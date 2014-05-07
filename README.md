Roots Cache Manifest
======================

[![npm](https://badge.fury.io/js/roots-cache-manifest.png)](http://badge.fury.io/js/roots-cache-manifest) [![tests](https://travis-ci.org/dapetcu21/roots-cache-manifest.png?branch=master)](https://travis-ci.org/dapetcu21/roots-cache-manifest) [![dependencies](https://david-dm.org/dapetcu21/roots-cache-manifest.png?theme=shields.io)](https://david-dm.org/dapetcu21/roots-cache-manifest)

Roots cache manifest is a [roots](https://github.com/jenius/roots) plugin that allows you to use wildcard globs in your cache manifest's explicit entries.

### Installation

- make sure you are in your roots project directory
- `npm install roots-cache-manifest --save`
- modify your `app.coffee` file to include the extension, as such

  ```coffee
  CacheManifest = require('roots-cache-manifest')

  module.exports =
    extensions: [CacheManifest(
      manifest: "assets/manifest.appcache", # required
    )]

    # everything else...
  ```

### Usage

This extension will go through all the files in your output directory and add them to your cache manifest according to specified globs. Paths will be taken as relative to the directory of the final manifest output.

For example, let's say we have this output directory:
```
|-- outside.css
|-- index.html
|-- manifest.appcache
|-- partials
|   `-- partial.html
|-- css
|   |-- libs
|   |   `-- bootstrap.css
|   `-- master.css
`-- js
    |-- libs
    |   `-- bootstrap.js
    `-- main.js
```

The extension will take this manifest.appcache:
```
css/**/*.css
js/*.js
*.html
```

And compile it into this:
```
CACHE MANIFEST
#<timestamp>
css/libs/bootstrap.css
css/master.css
js/main.js
index.html
partials/partial.html
```


### Options

##### manifest
The path to your input cache.manifest or a [minimatch](https://github.com/isaacs/minimatch)-compatible string matching one or more files to be compiled. This is mandatory.

##### matchopts
Options for [minimatch](https://github.com/isaacs/minimatch). By default, `matchBase` and `nonull` are enabled.

##### timestamp
Adds a comment with the current timestamp (so the appcache will be refreshed)

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
