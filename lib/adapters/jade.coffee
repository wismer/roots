transformer = require('transformers')['jade']
_ = require 'underscore'

exports.settings =
	file_type: 'jade'
	target: 'html'

exports.compile = (file, options={}, cb) ->
	_.defaults(options,
		minify: global.options.compress
	)

	transformer.renderFile(file, options, cb)
	return
