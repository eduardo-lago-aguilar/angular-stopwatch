'use strict'

class Stopwatch
  @default_delay = 1000

  constructor: ({$timeout, delay}) ->
    @start_time = null
    @end_time = null
    @delay = delay
    @timer = null
    @is_running = no
    @milliseconds = 0
    @timeout = $timeout

  elapsed_time: =>
    if @timer
      @current_time() - @start_time
    else
      @end_time - @start_time

  start: =>
    @do_start() unless @timer?
    @timer

  pause: (pause_callback = ->)=>
    @do_pause pause_callback if @timer?

  reset: =>
    elapsed_time = @pause()
    @start_time = null
    @end_time = null
    @milliseconds = 0
    elapsed_time

# private
  current_time: ->
    new Date

  tick: =>
    @end_time = @current_time()
    @timer = @timeout @tick, @delay
    @is_running = yes
    @milliseconds = @elapsed_time()

  do_start: =>
    @start_time = @current_time() - if @start_time? then @elapsed_time() else 0
    @tick()

  do_pause: (pause_callback) =>
    @timer.then (->), => @end_pause pause_callback
    @timeout.cancel @timer

  end_pause: (pause_callback) =>
    @end_time = @current_time()
    @timer = null
    @is_running = no
    @milliseconds = @elapsed_time()
    pause_callback @milliseconds

stopwatchService = ($timeout) ->
  get_instance = ({timeout, delay}={timeout: $timeout, delay: Stopwatch.default_delay}) -> new Stopwatch $timeout: timeout, delay: delay

  @_ =
    default_delay: Stopwatch.default_delay
    get_instance: get_instance
    getInstance: -> get_instance

angular.module('ng-stopwatch', []).factory 'stopwatchService', ['$timeout', stopwatchService]

module.exports =
  Stopwatch: Stopwatch
