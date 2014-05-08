CacheManifest = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]

  extensions: [CacheManifest
    manifest: "assets/manifest.appcache"
    timestamp: false
  ]
