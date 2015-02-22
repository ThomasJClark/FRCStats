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
      # In case this is covering something up, turn transparent when the mouse
      # is over it.
      .on 'mouseover', () -> (d3.select this).attr 'opacity', 0.25
      .on 'mouseout',  () -> (d3.select this).attr 'opacity', 1.0
    enter.append 'rect'
      .style 'fill', '#1ABC9C'
    enter.append 'path'
      .style 'fill', '#1ABC9C'
      .attr 'd', 'M 0 0 L 8 -24 L -8 -24 Z'
    enter.append 'text'
      .style 'fill', 'White'
      .style 'text-anchor', 'middle'
      .attr { x: 0, y: -24 }

    # Move the entire bubble to the correct position
    infoBubble.transition()
      .duration 500
      .ease 'sin-in-out'
      .attr
        transform: "translate(#{ my.x() }, #{ my.y() })"

    # Update the text in the bubble
    (infoBubble.select 'text').text my.text()

    # The bubble's outer rectangle should fit the bounding box of the text,
    # plus padding on each side.
    textBBox = (infoBubble.select 'text').node().getBBox()
    infoBubble.select 'rect'
      .attr
        rx: 3
        x: textBBox.x - 16
        y: textBBox.y - 8
        width: textBBox.width + 32
        height: textBBox.height + 16


  # Get/set the text to show inside of the infoBubble
  my.text = (_text) ->
    if not _text
      text
    else
      text = _text
      my

  # Get/set the x position of the tip of the point.
  my.x = (_x) ->
    if not _x
      x
    else
      x = _x
      my

  # Get/set the y positio of the tip of the point.  The actual bubble is
  # rendered above this point.
  my.y = (_y) ->
    if not _y
      y
    else
      y = _y
      my

  my
