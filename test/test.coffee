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
    contents = """CACHE MANIFEST
      css/libs/bootstrap.css
      css/master.css
      js/main.js
      index.html
      partials/partial.html"""

    p = path.join(@public, 'manifest.appcache')
    h.file.exists(p).should.be.ok
    h.file.contains(p, contents).should.be.ok

describe 'timestamp', ->

  before (done) -> compile_fixture.call(@, 'timestamp', done)

  it 'should compile a basic manifest with timestamp comment', ->
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

describe 'matchopts', ->

  before (done) -> compile_fixture.call(@, 'matchopts', done)

  it 'should compile a basic manifest with different match options', ->
    contents = """CACHE MANIFEST
      css/libs/bootstrap.css
      css/master.css
      js/main.js
      index.html"""

    p = path.join(@public, 'manifest.appcache')
    h.file.exists(p).should.be.ok
    h.file.contains(p, contents).should.be.ok


describe 'matchnonull', ->

  before (done) -> compile_fixture.call(@, 'matchnonull', done)

  it 'should compile a basic manifest leaving unmatched expressions alone', ->
    contents = """CACHE MANIFEST
      css/libs/bootstrap.css
      css/master.css
      js/main.js
      index.html
      partials/partial.html
      http://cdn.somecdn.com/a.png"""

    p = path.join(@public, 'manifest.appcache')
    h.file.exists(p).should.be.ok
    h.file.contains(p, contents).should.be.ok

describe 'complex', ->

  before (done) -> compile_fixture.call(@, 'complex', done)

  it 'should compile a complex manifest with all 3 sections', ->
    contents = """CACHE MANIFEST
      CACHE:
      css/libs/bootstrap.css
      css/master.css
      js/main.js
      index.html
      partials/partial.html
      NETWORK:
      online
      FALLBACK:
      *"""

    p = path.join(@public, 'manifest.appcache')
    h.file.exists(p).should.be.ok
    h.file.contains(p, contents).should.be.ok
