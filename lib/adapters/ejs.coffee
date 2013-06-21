transformer = require('transformers')['ejs']
_ = require 'underscore'

exports.settings =
	file_type: 'ejs'
	target: 'html'

exports.compile = (file, options={}, cb) ->
	_.defaults(options,
		minify: global.options.compress
	)

	transformer.renderFile(file, options, cb)
	return
