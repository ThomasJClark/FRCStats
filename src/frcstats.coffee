getRandomData = () ->
  sampleSize = Math.pow 1000, Math.random()
  pdf = d3.random.bates 10
  (100 * pdf() for _ in d3.range sampleSize)


$ ->
  svg = (d3.select '#histogramContainer').append 'svg'
    .attr
      viewBox: '0 0 800 400'
      width: '100%'

  barGroup = svg.append 'g'

  axisGroup = svg.append 'g'
    .attr 'transform', 'translate(0, 364)'

  label = (d3.select '#histogramLabel')
    .text 'Thing'

  averageBubble = frcstats.infoBubble 'averageBubble'
  testBubble = frcstats.infoBubble 'testBox'

  fsh = frcstats.histogram()
    .width 800
    .height 360
    .data getRandomData()

  axis = d3.svg.axis()
    .tickPadding 8

  update = () ->
    randomData = getRandomData()

    fsh.data randomData
    axis.scale fsh.xScale()
    barGroup.call fsh
    axisGroup.transition()
      .duration 500
      .ease 'sin-in-out'
      .call axis

    mean = Math.round (randomData.reduce (a, b) -> a + b) / randomData.length

    x = fsh.xScale() mean
    averageBubble
      .x x
      .y fsh.yScale() 0
      .text "average = #{mean}"
    svg.call averageBubble

    testBubble
      .x fsh.xScale() 40
      .y fsh.yScale() 0
      .text 'lol'
    svg.call testBubble

  update()
  window.setInterval update, 1000
