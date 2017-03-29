// gulpfile.js
var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var webserver = require('gulp-webserver');
var sourcemaps = require('gulp-sourcemaps');
var del = require('del');

var paths = {
  scripts: ['app/js/**/*.coffee', '!app/external/**/*.coffee']
};

// Webサーバ
gulp.task('webserver', function() {
  gulp.src('./')
    .pipe(webserver({
      livereload: true,
    }));
});

// JS を圧縮(min)
gulp.task('uglify', function(){
    console.log('--------- uglify task ----------');
    gulp.src('./node_modules/smoothie/smoothie.js')
        .pipe(uglify({preserveComments: 'some'}))
        .pipe(gulp.dest('./node_modules/smoothie/min'));
});

// スクリプトの結合と配置
gulp.task('scripts', function() {
  return gulp.src([
    './bower_components/angular/angular.min.js',
    './bower_components/onsenui/js/onsenui_all.min.js',
    './node_modules/smoothie/min/smoothie.js'
  ])
    .pipe(concat('all.js'))
    .pipe(gulp.dest('./javascripts/'));
});

// ファイルの変更を監視
gulp.task('watch', function() {
  // TODO: uglifyは上手く動作してるか不明。。。
  gulp.watch(paths.scripts, ['uglify','scripts']);
});

gulp.task('default', ['webserver', 'uglify', 'scripts', 'watch']);
