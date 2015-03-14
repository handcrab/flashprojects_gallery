var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

jQuery(function() {
  var Gallery, GalleryItem, GalleryItemView, GalleryView, pfolio;
  GalleryItem = (function(superClass) {
    extend(GalleryItem, superClass);

    function GalleryItem() {
      return GalleryItem.__super__.constructor.apply(this, arguments);
    }

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
        'data-description': (this.model.get('author')) + "@" + (this.model.get('date')) + ": " + (this.model.get('description'))
      };
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
            return _this.renderItems(items.models);
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
  pfolio = new GalleryView;
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
      index: this,
      event: e,
      onslide: function(index, slide) {
        var node, text;
        text = $(this.list[index]).data('description');
        node = this.container.find('.description');
        node.empty();
        $(node).append('<h5>').find(':first-child').append(text);
        return slide;
      }
    };
    links = $(this).parent().find('a');
    return blueimp.Gallery(links, options);
  });
  return $('nav a').click(function(e) {
    $('nav a').removeClass('active button-primary');
    return $(this).addClass('active button-primary');
  });
});
