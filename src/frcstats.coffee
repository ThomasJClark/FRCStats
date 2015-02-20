getRandomData = () ->
  sampleSize = 10 * Math.pow 10000, Math.random()
  pdf = d3.random.bates 10
  (pdf() for _ in d3.range sampleSize)


$ ->
  svg = (d3.select '#histogramContainer').append 'svg'
    .attr 'viewBox', '0 0 800 400'

  barGroup = svg.append 'g'

  axisGroup = svg.append 'g'
    .attr 'transform', 'translate(0, 364)'

  label = (d3.select '#histogramLabel')
    .text 'Thing'

  fsh = frcstats.histogram()
    .width 800
    .height 360
    .data getRandomData()

  axis = d3.svg.axis()
    .tickPadding 8

  update = () ->
    fsh.data getRandomData()

    axis.scale fsh.xScale()
    barGroup.call fsh
    axisGroup.transition()
      .duration 500
      .ease 'sin-in-out'
      .call axis

  update()
  window.setInterval update, 1000
