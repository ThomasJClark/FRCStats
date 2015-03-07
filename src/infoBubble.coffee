# infoBubble.coffee
#
# Shows a tiny green speech bubble to put text in.  This is used to annotate
# the histogram with extra statistical information.
frcstats = frcstats ? {}
frcstats.infoBubble = (id) ->
  text = ''
  x = 0
  y = 0

  my = (container) ->
    infoBubble = (container.selectAll '#' + id).data [ my ]
    infoBubble.exit().remove()

    enter = infoBubble.enter().append 'g'
      .attr 'id', id
      # Only show the whole bubble when it's moused over.
      .on 'mouseover', () ->
        bubbleRect.attr 'display', 'inline'
        bubbleText.attr 'display', 'inline'
      .on 'mouseout',  () ->
        bubbleRect.attr 'display', 'none'
        bubbleText.attr 'display', 'none'

    enter.append 'rect'
      .style 'fill', '#1ABC9C'
      .attr 'display', 'none'
    enter.append 'path'
      .style 'fill', '#1ABC9C'
      .attr
        d: 'M 0 0 L 8 -24 L -8 -24 Z'
        transform: "translate(#{ my.x() }, #{ my.y() })"
    enter.append 'text'
      .style 'fill', 'White'
      .style 'text-anchor', 'middle'
      .attr 'display', 'none'

    bubbleRect = infoBubble.select 'rect'
    bubbleTip = infoBubble.select 'path'
    bubbleText = infoBubble.select 'text'

    # Update the text and position of the bubble
    bubbleText
      .text my.text()
      .attr
        x: my.x()
        y: my.y() - 24

    # Transition the tip to the new position
    bubbleTip
      .transition()
        .duration 500
        .ease 'sin-in-out'
        .attr 'transform', "translate(#{ my.x() }, #{ my.y() })"

    # The bubble's outer rectangle should fit the bounding box of the text,
    # plus padding on each side. We have to temporarily set the text to display
    # inline in order to get its bounds, since it might be hidden.
    textDisplay = bubbleText.attr 'display'
    bubbleText.attr 'display', 'inline'
    textBBox = bubbleText.node().getBBox()
    bubbleText.attr 'display', textDisplay

    # If the text extends outside of the container, move it back inside.
    bubbleText.attr 'transform', "translate(#{Math.max -textBBox.x, 0}, 0)"
    textBBox.x = Math.max textBBox.x, 0

    bubbleRect
      .attr
        rx: 3
        x: textBBox.x - 16
        y: textBBox.y - 8
        width: textBBox.width + 32
        height: textBBox.height + 16


  # Get/set the text to show inside of the infoBubble
  my.text = (_text) ->
    if not _text?
      text
    else
      text = _text
      my

  # Get/set the x position of the tip of the point.
  my.x = (_x) ->
    if not _x?
      x
    else
      x = _x
      my

  # Get/set the y positio of the tip of the point.  The actual bubble is
  # rendered above this point.
  my.y = (_y) ->
    if not _y?
      y
    else
      y = _y
      my

  my
