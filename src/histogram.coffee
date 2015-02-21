# histogram.coffee
#
# Renders an animated histogram of values that uses color to show percentile
# scores.
if not frcstats then frcstats = {}
frcstats.histogram = () ->
  data = undefined
  bins = undefined
  width = 800
  height = 800

  histogram = d3.layout.histogram()
  xScale = d3.scale.linear()
  yScale = d3.scale.linear()
  widthScale = d3.scale.linear()
  heightScale = d3.scale.linear()

  # Map the midddle 50 percentile to the same yellow color, and transition to
  # red and green for extremely high and extremely low percentile scores.
  colorScale  = d3.scale.linear()
    .domain [0, 0.25, 0.75, 1]
    .range ['#c0392b', '#f1c40f', '#f1c40f', '#27ae60']


  my = (container) ->
    bars = (container.selectAll '.bar').data bins

    # If there are any bars not needed for the new dataset, transition them into
    # the bottom of the graph before removing them.
    bars.exit().transition()
      .duration 200
      .ease 'exp-in'
      .attr
        y: height
        height: 0
      .style
        opacity: 0
      .each 'end', () -> (d3.select this).remove()

    # If there are any bars to add, add them at the bottom of the screen with
    # a height of 0, so they pop up to their assigned values
    bars.enter()
      .append 'rect'
        .attr
          class: 'bar'
          x: (d) -> xScale d.x
          y: height
          width: (d) -> (widthScale d.dx) - 4
          height: 0
          rx: 3
        .style
          fill: (d) -> colorScale d.percentile
          opacity: 0

    # Transition all bars to their correct position and size
    bars.transition()
      .duration 500
      .ease 'sin-in-out'
      .attr
        x: (d) -> xScale d.x
        y: (d) -> yScale d.y
        width: (d) -> (widthScale d.dx) - 4
        height: (d) -> heightScale d.y
      .style
        fill: (d) -> colorScale d.percentile
        opacity: 1


  my.xScale = () -> xScale

  my.yScale = () -> yScale

  my.widthScale = () -> widthScale

  my.heightScale = () -> heightScale


  # Get/set the width of the rendered histogram
  my.width = (_width) ->
    if not _width
      width
    else
      width = _width
      xScale.range [0, width]
      widthScale.range [0, width]
      my


  # Get/set the height of the rendered histogram
  my.height = (_height) ->
    if not _height
      height
    else
      height = _height
      heightScale.range [0, height]
      yScale.range [height, 0]
      my


  # Get/set an array of values to compute the histogram of
  my.data = (_data) ->
    if not _data
      data
    else
      data = _data
      bins = histogram data

      # Adjust the scales based on the number of bins and their ranges.
      minY = d3.min bins, (d) -> +d.y
      maxY = d3.max bins, (d) -> +d.y

      xScale.domain [bins[0].x, bins[bins.length - 1].x + bins[bins.length - 1].dx]
      yScale.domain [0, maxY]
      widthScale.domain [0, -bins[0].x + bins[bins.length - 1].x + bins[bins.length - 1].dx]
      heightScale.domain [0, maxY]

      # Calculate the percentile score of each bin
      sum = 0
      maxSum = data.length - bins[bins.length - 1].length
      for bin in bins
        bin.percentile = sum / maxSum
        sum += bin.length

      my

  my
