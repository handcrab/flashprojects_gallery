var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

jQuery(function() {
  var App, Gallery, GalleryItem, GalleryItemView, GalleryView, app;
  GalleryItem = (function(superClass) {
    extend(GalleryItem, superClass);

    function GalleryItem() {
      return GalleryItem.__super__.constructor.apply(this, arguments);
    }

    GalleryItem.id_count = 0;

    GalleryItem.prototype.initialize = function() {
      return this.id = (GalleryItem.id_count += 1);
    };

    GalleryItem.prototype.dateYear = function() {
      var date, dateRegexp;
      dateRegexp = /(\d{2}).(\d{2}).(\d{4})/i;
      date = this.get('date').toString();
      return date.match(dateRegexp)[3];
    };

    GalleryItem.prototype.get = function(attr) {
      if (typeof this[attr] === 'function') {
        return this[attr]();
      }
      return GalleryItem.__super__.get.call(this, attr);
    };

    return GalleryItem;

  })(Backbone.Model);
  Gallery = (function(superClass) {
    extend(Gallery, superClass);

    function Gallery() {
      return Gallery.__super__.constructor.apply(this, arguments);
    }

    Gallery.prototype.model = GalleryItem;

    Gallery.prototype.url = 'https://dl.dropboxusercontent.com/u/31230733/swfs/files.json';

    Gallery.prototype.getYears = function(items) {
      var item;
      if (items == null) {
        items = this.models;
      }
      return _((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = items.length; i < len; i++) {
          item = items[i];
          results.push(item.get('dateYear'));
        }
        return results;
      })()).uniq().filter(function(e) {
        return !_.isEmpty(e);
      }).sort();
    };

    Gallery.prototype.getSubjects = function(items) {
      var item;
      if (items == null) {
        items = this.models;
      }
      return _((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = items.length; i < len; i++) {
          item = items[i];
          results.push(item.get('subject'));
        }
        return results;
      })()).uniq().sort();
    };

    return Gallery;

  })(Backbone.Collection);
  GalleryItemView = (function(superClass) {
    extend(GalleryItemView, superClass);

    function GalleryItemView() {
      return GalleryItemView.__super__.constructor.apply(this, arguments);
    }

    GalleryItemView.prototype.tagName = 'a';

    GalleryItemView.prototype.className = 'gallery-item';

    GalleryItemView.prototype.attributes = function() {
      return {
        href: "" + (this.model.get('href')),
        type: this.model.get('href').match(/swf$/i) ? "application/x-shockwave-flash" : void 0,
        'data-description': this.descriptionStr(),
        'data-id': this.model.id
      };
    };

    GalleryItemView.prototype.descriptionStr = function() {
      return (this.model.get('author')) + "@" + (this.model.get('date')) + ": " + (this.model.get('description'));
    };

    GalleryItemView.prototype.render = function() {
      $(this.el).html("<img class='preview' src='" + (this.model.get('preview')) + "'>");
      return this;
    };

    return GalleryItemView;

  })(Backbone.View);
  GalleryView = (function(superClass) {
    extend(GalleryView, superClass);

    function GalleryView() {
      return GalleryView.__super__.constructor.apply(this, arguments);
    }

    GalleryView.prototype.el = $('#gallery');

    GalleryView.prototype.initialize = function() {
      this.collection = new Gallery;
      return this.render();
    };

    GalleryView.prototype.render = function() {
      return this.collection.fetch({
        success: (function(_this) {
          return function(items) {
            $(_this.el).find('.content').empty();
            $(_this.el).find('.content').css({
              background: 'none'
            });
            _this.renderItems(items.models);
            return _this.trigger('render');
          };
        })(this)
      });
    };

    GalleryView.prototype.clearContent = function() {
      return $(this.el).find('.content').empty();
    };

    GalleryView.prototype.renderItems = function(items) {
      var i, item, item_view, len, results;
      if (items.target) {
        this.clearContent();
        items = this.collection.models;
      }
      results = [];
      for (i = 0, len = items.length; i < len; i++) {
        item = items[i];
        item_view = new GalleryItemView({
          model: item
        });
        results.push($(this.el).find('.content').append(item_view.render().el));
      }
      return results;
    };

    GalleryView.prototype.showByYears = function() {
      var $content, i, itemsByYear, len, ref, results, year;
      $content = this.clearContent();
      ref = this.collection.getYears();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        year = ref[i];
        $content.append("<h2>Год: " + year + "</h2>");
        itemsByYear = this.collection.where({
          dateYear: year
        });
        results.push(this.renderItems(itemsByYear));
      }
      return results;
    };

    GalleryView.prototype.showBySubjects = function() {
      var $content, i, itemsBySubject, len, ref, results, subject;
      $content = this.clearContent();
      ref = this.collection.getSubjects();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        subject = ref[i];
        $content.append("<h2>Тема: " + subject + "</h2>");
        itemsBySubject = this.collection.where({
          subject: subject
        });
        results.push(this.renderItems(itemsBySubject));
      }
      return results;
    };

    GalleryView.prototype.events = {
      'click .show-by-years': 'showByYears',
      'click .show-by-subjects': 'showBySubjects',
      'click .show-all': 'renderItems'
    };

    return GalleryView;

  })(Backbone.View);
  App = (function(superClass) {
    extend(App, superClass);

    function App() {
      return App.__super__.constructor.apply(this, arguments);
    }

    App.prototype.routes = {
      'by_years': 'by_years',
      'by_subjects': 'by_subjects',
      'all': 'all',
      'projects/:id': 'display_proj'
    };

    App.prototype.initialize = function() {
      return this.gallery = new GalleryView;
    };

    App.prototype.clickItem = function(item_id) {
      return this.gallery.$el.find("[data-id='" + item_id + "']").click();
    };

    App.prototype.display_proj = function(proj_id) {
      return this.gallery.on('render', (function(_this) {
        return function() {
          return _this.clickItem(proj_id);
        };
      })(this));
    };

    App.prototype.by_years = function() {
      return this.filter('.show-by-years');
    };

    App.prototype.by_subjects = function() {
      return this.filter('.show-by-subjects');
    };

    App.prototype.all = function() {
      return this.filter('.show-all');
    };

    App.prototype.filter = function(query) {
      if (!_.isEmpty(this.gallery.collection.models)) {
        return this.gallery.$el.find(query).trigger('click');
      }
      return $(document).ajaxSuccess((function(_this) {
        return function() {
          return _this.gallery.$el.find(query).trigger('click');
        };
      })(this));
    };

    return App;

  })(Backbone.Router);
  app = app || {};
  app.pfolio = new App;
  Backbone.history.start();
  blueimp.Gallery.prototype.applicationFactory = function(obj, callback) {
    var $element;
    $element = $('<div>').addClass('application-content');
    $.get(obj.href).done(function(result) {
      $element.flash({
        swf: obj.href,
        width: '100%',
        height: '100%',
        valign: "top",
        allowFullScreen: true
      });
      return callback({
        type: 'load',
        target: $element[0]
      });
    }).fail(function() {
      return callback({
        type: 'error',
        target: $element[0]
      });
    });
    return $element[0];
  };
  $(document).on('click', '#gallery a.gallery-item', function(e) {
    var links, options;
    options = {
      index: $(this).index(),
      event: e,
      preloadRange: 1,
      onslide: function(index, slide) {
        var $link, id, node, text;
        $link = $(this.list[index]);
        id = $link.data('id');
        Backbone.history.navigate("projects/" + id);
        this.slidesContainer;
        text = $link.data('description');
        node = this.container.find('.description');
        node.empty();
        $(node).append('<h5>').find(':first-child').append(text);
        $(node).append('<div id="vk_like">');
        VK.Widgets.Like("vk_like", {
          type: 'vertical',
          pageUrl: window.location.href
        });
        return slide;
      }
    };
    links = $(this).parent().find('a');
    return blueimp.Gallery(links, options);
  });
  $('nav a').click(function(e) {
    $('nav a').removeClass('active button-primary');
    return $(this).addClass('active button-primary');
  });
  return VK.init({
    apiId: 3568852,
    onlyWidgets: true,
    pageImage: '../img/adobe_flash.png',
    text: 'Интересные работы'
  });
});
