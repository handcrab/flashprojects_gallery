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
    # get: (attr) ->
    #   return @[attr]() if (typeof @[attr] == 'function')
    #   super attr

  # -- Collection
  class Gallery extends Backbone.Collection
    model: GalleryItem
    url: 'https://dl.dropboxusercontent.com/u/31230733/swfs/files.json'

    initialize: -> @fetch()

    # HELPERS
    # -------
    # list of the projects' dates
    getYears: (items=@models) ->
      _((item.dateYear() for item in items)).uniq()

    # list of the projects' subjects
    getSubjects: (items=@models) ->
      _((item.dateYear() for item in items)).uniq()

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
    attributes: ->
      # rel: 'gallery'
      title: "#{ @model.get 'author' }@#{ @model.get 'date' }: #{ @model.get 'description' }"
      href: "#{ @model.get 'href' }"
      type: "application/x-shockwave-flash" if @model.get('href').match(/swf$/i)
      'data-description': "#{ @model.get 'author' }@#{ @model.get 'date' }: #{ @model.get 'description' }"
    
    initialize: ->
      #_.bindAll @, 'change', 'remove'

      # model events
      # on model.change - update view
      # @model.bind 'change', @render, @
      # @model.bind 'remove', @unrender

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
      # @collection.bind 'add', @appendItem
      # @collection.bind 'sync', @render, @
      # @collection.fetch()
      @render()

    render: ->
      # for item in @collection.models
      @collection.fetch
        success: (items) =>
          # $(@el).find('.loading').hide()
          # $(@el).find('.content').empty()

          for item in items.models
            item_view = new GalleryItemView model: item
            # $(@el).find('ul').append item_view.render().el
            $(@el).find('.content').append item_view.render().el

  window.Gallery = Gallery
  window.GalleryItem = GalleryItem
  window.GalleryView = GalleryView
  pfolio = new GalleryView
