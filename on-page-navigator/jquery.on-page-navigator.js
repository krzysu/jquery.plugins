//
// jquery.on-page-navigator
// desc: add one page navigation based on anchors, highlights current page position
// version: 0.2
// requires: jQuery 1.7+

// how to use?
// init:     $(parent_selector).onPageNavigator(options)
// destroy:  $(parent_selector).onPageNavigator('destroy')

// options:
//   speed: 1000                      // speed of autoscroll
//   topOffset: 0                     // top offset of destination position
//   callbackBefore: (el) ->          // callback before autoscroll begins, gets raw clicked element
//   callbackAfter: (el) ->           // callback after autoscroll ends, gets raw clicked element
//   callbackGetHighlight: (el) ->    // callback when current navigation element is highlighted, gets raw current element
//   callbackLostHighlight: ->        // callback when all elements lost highlight, means window is outside of any element in page navigation

(function() {
  var $, PageNavigator, methods, navigator;

  $ = jQuery;

  navigator = null;

  $.fn.onPageNavigator = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      return $.error('Method ' + method + ' does not exist on jQuery.onPageNavigator');
    }
  };

  methods = {
    init: function(options) {
      var defaults, settings;
      defaults = {
        speed: 1000,
        topOffset: 0,
        callbackBefore: function() {},
        callbackAfter: function() {},
        callbackGetHighlight: function() {},
        callbackLostHighlight: function() {}
      };
      settings = $.extend({}, defaults, options);
      navigator = new PageNavigator(this, settings);
      return this;
    },
    destroy: function() {
      navigator.destroy();
      return this;
    }
  };

  PageNavigator = (function() {

    function PageNavigator(parent, settings) {
      this.parent = parent;
      this.settings = settings;
      this.initNavigateEvent();
      this.initHighlightingEvent();
    }

    PageNavigator.prototype.initNavigateEvent = function() {
      var _this = this;
      return $(this.parent).on('click.navigator', 'a', function(e) {
        e.preventDefault();
        return _this.onNavigate(e.target);
      });
    };

    PageNavigator.prototype.onNavigate = function(el) {
      var $el, destination, destinationId, settings;
      $el = $(el);
      settings = this.settings;
      settings.callbackBefore(el);
      destinationId = $el.attr('href');
      destination = $(destinationId).offset().top - settings.topOffset;
      return $("html:not(:animated),body:not(:animated)").animate({
        scrollTop: destination
      }, settings.speed, function() {
        return settings.callbackAfter(el);
      });
    };

    PageNavigator.prototype.initHighlightingEvent = function() {
      var $parent, ids,
        _this = this;
      ids = [];
      $parent = $(this.parent);
      $parent.find('a').each(function(i) {
        return ids.push($(this).attr('href'));
      });
      return $(window).on('scroll.navigator', function(e) {
        return _this.highlight(e.target, ids);
      });
    };

    PageNavigator.prototype.highlight = function(win, ids) {
      var $parent, $toHighlight, activeEl, bottom, id, scroll, top, _i, _len;
      scroll = $(win).scrollTop();
      activeEl = null;
      $parent = $(this.parent);
      for (_i = 0, _len = ids.length; _i < _len; _i++) {
        id = ids[_i];
        top = $(id).offset().top - this.settings.topOffset - 10;
        bottom = $(id).offset().top + $(id).outerHeight();
        if (scroll > top && scroll < bottom) {
          activeEl = id;
        }
      }
      if (activeEl !== null) {
        $parent.find('a').removeClass('active');
        $toHighlight = $parent.find('a[href=' + activeEl + ']');
        $toHighlight.addClass('active');
        return this.settings.callbackGetHighlight($toHighlight[0]);
      } else {
        $parent.find('a').removeClass('active');
        return this.settings.callbackLostHighlight();
      }
    };

    PageNavigator.prototype.destroy = function() {
      $(this.parent).off('.navigator');
      return $(window).off('.navigator');
    };

    return PageNavigator;

  })();

}).call(this);
