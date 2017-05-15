# gulp がインストールされていない場合
$ npm install -g gulp

# git から本プロジェクトを取得した場合、以下のコマンドを実施する必要がある
$ bower install
$ npm install
$ gulp
※node_modules/smoothie/smoothie.js の監視や圧縮が上手く動作していないかも
※ブラウザより localhost:8000 でアクセスできる

参考サイト：
* npm + gulp + bower でビルド自動化
http://int128.hatenablog.com/entry/2014/07/02/004543
* package.jsonでnpmを管理する
http://alice345.hatenablog.com/entry/2014/01/14/152316


# --------------------------------------------------------------------------------
# 以下のサイトに従って環境構築してみた
# http://blog.asial.co.jp/1370
# ベースデモサイト：http://www.wecloud.net.cn/onsenUI/demo/carousel/index.html
# ベースデモソース：https://github.com/OnsenUI/OnsenUI/releases/tag/1.3.19
# --------------------------------------------------------------------------------

# プロジェクト（作業）ディレクトを作成する
$ mkdir onsenui_test


# onsenui パッケージをインストールするため bower をインストールする
$ npm install -g bower

# onsenui をインストールする
#  カレントディレクトリの bower_components にインストールされる
$ bower install onsenui --save

# Gulp を利用して実行環境に必要なファイル群を纏める（grunt と同様のも）
# 以下のqiita記事があるようにどうも gulp,gruntは流行ってない感じがする。。。
# [意訳]私がGulpとGruntを手放した理由
#  http://qiita.com/chuck0523/items/dafdbd19c12efd40e2de
$ cd onsenui_test
$ npm init
# 問い合わせ項目が複数あるがauthor,license ぐらいを以下のようにし後はデフォルトでいい
# デフォルトはそのまま何も入力せず改行すればいいっポイ。
author : 自分の名前
license: MIT

# npm init で package.json が生成される。そのに必要な gulp パッケージ群をインストールする
$ npm install -g gulp # グローバルにもインストール
$ npm install --save-dev gulp # ローカルにもインストール
$ npm install --save-dev gulp-changed # ここから下はGulpのプラグインです。
$ npm install --save-dev gulp-concat
$ npm install --save-dev gulp-coffee
$ npm install --save-dev gulp-uglify
$ npm install --save-dev gulp-sourcemaps
$ npm install --save-dev gulp-webserver
$ npm install --save-dev del

# gulp用設定ファイルを作成する
$ emacs gulpfile.js
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
 
// Webサーバの機能です
gulp.task('webserver', function() {
  gulp.src(&quot;./&quot;)
    .pipe(webserver({
      livereload: true,
    }));
});
 
// スクリプトの結合と配置を行っています
gulp.task('scripts', function() {
  return gulp.src([
      './bower_components/onsenui/build/js/angular/angular.min.js', // ここは最新のパスに変更する必要がある
      './bower_components/onsenui/build/js/onsenui_all.min.js'      // ここは最新のパスに変更する必要がある
  ])
    .pipe(concat('all.js'))
    .pipe(gulp.dest('./javascripts/'));
});
 
// ファイルの変更を監視しています（今回は使っていません）
gulp.task('watch', function() {
  gulp.watch(paths.scripts, ['scripts']);
});
 
gulp.task('default', ['webserver', 'scripts', 'watch']);


# webserver, scripts, watch 全部を動作させるには
$ gulp

# webserver だけ動作させるには
$ gulp webserver

# scripts だけ動作させるには
$ gulp scripts




