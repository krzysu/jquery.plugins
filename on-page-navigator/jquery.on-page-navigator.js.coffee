#
# jquery.on-page-navigator
# desc: add one page navigation based on anchors, highlights current page position
# version: 0.2
# requires: jQuery 1.7+

# how to use?
# init:     $(parent_selector).onPageNavigator(options)
# destroy:  $(parent_selector).onPageNavigator('destroy')

# options:
#   speed: 1000                      // speed of autoscroll
#   topOffset: 0                     // top offset of destination position
#   callbackBefore: (el) ->          // callback before autoscroll begins, gets raw clicked element
#   callbackAfter: (el) ->           // callback after autoscroll ends, gets raw clicked element
#   callbackGetHighlight: (el) ->    // callback when current navigation element is highlighted, gets raw current element
#   callbackLostHighlight: ->        // callback when all elements lost highlight, means window is outside of any element in page navigation


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
      callbackBefore: ->
      callbackAfter: ->
      callbackGetHighlight: ->
      callbackLostHighlight: ->

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
      @onNavigate(e.currentTarget)
                      
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

      $activeEl = $parent.find('a[href=' + activeEl + ']')
      if $activeEl.hasClass('active')
        return

      $parent.find('a').removeClass('active')
      $toHighlight = $activeEl
      $toHighlight.addClass('active')
      @settings.callbackGetHighlight( $toHighlight[0] )
    else
      $parent.find('a').removeClass('active')
      @settings.callbackLostHighlight()

  destroy: () ->
    $(@parent).off '.navigator'
    $(window).off '.navigator'

