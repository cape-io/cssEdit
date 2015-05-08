argv = require('minimist')(process.argv.slice(2))
fs = require 'fs'

{site} = argv
unless site
  console.error 'You must have a valid site variable defined.'
  return

yaml = require 'js-yaml'
try
  sites = yaml.safeLoad(fs.readFileSync('./sites.yaml', 'utf8'));
catch e
  console.error(e)
  return

unless sites[site] and sites[site].url and sites[site].layout
  console.error site+' is not in sites.yaml or does not have url and layout defined.'
  console.log sites
  return
{url, layout, repo} = sites[site]

# Gulp Utils
gulp = require 'gulp'
less = require 'gulp-less'

# Development
browserSync = require 'browser-sync'

home = process.env['HOME']
require('./server')(url, layout, home, repo)

cssReload = ->
  browserSync.reload("*.css")

# Default gulp tasks watches files for changes
gulp.task "default", ['browser-sync'], ->
  gulp.watch "../#{layout}/styles/*.less", ["styles", cssReload]
  return

# For development.
gulp.task "browser-sync", ['styles'], ->
  browserSync
    proxy: "localhost:8081"
    logConnections: true
    injectChanges: true
  return

# Process LESS to CSS.
gulp.task 'styles', ->
  gulp.src(["../#{layout}/styles/app.less", "../#{layout}/styles/print.less", "../#{layout}/styles/iefix.less"])
    .pipe less()
    .pipe gulp.dest("../#{layout}/public")
