class HtmlFactory
  canvas: () ->
    if $('#test-canvas').length == 0
      @initCanvas()
    $('#test-canvas')

  initCanvas: () ->
    $('body').append("<div id='test-canvas>"}))

  clear: () ->
    @canvas().html('')

  boxWithParent: (boxId, parentId) ->
    html = "<div id='#{parentId}' style='padding: 10px; height: 1000px; width: 1000px; margin: 100px 20px; position: relative;'>
              <div id='#{boxId}' style='padding: 10px; height: 100px; width: 100px;'></div>
            </div>"
    @canvas().append(html)


class Window
  constructor: (@positioner) ->
    @$win = $(window)
    
  scrollInRange: ->
    positionInRange = @positioner.startPoint + 100
    @$win.scrollTop(positionInRange).trigger('scroll')

  scrollAboveRange: ->
    positionAboveRange = @positioner.startPoint - 100
    @$win.scrollTop(positionAboveRange).trigger('scroll')

  scrollUnderRange: ->
    positionUnderRange = @positioner.endPoint + 100
    @$win.scrollTop(positionUnderRange).trigger('scroll')

  scrollStartPoint: ->
    position = @positioner.startPoint
    @$win.scrollTop(position).trigger('scroll')

  scrollEndPoint: ->
    position = @positioner.endPoint
    @$win.scrollTop(position).trigger('scroll')

  resize: ->
    @$win.trigger('resize')


describe "Positioner - fix element position during scroll", ->
  
  htmlFactory = new HtmlFactory()

  beforeEach () ->
    htmlFactory.boxWithParent('box', 'parent')

  describe "Positioner without parent element", ->
    it "should set end point to height of document if no parent element provided or not found", ->
      positioner = new Positioner('#box', '', 10)

      expect(positioner.endPoint).toEqual( $(document).height() )
      expect( (positioner.endPoint - positioner.startPoint) > 900 ).toBeTruthy()

  describe "Positioner with parent element", ->

    beforeEach () ->
      @margin = 10
      @positioner = new Positioner('#box', '#parent', @margin)
      @browserWindow = new Window(@positioner)

    it "should set start and end points, where box will have position fixed", ->
      expect( @positioner.endPoint - @positioner.startPoint ).toEqual(880)

    it "should pin box position when window top scroll value is in range of start/end points", ->
      @browserWindow.scrollInRange()
      distanceFromTopOfWindow = $('#box').offset().top - $(window).scrollTop()

      expect(distanceFromTopOfWindow).toEqual(@margin)
      expect(@positioner.isBoxFixed).toEqual(true)

    it "should not pin box position when window top scroll value is on edge of start point", ->
      @browserWindow.scrollStartPoint()
      expect(@positioner.isBoxFixed).toEqual(false)

    it "should not pin box position when window top scroll value is on edge of end point", ->
      @browserWindow.scrollEndPoint()
      expect(@positioner.isBoxFixed).toEqual(false)

    it "should unpin box position when window top scroll value was in range but now is above the starting point", ->
      @browserWindow.scrollInRange()
      @browserWindow.scrollAboveRange()
      
      distanceFromTopOfWindow = $('#box').offset().top - $(window).scrollTop()

      expect(distanceFromTopOfWindow).not.toEqual(@margin)
      expect(@positioner.isBoxFixed).toEqual(false)

    it "should leave box at the bottom of parent when window top scroll value was in range but now is under the end point", ->
      @browserWindow.scrollInRange()
      @browserWindow.scrollUnderRange()

      distanceFromTopOfWindow = $('#box').offset().top - $(window).scrollTop()
      distanceFromTopOfParent = $('#box').offset().top - $('#parent').offset().top

      expect(distanceFromTopOfWindow).not.toEqual(@margin)
      expect(distanceFromTopOfParent).toEqual(890)
      expect(@positioner.isBoxAtTheBottom).toEqual(true)

    it "should be able to destroy itself", ->
      @browserWindow.scrollInRange()
      
      @positioner.destroy()

      distanceFromTopOfWindow = $('#box').offset().top - $(window).scrollTop()
      expect(distanceFromTopOfWindow).not.toEqual(@margin)
      expect(@positioner.isBoxFixed).toEqual(false)

    it "should preserve the width of positioned box when pinned", ->
      $box = $('#box')
      boxWidthBefore = $box.width()
      @browserWindow.scrollInRange()
      boxWidthAfter = $box.width()

      expect(boxWidthBefore).toEqual(boxWidthAfter)

    it "should preserve the width of positioned box when left at the bottom", ->
      @browserWindow.scrollInRange()
      
      $box = $('#box')
      boxWidthBefore = $box.width()
      @browserWindow.scrollUnderRange()
      boxWidthAfter = $box.width()

      expect(boxWidthBefore).toEqual(boxWidthAfter)

    it "should recalculate all values after window resize", ->
      @browserWindow.scrollInRange()
      @browserWindow.resize()

      distanceFromTopOfWindow = $('#box').offset().top - $(window).scrollTop()

      expect(distanceFromTopOfWindow).toEqual(@margin)
      expect(@positioner.isBoxFixed).toEqual(true)

    afterEach () ->
      @positioner.destroy()