fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

task 'build', 'Build js/ from src/', ->
  coffee = spawn 'coffee', ['-c', '-j', 'js/frcstats.js', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-j', 'js/frcstats.js', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
