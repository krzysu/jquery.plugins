#
# jquery.fixed-position
# desc: keep element in fixed position during window scroll
# version: 0.1
# requires: jQuery 1.7+

# how to use?
# init: 		$(selector).fixedPosition(options)
# destroy: 	$(selector).fixedPosition('destroy')

# options:
# 	parent: null           // parent element that limit box position
#   margin: 0              // distance between positioned element and top of the window 
#   preserveSpace: false   // will add temporary element in exactly the same dimensions like positioned element to preserve page layout
#


$ = jQuery
positioner = null

$.fn.fixedPosition = (method) ->
  if methods[method]
    return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ))
  else if typeof method == 'object' || !method
    return methods.init.apply( this, arguments )
  else
    $.error('Method ' +  method + ' does not exist on jQuery.fixedPosition')    


methods = 
  init: (options) ->
  	defaults =
      parent: null
      margin: 0
      preserveSpace: false

    settings = $.extend({}, defaults, options)
    positioner = new Positioner(@, settings)
    return @

  destroy: () ->
    return @


class window.Positioner
  constructor: (@box, @parent, @margin = 0, @preserveSpace = false) ->
    if @box != null && $(@box).length > 0
      @_setData()
      @_initEvents()
      @_controlBoxPosition() # check initial position of box

  _setData: () ->
    @isBoxFixed = false # for test purposes
    @isBoxAtTheBottom = false # for test purposes

    unless @isPreserved?
      @isPreserved = false

    @$box = $(@box)

    @_unpinBox() # we must get box data from unpinned state
    @boxWidth = @$box.width()
    boxOffsetTop = @$box.offset().top
    @boxOffsetLeft = @$box.offset().left
    @startPoint = boxOffsetTop - @margin
    @endPoint = $(document).height() # default height of whole page

    if @parent != null && $(@parent).length > 0
      $parent = $(@parent)
      parentHeight = $parent.height()
      @endPoint = boxOffsetTop + parentHeight - @$box.outerHeight() - @margin

      parentWidth = $parent.width()
      parentPaddingTop = ($parent.innerHeight() - parentHeight)/2
      parentPaddingLeft = ($parent.innerWidth() - parentWidth)/2
      @distanceFromTopOfParent = parentHeight - @$box.outerHeight() + parentPaddingTop
      @distanceFromLeftOfParent = parentWidth - @$box.outerWidth() + parentPaddingLeft

  _initEvents: () ->
    $(window).on 'scroll.positioner', () =>
      @_controlBoxPosition()

    $(window).on 'resize.positioner', () =>
      @_setData()
      @_controlBoxPosition()

  _controlBoxPosition: () ->
    windowTopScroll = $(window).scrollTop()

    if windowTopScroll > @startPoint && windowTopScroll < @endPoint
      @_pinBox()
      @_preserveSpace()
    else if windowTopScroll >= @endPoint
      @_unpinBoxAtTheEnd()
    else 
      @_unpinBox()
      @_returnSpace()

  _pinBox: () ->
    @$box
      .addClass('pinned')
      .css
        position: 'fixed'
        width: @boxWidth
        left: @boxOffsetLeft
        top: @margin

    @isBoxFixed = true
    @isBoxAtTheBottom = false

  _unpinBox: () ->
    @$box
      .removeClass('pinned')
      .css
        position: ''
        width: ''
        left: ''
        top: ''

    @isBoxFixed = false
    @isBoxAtTheBottom = false

  _unpinBoxAtTheEnd: () ->
    @$box
      .removeClass('pinned')
      .css
        position: 'absolute'
        width: @boxWidth
        left: @distanceFromLeftOfParent
        top: @distanceFromTopOfParent

    @isBoxFixed = false
    @isBoxAtTheBottom = true

  _preserveSpace: () ->
    if @preserveSpace
      $spacer = $('<div class="positioner-spacer">')
      unless @isPreserved
        height = @$box.outerHeight(true)
        $spacer.css('height', height).insertAfter(@box)
        @isPreserved = true

  _returnSpace: () ->
    if @isPreserved
      $('.positioner-spacer').remove()
      @isPreserved = false


  refresh: () ->
    @_setData()

  destroy: () ->
    @_unpinBox()
    $('.positioner-spacer').remove()
    $(window).off '.positioner'


