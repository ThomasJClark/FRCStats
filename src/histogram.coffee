# histogram.coffee
#
# Renders an animated histogram of values that uses color to show percentile
# scores.
if not frcstats then frcstats = {}
frcstats.histogram = () ->
  _data = undefined
  _bins = undefined
  _width = 800
  _height = 800

  _histogram = d3.layout.histogram()
  _xScale = d3.scale.linear()
  _yScale = d3.scale.linear()
  _widthScale = d3.scale.linear()
  _heightScale = d3.scale.linear()

  # Map the midddle 50 percentile to the same yellow color, and transition to
  # red and green for extremely high and extremely low percentile scores.
  _colorScale  = d3.scale.linear()
    .domain [0, 0.25, 0.75, 1]
    .range ['#c0392b', '#f1c40f', '#f1c40f', '#27ae60']


  my = (container) ->
    bars = (container.selectAll '.bar').data _bins

    # If there are any bars not needed for the new dataset, transition them into
    # the bottom of the graph before removing them.
    bars.exit().transition()
      .duration 200
      .ease 'exp-in'
      .attr
        y: _height
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
          x: (d) -> _xScale d.x
          y: _height
          width: (d) -> (_widthScale d.dx) - 4
          height: 0
          rx: 3
        .style
          fill: (d) -> _colorScale d.percentile
          opacity: 0

    # Transition all bars to their correct position and size
    bars.transition()
      .duration 500
      .ease 'sin-in-out'
      .attr
        x: (d) -> _xScale d.x
        y: (d) -> _yScale d.y
        width: (d) -> (_widthScale d.dx) - 4
        height: (d) -> _heightScale d.y
      .style
        fill: (d) -> _colorScale d.percentile
        opacity: 1


  my.xScale = () -> _xScale

  my.yScale = () -> _yScale

  my.widthScale = () -> _widthScale

  my.heightScale = () -> _heightScale


  # Get/set the width of the rendered histogram
  my.width = (width) ->
    if not width
      _width
    else
      _width = width
      _xScale.range [0, _width]
      _widthScale.range [0, _width]
      my


  # Get/set the height of the rendered histogram
  my.height = (height) ->
    if not height
      _height
    else
      _height = height
      _heightScale.range [0, _height]
      _yScale.range [_height, 0]
      my


  # Get/set an array of values to compute the histogram of
  my.data = (data) ->
    if not data
      _data
    else
      _data = data
      _bins = _histogram data

      # Adjust the scales based on the number of bins and their ranges.
      minY = d3.min _bins, (d) -> +d.y
      maxY = d3.max _bins, (d) -> +d.y

      _xScale.domain [_bins[0].x, _bins[_bins.length - 1].x + _bins[_bins.length - 1].dx]
      _yScale.domain [0, maxY]
      _widthScale.domain [0, -_bins[0].x + _bins[_bins.length - 1].x + _bins[_bins.length - 1].dx]
      _heightScale.domain [0, maxY]

      # Calculate the percentile score of each bin
      sum = 0
      maxSum = _data.length - _bins[_bins.length - 1].length
      for bin in _bins
        bin.percentile = sum / maxSum
        sum += bin.length

      my

  my
