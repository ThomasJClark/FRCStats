getRandomData = () ->
  sampleSize = 10 * Math.pow 10000, Math.random()
  pdf = d3.random.bates 10
  (pdf() for _ in d3.range sampleSize)


$ ->
  svg = (d3.select '#svgContainer').append 'svg'
    .attr
      viewBox: '0 0 800 450'

  fsh = frcstats.histogram()
    .width 800
    .height 400
    .data getRandomData()

  fsh svg
  window.setInterval (() -> (fsh.data getRandomData()) svg), 1000
