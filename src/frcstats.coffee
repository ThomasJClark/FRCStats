$ ->
  svg = (d3.select '#histogramContainer').append 'svg'
    .attr
      viewBox: '0 0 800 400'
      width: '100%'
    .style
      overflow: 'visible'

  histogramGroup = (svg.append 'g').attr 'transform', 'translate(0, 0)'
  axisGroup = (svg.append 'g').attr 'transform', 'translate(0, 364)'

  histogram = frcstats.histogram()
    .width 800
    .height 360
  axis = d3.svg.axis()
  bubble = frcstats.infoBubble 'averageBubble'

  eventsList = []
  $('#event').select2
    placeholder: 'Select an Event'
    data: () -> { results: eventsList }


  # Updates all of the visual components (the histogram, axis, etc) with new
  # data.
  # @param {data} An array of numbers containing the data to show
  updateView = (data) ->
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
    mean = (Math.round 10 * d3.mean data) / 10
    bubble
      .x histogram.xScale() mean
      .y histogram.yScale() 0
      .text "average = #{ mean }"
    histogramGroup
      .call bubble


  # @param {dataUrl} The URL passed to d3.csv to load the match data from
  # @param {matchType} Which type of matches to include - either 'P', 'Q', or
  #    'E' (practice, qualification, elimination).
  # @param {field} The field type of interest, which is either 'Final', 'Foul',
  #   'Auto', or 'Teleop'.
  cache = {}
  setData = (dataUrl, matchType, field) ->
    get = (rows) ->
      cache[dataUrl] = rows

      redField = "red#{ field }"
      blueField = "blue#{ field }"
      event = ($ '#event').val() or 'All Events'
      scores = []
      events = d3.set ['All Events']

      for row in rows when row.type is matchType
        if event is row.event or event is 'All Events'
          scores.push row[redField]
          scores.push row[blueField]
        events.add row.event

      updateView scores

      # Set the event <select> to show all of the events for the currently
      # selected year.
      eventsList = ({ id: event, text: event } for event in events.values())

    rows = cache[dataUrl]
    if rows? then get rows else (d3.csv dataUrl).get (error, rows) -> get rows


  # Call setData() with parameters from the user interface fields
  onChange = () ->
    setData ($ '#year').val(),
            ($ 'input[name=matchType]:checked').val(),
            ($ '#field').val()

  # The list of events changes from year to year, so if a different year is
  # selected, remove the event filter before updating the data.
  ($ '#year').on 'change', () ->
    ($ '#event').select2 'val', 'All Events'
    onChange()

  # If any other field changes, immediately update the data.
  ($ '#field, input[name=matchType], #event').on 'change', onChange
  onChange()
