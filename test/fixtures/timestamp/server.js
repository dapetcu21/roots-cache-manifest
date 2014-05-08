var Roots = require('roots');

proj = new Roots(__dirname);
proj.on('error', console.log.bind(console))
    .on('done', function() {
        console.log('Compilation done. Starting server')
    });
console.log('Compiling project');
proj.compile();
