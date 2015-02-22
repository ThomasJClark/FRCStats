$ ->
  svg = (d3.select '#histogramContainer').append 'svg'
    .attr
      viewBox: '0 0 800 400'
      width: '100%'

  histogramGroup = (svg.append 'g').attr 'transform', 'translate(10, 0)'
  axisGroup = (svg.append 'g').attr 'transform', 'translate(10, 364)'

  histogram = frcstats.histogram()
    .width 780
    .height 360
  axis = d3.svg.axis()
  label = d3.select '#histogramLabel'
  bubble = frcstats.infoBubble 'averageBubble'


  # Updates all of the visual components (the histogram, axis, etc) with new
  # data.
  updateData = (data) ->
    # Update the histogram
    histogram.data data
    histogramGroup
      .call histogram

    # Update the axis
    axis.scale histogram.xScale()
    axisGroup.transition()
      .duration 500
      .ease 'sin-in-out'
      .call axis

    # Update the text bubble that shows what the average score is
    mean = Math.round d3.mean data
    bubble
      .x histogram.xScale() mean
      .y histogram.yScale() 0
      .text "average = #{ mean }"
    histogramGroup
      .call bubble


  # For now, just load all of the 2014 matches, and show only the final match
  # scores from qualification and elimination matches.
  #
  # TODO: actual filter the data based on the user input fields
  d3.csv 'data/2014data.csv'
    .get (error, rows) ->
      data = []
      for row in rows when row.type is 'Q' or row.type is 'E'
        data.push row.redFinal
        data.push row.blueFinal

      label.text 'Final Score'
      updateData data
