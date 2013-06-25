transformer = require('transformers')['coffee-script']
_ = require 'underscore'

exports.settings =
	file_type: 'coffee'
	target: 'js'

exports.compile = (file, options={}, cb) ->
	_.defaults(options,
		header: false
		bare: global.options.coffeescript_bare
		minify: global.options.compress
		filename: file.path
	)

	transformer.render(file.contents, options, cb)
	return
