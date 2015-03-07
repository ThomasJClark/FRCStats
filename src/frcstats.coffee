$ ->
  svg = (d3.select '#histogramContainer').append 'svg'
    .attr
      viewBox: '0 0 800 400'
      width: '100%'
    .style
      overflow: 'visible'

  histogramGroup = (svg.append 'g').attr 'transform', 'translate(32, 0)'
  bubbleGroup = (svg.append 'g').attr 'transform', 'translate(32, 0)'
  axisGroup = (svg.append 'g').attr 'transform', 'translate(32, 364)'
  labelText = (svg.append 'text')
    .text 'Frequency'
    .style
      'dominant-baseline': 'hanging'
      'text-anchor': 'middle'
      'fill': '#34495E'
    .attr
      transform: 'translate(0, 200) rotate(-90)'

  histogram = frcstats.histogram()
    .width 800 - 32
    .height 360
  axis = d3.svg.axis()
  medianBubble = frcstats.infoBubble 'medianBubble'
  firstQuartileBubble = frcstats.infoBubble 'firstQuartileBubble'
  thirdQuartileBubble = frcstats.infoBubble 'thirdQuartileBubble'

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

    # Update the text bubbles that show the interquartile range
    data.sort (a, b) -> a - b
    median = Math.round d3.median data
    firstQuartile = Math.round d3.quantile data, 0.25
    thirdQuartile = Math.round d3.quantile data, 0.75

    medianBubble
      .x histogram.xScale() median
      .y histogram.yScale() 0
      .text "median = #{ median }pts"
    firstQuartileBubble
      .x histogram.xScale() firstQuartile
      .y histogram.yScale() 0
      .text "25th percentile = #{ firstQuartile }pts"
    thirdQuartileBubble
      .x histogram.xScale() thirdQuartile
      .y histogram.yScale() 0
      .text "75th percentile = #{ thirdQuartile }pts"

    bubbleGroup.call medianBubble
    bubbleGroup.call firstQuartileBubble
    bubbleGroup.call thirdQuartileBubble


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
    # Temporary workaround -
    # Disable practice matches for 2015, since TBA only reports
    # elimination and qualification matches.
    d3.select 'input[name=matchType][value=P]'
      .attr 'disabled', ($ '#year').val() is 'data/2015data.csv' or undefined

    setData ($ '#year').val(),
            ($ 'input[name=matchType]:checked').val(),
            ($ '#field').val()

  # The list of events changes from year to year, and the availabe match types
  # is also different for each year.  So, if the selected year changes, reset
  # those options before updating.
  ($ '#year').on 'change', () ->
    ($ '#event').select2 'val', 'All Events'
    ($ 'input[name=matchType][value=Q]').click()

    onChange()

  # If any other field changes, immediately update the data.
  ($ '#field, input[name=matchType], #event').on 'change', onChange
  onChange()
