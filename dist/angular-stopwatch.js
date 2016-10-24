(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var Stopwatch, stopwatchService,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Stopwatch = (function() {
  Stopwatch.default_delay = 0;

  function Stopwatch(arg) {
    var $timeout, delay;
    $timeout = arg.$timeout, delay = arg.delay;
    this.end_pause = bind(this.end_pause, this);
    this.do_pause = bind(this.do_pause, this);
    this.do_start = bind(this.do_start, this);
    this.tick = bind(this.tick, this);
    this.reset = bind(this.reset, this);
    this.pause = bind(this.pause, this);
    this.start = bind(this.start, this);
    this.elapsed_time = bind(this.elapsed_time, this);
    this.start_time = null;
    this.end_time = null;
    this.delay = delay;
    this.timer = null;
    this.is_running = false;
    this.milliseconds = 0;
    this.timeout = $timeout;
  }

  Stopwatch.prototype.elapsed_time = function() {
    if (this.timer) {
      return this.current_time() - this.start_time;
    } else {
      return this.end_time - this.start_time;
    }
  };

  Stopwatch.prototype.start = function() {
    if (this.timer == null) {
      this.do_start();
    }
    return this.timer;
  };

  Stopwatch.prototype.pause = function(pause_callback) {
    if (pause_callback == null) {
      pause_callback = function() {};
    }
    if (this.timer != null) {
      return this.do_pause(pause_callback);
    }
  };

  Stopwatch.prototype.reset = function() {
    var elapsed_time;
    elapsed_time = this.pause();
    this.start_time = null;
    this.end_time = null;
    this.milliseconds = 0;
    return elapsed_time;
  };

  Stopwatch.prototype.current_time = function() {
    return new Date;
  };

  Stopwatch.prototype.tick = function() {
    this.end_time = this.current_time();
    this.timer = this.timeout(this.tick, this.delay);
    this.is_running = true;
    return this.milliseconds = this.elapsed_time();
  };

  Stopwatch.prototype.do_start = function() {
    this.start_time = this.current_time() - (this.start_time != null ? this.elapsed_time() : 0);
    return this.tick();
  };

  Stopwatch.prototype.do_pause = function(pause_callback) {
    this.timer.then((function() {}), (function(_this) {
      return function() {
        return _this.end_pause(pause_callback);
      };
    })(this));
    return this.timeout.cancel(this.timer);
  };

  Stopwatch.prototype.end_pause = function(pause_callback) {
    this.end_time = this.current_time();
    this.timer = null;
    this.is_running = false;
    this.milliseconds = this.elapsed_time();
    return pause_callback(this.milliseconds);
  };

  return Stopwatch;

})();

stopwatchService = function($timeout) {
  var get_instance;
  get_instance = function(arg) {
    var delay, ref, timeout;
    ref = arg != null ? arg : {
      timeout: $timeout,
      delay: Stopwatch.default_delay
    }, timeout = ref.timeout, delay = ref.delay;
    return new Stopwatch({
      $timeout: timeout,
      delay: delay
    });
  };
  return this._ = {
    default_delay: Stopwatch.default_delay,
    get_instance: get_instance,
    getInstance: function() {
      return get_instance;
    }
  };
};

angular.module('ng-stopwatch', []).factory('stopwatchService', ['$timeout', stopwatchService]);

module.exports = {
  Stopwatch: Stopwatch
};

},{}]},{},[1]);
