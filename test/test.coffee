path   = require 'path'
fs     = require 'fs'
should = require 'should'
Roots  = require 'roots'
RootsUtil = require 'roots-util'

_path  = path.join(__dirname, 'fixtures')
h = new RootsUtil.Helpers(base: _path)

# utils

compile_fixture = (fixture_name, done) ->
  @public = path.join(fixture_name, 'public')
  h.project.compile(Roots, fixture_name, ->
    done()
    return
  )

before (done) ->
  h.project.install_dependencies('*', done)

after ->
  h.project.remove_folders('**/public')

# tests

describe 'errors', ->

  it 'should throw an error when no manifest is defined', ->
    @path = path.join(_path, 'error')
    project = (=> new Roots(@path).compile()).should.throw()#("you must provide a manifest path or glob")

describe 'basics', ->

  before (done) -> compile_fixture.call(@, 'basic', done)

  it 'should compile a basic manifest', ->
    contents = new RegExp("""CACHE MANIFEST
      #[0-9]*
      css/libs/bootstrap.css
      css/master.css
      js/main.js
      index.html
      partials/partial.html""")

    p = path.join(@public, 'manifest.appcache')
    h.file.exists(p).should.be.ok
    h.file.contains_match(p, contents).should.be.ok
