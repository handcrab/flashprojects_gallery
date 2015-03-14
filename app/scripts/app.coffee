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

    # initialize: -> @fetch()

    # list of the all dates
    getYears: (items=@models) ->
      # .filter (e) -> not _.isEmpty e
      _((item.get('dateYear') for item in items))
        .uniq()
        .filter (e) -> not _.isEmpty e
        .sort()

    # list of all subjects
    getSubjects: (items=@models) ->
      _((item.get('subject') for item in items))
        .uniq()
        # .filter (e) -> not _.isEmpty e
        .sort()

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
          @renderItems items.models
        # @

    clearContent: -> $(@el).find('.content').empty()

    renderItems: (items) ->
      if items.target # is event
        @clearContent()
        items = @collection.models
      for item in items
        item_view = new GalleryItemView model: item
        $(@el).find('.content').append item_view.render().el

    showByYears: ->
      # @collection.fetch unless @collection.models
      $content = @clearContent()

      for year in @collection.getYears()
        $content.append """
          <h2>Год: #{year}</h2>
        """
        itemsByYear = @collection.where dateYear: year
        @renderItems itemsByYear

    # showByYears
    showBySubjects: ->
      $content = @clearContent()

      for subject in @collection.getSubjects()
        $content.append """
          <h2>Тема: #{subject}</h2>
        """
        itemsBySubject = @collection.where subject: subject
        @renderItems itemsBySubject

    events:
      'click .show-by-years': 'showByYears'
      'click .show-by-subjects': 'showBySubjects'
      'click .show-all': 'renderItems'

  class App extends Backbone.Router
    routes:
      'by_years': 'by_years'
      'by_subjects': 'by_subjects'
      'all': 'all'

    initialize: ->
      @gallery = new GalleryView
      #     this.view = new MovieAppView({ model: this.model });
      #     params.append_at.append(this.view.render().el);
      # },

    search: (query, page) ->

    by_years: -> @filter '.show-by-years'
    by_subjects: -> @filter '.show-by-subjects'
    all: -> @filter '.show-all'

    filter: (query) ->
      unless _.isEmpty @gallery.collection.models
        return @gallery.$el.find(query).trigger('click')
      # console.log 'loading' unless @gallery.collection.models
      # @gallery.collection.on 'success', ->
      $(document).ajaxSuccess =>
        @gallery.$el.find(query).trigger('click')
        # @gallery.showByYears()
        # @gallery.$el.trigger 'click .show-by-years'

  app = app or {}
  app.pfolio = new App
  Backbone.history.start()

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
        $(node).append('<h5>').find(':first-child').append text
        slide
    links = $(@).parent().find('a')
    blueimp.Gallery links, options

  # ----
  # menu
  $('nav a').click (e) ->
    $('nav a').removeClass 'active button-primary' # clear
    $(@).addClass 'active button-primary'
