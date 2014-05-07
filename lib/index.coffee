path      = require 'path'
fs        = require 'fs'
_         = require 'lodash'
W         = require 'when'
nodefn    = require 'when/node'
minimatch = require 'minimatch'
RootsUtil = require 'roots-util'

module.exports = (opts) ->
  class CacheManifestCompile
    constructor: (roots) ->
      @util = new RootsUtil(roots)
      @roots = roots

      opts = _.defaults opts or {},
        timestamp: true

      if !opts.manifest? then throw new Error('you must provide a manifest path or glob')
      @pattern = opts.manifest

      @matchopts = _.defaults opts.matchopts or {},
        matchBase: true
        nonull: true

      {@timestamp} = opts

      @category = "cache-manifest"
      @manifests = {}

      # hijacking config.after since roots doesn't
      # give me any mechanism for doing something
      # at the end of the compile
      oldAfter = roots.config.after
      roots.config.after = (done, err) =>
        done_hook.call(@)
          .then(=>
            #restoring config.after
            @roots.config.after = oldAfter
            hook_method.call(@, oldAfter).then(done, err)
          )

    fs: ->
      extract: true
      ordered: false
      detect: (f) => minimatch(f.relative, @pattern)

    compile_hooks: ->
      write: write_hook.bind(@)
      after_file: after_hook.bind(@)

    # @api private
    
    # stolen from roots' compile.coffee
    hook_method = (hook) ->
      if not hook then return W.resolve()

      if Array.isArray(hook)
        hooks = hook.map((h) => nodefn.call(h.bind(@roots)))
      else if typeof hook == 'function'
        hooks = [nodefn.call(hook.bind(@roots))]
      else
        return W.reject('before hook should be a function or array')

      W.all(hooks)

    # parse the manifest
    after_hook = (ctx) ->
      out = ctx.roots.config.out(ctx.file, '')
      lines = ctx.content.toString().split('\n')
      manifest =
        explicit: []
        network: []
        fallback: []

      @manifests[out] = manifest

      states =
        "CACHE:": manifest.explicit
        "CACHE MANIFEST": manifest.explicit
        "NETWORK:": manifest.network
        "FALLBACK:": manifest.fallback

      currentState = manifest.explicit

      for line in ctx.content.toString().split('\n')
        line = line.trim()
        if line == "" or line[0] == "#"
          continue
        newState = states[line]
        if newState
          currentState = newState
        else
          currentState.push line

    write_hook = (ctx) ->
      return false

    walk = (dir) ->
      walk_ = (dir, done, error) ->
        results = []
        fs.readdir dir, (err, list) ->
          if (err)
            return error(err)
          i = 0
          do next = ->
            file = list[i++]
            if (!file)
              return done(results)
            file = dir + '/' + file
            fs.stat file, (err, stat) ->
              if (stat && stat.isDirectory())
                walk_ file, (res) ->
                  results = results.concat(res)
                  next()
                , error
              else
                results.push file
                next()
      W.promise((resolve, reject) ->
        walk_(dir, resolve, reject)
        return null
      )

    done_hook = ->
      walk(@roots.config.output_path()).then (paths) =>

        timestamp = "#" + new Date().getTime().toString()
        promises = []
        for out_path, manifest of @manifests
          rel_paths = _.map paths,
            path.relative.bind path,
              path.dirname out_path

          explicit = []

          for pattern in manifest.explicit
            explicit = explicit.concat rel_paths.filter(
              minimatch.filter(pattern, @matchopts))

          lines = ["CACHE MANIFEST"]
          if @timestamp
            lines.push timestamp

          if manifest.network.length or manifest.fallback.length
            lines.push "CACHE:"
          for line in explicit
            lines.push line

          if manifest.network.length
            lines.push "NETWORK:"
            for line in manifest.network
              lines.push line

          if manifest.fallback.length
            lines.push "NETWORK:"
            for line in manifest.fallback
              lines.push line

          contents = lines.join('\n')
          promises.push nodefn.call(fs.writeFile, out_path, contents,
            encoding: 'utf-8'
          )

        W.all(promises)
