class window.Positioner
  constructor: (@box, @parent, @margin = 0) ->
    @_setData()
    @_initEvents()
    @_controlBoxPosition() # check initial position of box

  _setData: () ->
    @isBoxFixed = false # for test purposes
    @isBoxAtTheBottom = false # for test purposes

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
    else if windowTopScroll >= @endPoint
      @_unpinBoxAtTheEnd()
    else 
      @_unpinBox()

  _pinBox: () ->
    @$box.css
      position: 'fixed'
      width: @boxWidth
      left: @boxOffsetLeft
      top: @margin

    @isBoxFixed = true
    @isBoxAtTheBottom = false
        
  _unpinBox: () ->
    @$box.css
      position: ''
      width: ''
      left: ''
      top: ''

    @isBoxFixed = false
    @isBoxAtTheBottom = false

  _unpinBoxAtTheEnd: () ->
    @$box.css
      position: 'absolute'
      width: @boxWidth
      left: @distanceFromLeftOfParent
      top: @distanceFromTopOfParent

    @isBoxFixed = false
    @isBoxAtTheBottom = true

  refresh: () ->
    @_setData()

  destroy: () ->
    @_unpinBox()
    $(window).off '.positioner'


