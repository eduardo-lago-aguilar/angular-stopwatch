'use strict'

describe 'Stopwatch', ->
  beforeEach module 'ng-stopwatch'

  beforeEach inject (stopwatchService, $timeout) =>
    @sws = stopwatchService
    @timeout = $timeout

  describe '#new', =>
    it 'initializes the timers', =>
      stopwatch = @sws.get_instance timeout: (->), delay: 1500
      expect(stopwatch.start_time).toBeNull()
      expect(stopwatch.end_time).toBeNull()
      expect(stopwatch.delay).toEqual 1500
      expect(stopwatch.timeout).toBeDefined()
      expect(stopwatch.timer).toBeNull()
      expect(stopwatch.is_running).toBe no
      expect(stopwatch.milliseconds).toBe 0

    it 'has a default @delay', =>
      stopwatch = @sws.get_instance()
      expect(stopwatch.delay).toEqual @sws.default_delay

  describe '#elapsed_time', =>
    it 'returns the total elapsed time if stopped', =>
      stopwatch = @sws.get_instance()

      stopwatch.timer = null
      stopwatch.is_running = no
      stopwatch.end_time = 2000
      stopwatch.start_time = 500

      expect(stopwatch.elapsed_time()).toEqual 1500

    it 'returns the current elapsed time if started', =>
      stopwatch = @sws.get_instance()

      stopwatch.timer = {}
      stopwatch.is_running = yes
      spyOn(stopwatch, 'current_time').and.returnValue 3000
      stopwatch.start_time = 500

      expect(stopwatch.elapsed_time()).toEqual 2500

  describe '#tick', =>
    it 'tick', =>
      my_timeout = (tick, delay) =>
        expect(tick).toBe stopwatch.tick
        expect(delay).toBe stopwatch.delay
        'some timer'

      stopwatch = @sws.get_instance timeout: my_timeout

      spyOn(stopwatch, 'current_time').and.returnValue 45678
      spyOn(stopwatch, 'elapsed_time').and.returnValue 2000
      stopwatch.tick()
      expect(stopwatch.end_time).toEqual 45678
      expect(stopwatch.timer).toEqual 'some timer'
      expect(stopwatch.is_running).toEqual yes
      expect(stopwatch.milliseconds).toEqual 2000

  describe '#start', =>
    it 'returns immediately if already started', =>
      stopwatch = @sws.get_instance()
      stopwatch.timer = {}
      stopwatch.is_running = yes
      spyOn(stopwatch, 'do_start').and.callFake -> throw new Error('you should not call this function')
      expect(stopwatch.start()).toBe stopwatch.timer

    it 'calls #do_start if not started yet', =>
      stopwatch = @sws.get_instance()
      stopwatch.timer = null
      stopwatch.is_running = no
      spyOn(stopwatch, 'do_start').and.callFake ->
        stopwatch.timer = {}
        undefined

      expect(stopwatch.start()).toBe stopwatch.timer
      expect(stopwatch.do_start).toHaveBeenCalled()

  describe '#do_start', =>
    beforeEach =>
      @stopwatch = @sws.get_instance()
      spyOn(@stopwatch, 'tick').and.stub()

    afterEach =>
      expect(@stopwatch.tick).toHaveBeenCalled()

    it ' if we are starting for the first time. set the time to the current time', =>
      @stopwatch.start_time = null
      spyOn(@stopwatch, 'current_time').and.returnValue 4567
      @stopwatch.do_start()
      expect(@stopwatch.start_time).toEqual 4567

    it 'if we are paused, then we need to offset the date by the previously elapsed time.', =>
      @stopwatch.start_time = 123
      spyOn(@stopwatch, 'current_time').and.returnValue 500
      spyOn(@stopwatch, 'elapsed_time').and.returnValue 200
      @stopwatch.do_start()
      expect(@stopwatch.start_time).toEqual 300

  describe '#pause', =>
    it 'returns immediately if not running', =>
      stopwatch = @sws.get_instance()
      stopwatch.timer = null
      stopwatch.is_running = no
      spyOn(stopwatch, 'do_pause').and.callFake -> throw new Error('you should not call this function')
      stopwatch.pause()

    it 'calls #do_pause if running', =>
      stopwatch = @sws.get_instance()
      stopwatch.timer = {}
      stopwatch.is_running = yes
      spyOn(stopwatch, 'do_pause').and.stub()
      pause_callback = ->
      stopwatch.pause pause_callback
      expect(stopwatch.do_pause).toHaveBeenCalledWith pause_callback

  describe '#do_pause', =>
    it 'does the pause', =>
      my_timeout =
        cancel: (running)->
          expect(running).toBe stopwatch.timer

      stopwatch = @sws.get_instance timeout: my_timeout
      stopwatch.timer =
        then: ->

      stopwatch.is_running = yes
      spyOn(my_timeout, 'cancel').and.callThrough()
      spyOn(stopwatch.timer, 'then').and.stub()

      pause_callback = ->
      stopwatch.do_pause pause_callback

      expect(my_timeout.cancel).toHaveBeenCalled()
      #TODO: use a better matcher for this!
      expect(stopwatch.timer.then).toHaveBeenCalledWith jasmine.any(Function), jasmine.any(Function)

  describe '#end_pause', =>
    it 'ends the pause', =>
      stopwatch = @sws.get_instance()

      spyOn(stopwatch, 'current_time').and.returnValue 12345
      spyOn(stopwatch, 'elapsed_time').and.returnValue 6789

      ctrl =
        pause_callback: ->

      spyOn(ctrl, 'pause_callback').and.stub()

      stopwatch.end_pause ctrl.pause_callback

      expect(stopwatch.end_time).toEqual 12345
      expect(stopwatch.timer).toBeNull()
      expect(stopwatch.is_running).toBe no
      expect(stopwatch.milliseconds).toBe 6789
      expect(ctrl.pause_callback).toHaveBeenCalledWith 6789

  describe '#reset', =>
    it 'resets and returns the #pause result', =>
      stopwatch = @sws.get_instance()
      stopwatch.start_time = {}
      stopwatch.end_time = {}
      stopwatch.milliseconds = 3000
      spyOn(stopwatch, 'pause').and.returnValue 2468
      expect(stopwatch.reset()).toEqual 2468
      expect(stopwatch.pause).toHaveBeenCalled()
      expect(stopwatch.start_time).toBeNull()
      expect(stopwatch.end_time).toBeNull()
      expect(stopwatch.milliseconds).toBe 0

  describe '#current_time', =>
    it 'returns a new date', =>
      date = {}
      spyOn(window, 'Date').and.returnValue date
      stopwatch = @sws.get_instance()
      expect(stopwatch.current_time()).toBe date
