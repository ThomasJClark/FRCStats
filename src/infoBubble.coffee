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

    if enter.node()
      bubbleRect = enter.append 'rect'
        .style 'fill', '#1ABC9C'
        .attr 'display', 'none'
      bubbleTip = enter.append 'path'
        .style 'fill', '#1ABC9C'
        .attr 'd', 'M 0 0 L 8 -24 L -8 -24 Z'
      bubbleText = enter.append 'text'
        .style 'fill', 'White'
        .style 'text-anchor', 'middle'
        .attr { x: 0, y: -24 }
        .attr 'display', 'none'

    # Move the entire bubble to the correct position
    infoBubble.transition()
      .duration 500
      .ease 'sin-in-out'
      .attr
        transform: "translate(#{ my.x() }, #{ my.y() })"

    # Update the text in the bubble
    (infoBubble.select 'text').text my.text()

    # The bubble's outer rectangle should fit the bounding box of the text,
    # plus padding on each side. We have to temporarily set the text to display
    # inline in order to get its bounds, since it might be hidden.
    textDisplay = (infoBubble.select 'text').attr 'display'
    (infoBubble.select 'text').attr 'display', 'inline'
    textBBox = (infoBubble.select 'text').node().getBBox()
    (infoBubble.select 'text').attr 'display', textDisplay

    infoBubble.select 'rect'
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
