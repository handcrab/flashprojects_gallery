jQuery ->

  # MODELS
  # ======
  # -- Item
  #   "href": "https://flash_url.swf",
  #   "preview": "https://img_url.jpg",
  #   "date": "31.11.2012",
  #   "author": "John Doe",
  #   "subject": "foobar",
  #   "description": "lorem ipsum"
  class GalleryItem extends Backbone.Model
    # defaults: ->
    dateYear: ->
      dateRegexp = /(\d{2}).(\d{2}).(\d{4})/i
      date = @get('date').toString()
      date.match( dateRegexp )[3]

    get: (attr) ->
      return @[attr]() if (typeof @[attr] == 'function')
      super attr

  # -- Collection
  class Gallery extends Backbone.Collection
    model: GalleryItem
    url: 'https://dl.dropboxusercontent.com/u/31230733/swfs/files.json'

    initialize: -> @fetch()

    # HELPERS
    # -------
    # list of the projects' dates
    getYears: (items=@models) ->
      # .filter (e) -> not _.isEmpty e
      _((item.get('dateYear') for item in items))
        .uniq()
        .filter (e) -> not _.isEmpty e
        .sort()

    # list of the projects' subjects
    getSubjects: (items=@models) ->
      _((item.get('subject') for item in items))
        .uniq()
        # .filter (e) -> not _.isEmpty e
        .sort()
    # getYears: ->
    #   if @models.length is 0
    #     @fetch 
    #       success: (items) =>
    #         return _getYears items
    #   else
    #     return _getYears items

  # VIEWS
  # =====
  # --- Item View
  # a(href="https://flash_url.swf" type="application/x-shockwave-flash" data-description="flash") 
  #   img(src="image_preview_url.jpg")
  class GalleryItemView extends Backbone.View
    tagName: 'a'
    className: 'gallery-item'
    attributes: ->
      # rel: 'gallery'
      # title: "#{ @model.get 'author' }@#{ @model.get 'date' }: #{ @model.get 'description' }"
      href: "#{ @model.get 'href' }"
      type: "application/x-shockwave-flash" if @model.get('href').match(/swf$/i)
      'data-description': "#{ @model.get 'author' }@#{ @model.get 'date' }: #{ @model.get 'description' }"

    # initialize: ->

    render: ->
      $(@el).html """
        <img class='preview' src='#{ @model.get 'preview' }'>
      """
      @

  # --- Collection View
  class GalleryView extends Backbone.View
    el: $ '#gallery'

    initialize: ->
      @collection = new Gallery
      # @collection.fetch()
      @render()

    render: ->
      # for item in @collection.models
      @collection.fetch
        success: (items) =>
          # $(@el).find('.loading').hide()
          $(@el).find('.content').empty()
          $(@el).find('.content').css background: 'none' # disable spinner
          for item in items.models
            item_view = new GalleryItemView model: item
            # $(@el).find('ul').append item_view.render().el
            $(@el).find('.content').append item_view.render().el
        @

    showByYears: ->
      $content = $(@el).find('.content')
      $content.empty()

      years = @collection.getYears()
      for year in years
        $content.append """
          <h2>Год: #{year}</h2>
        """
        itemsByYear = @collection.where dateYear: year
        for item in itemsByYear
          item_view = new GalleryItemView model: item
          $content.append item_view.render().el
    
    showBySubjects: ->
      $content = $(@el).find('.content')
      $content.empty()

      subjects = @collection.getSubjects()
      console.log subjects
      for subject in subjects
        $content.append """
          <h2>Тема: #{subject}</h2>
        """
        itemsBySubject = @collection.where subject: subject
        for item in itemsBySubject
          item_view = new GalleryItemView model: item
          $content.append item_view.render().el

    events:
      'click .show-by-years': 'showByYears'
      'click .show-by-subjects': 'showBySubjects'
      'click .show-all': 'render'

  window.Gallery = Gallery
  window.GalleryItem = GalleryItem
  window.GalleryView = GalleryView
  pfolio = new GalleryView

  # ---------------
  # blueImp gallery
  # flash obj
  blueimp.Gallery::applicationFactory = (obj, callback) ->
    $element = $('<div>')
      .addClass('application-content')
      # .attr('title', obj.title)

    $.get obj.href
      .done (result) ->
        $element.flash
          # id: 'flash-obj'
          swf: obj.href
          width: '100%'
          height: '100%'
          valign: "top"
          # scale: 'exactFit'
          allowFullScreen: true
        callback
          type: 'load'
          target: $element[0]
      .fail ->
        callback
          type: 'error'
          target: $element[0]
    return $element[0]

  $(document).on 'click', '#gallery a.gallery-item', (e) ->
    options =
      index: @
      event: e
      # enableKeyboardNavigation: false
      # fullScreen: true
      onslide: (index, slide) ->
        text = $(@list[index]).data('description')
        node = @container.find '.description'
        node.empty()
        $(node).append text
        slide
    links = $(@).parent().find('a')
    blueimp.Gallery links, options
