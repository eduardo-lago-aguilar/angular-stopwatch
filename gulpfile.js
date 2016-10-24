'use strict'

var gulp = require('gulp');
var coffeeify = require('gulp-coffeeify');
var concat = require('gulp-concat');

gulp.task('coffeeify', function() {
    gulp.src('src/**/*.coffee')
        .pipe(coffeeify())
        .pipe(concat('angular-stopwatch.js'))
        .pipe(gulp.dest('dist'));
});

gulp.task('build', [
   'coffeeify'
]);
