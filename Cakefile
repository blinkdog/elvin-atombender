# Cakefile
# Copyright 2014 Patrick Meade. All rights reserved.
#----------------------------------------------------------------------

{exec} = require 'child_process'

task 'dist', 'Create ElvinRL distribution tarball', ->
  console.log 'UnsupportedOperationException'

task 'rebuild', 'Rebuild ElvinRL', ->
  clean -> compile -> copy -> browser -> test()

browser = (next) ->
  exec 'node_modules/browserify/bin/cmd.js main.js > ElvinRL.js', (err, stdout, stderr) ->
    throw err if err
    next?()

clean = (next) ->
  exec 'rm -fR lib/*', (err, stdout, stderr) ->
    throw err if err
    next?()

compile = (next) ->
  exec 'node_modules/coffee-script/bin/coffee -o lib/ -c src/coffee', (err, stdout, stderr) ->
    throw err if err
    next?()

copy = (next) ->
  exec 'cp src/js/* lib/', (err, stdout, stderr) ->
    throw err if err
    next?()

test = (next) ->
  exec 'mocha --compilers coffee:coffee-script/register --recursive', (err, stdout, stderr) ->
    console.log stdout + stderr
    next?() if stderr.indexOf("AssertionError") < 0

#----------------------------------------------------------------------
# end of Cakefile

