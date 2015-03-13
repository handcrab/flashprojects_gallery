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

  window.Gallery = Gallery
  window.GalleryItem = GalleryItem
  # window.GalleryView = GalleryView