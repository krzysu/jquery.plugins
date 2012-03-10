#
# jquery.on-page-navigator
# desc: add one page navigation based on anchors, highlights current page position
# version: 0.1
# requires: jQuery 1.7+

# how to use?
# init: 		$(parent_selector).onPageNavigator(options)
# destroy: 	$(parent_selector).onPageNavigator('destroy')

# options:
# 	speed: 1000                   // speed of slide
#   topOffset: 0                  // top offset of destination position
#   callbackBefore: (el) ->       // callback before slide begins, gets raw clicked element
#   callbackAfter: (el) ->        // callback after slide ends, gets raw clicked element
#


$ = jQuery
navigator = null

$.fn.onPageNavigator = (method) ->
  if methods[method]
    return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ))
  else if typeof method == 'object' || !method
    return methods.init.apply( this, arguments )
  else
    $.error('Method ' +  method + ' does not exist on jQuery.onPageNavigator')    


methods = 
  init: (options) ->

    defaults =
      speed: 1000,
      topOffset: 0,
      callbackBefore: () ->
      callbackAfter: () ->

    settings = $.extend({}, defaults, options)
    navigator = new PageNavigator(@, settings)
    return @

  destroy: () ->
    navigator.destroy()
    return @


class PageNavigator
  constructor: (@parent, @settings) ->
    @initNavigateEvent()
    @initHighlightingEvent()

  initNavigateEvent: () ->
    $(@parent).on 'click.navigator', 'a', (e) =>
      e.preventDefault()
      @onNavigate(e.target)
                      
  onNavigate: (el) ->
    $el = $(el)
    settings = @settings
    settings.callbackBefore(el)

    destinationId = $el.attr('href')
    destination = $(destinationId).offset().top - settings.topOffset
      
    $("html:not(:animated),body:not(:animated)").animate
      scrollTop: destination,
      settings.speed,
      ->
        settings.callbackAfter(el)

  initHighlightingEvent: () ->
    ids = []
    $parent = $(@parent)

    $parent.find('a').each (i) ->
      ids.push( $(@).attr('href') )

    $(window).on 'scroll.navigator', (e) =>
      @highlight(e.target, ids)

  highlight: (win, ids) ->
    scroll = $(win).scrollTop()
    activeEl = null
    $parent = $(@parent)
    
    for id in ids 
      top = $(id).offset().top - @settings.topOffset - 10
      bottom = $(id).offset().top + $(id).outerHeight()

      if scroll > top && scroll < bottom
        activeEl = id
    
    if( activeEl != null )
      $parent.find('a').removeClass('active')
      $parent.find('a[href=' + activeEl + ']').addClass('active')
    else
      $parent.find('a').removeClass('active')

  destroy: () ->
    $(@parent).off '.navigator'
    $(window).off '.navigator'

