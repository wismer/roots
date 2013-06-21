path = require('path')
fs = require('fs')
shell = require('shelljs')
EventEmitter = require('events').EventEmitter
adapters = require('./adapters')
compress = require('./utils/compressor')
output_path = require('./utils/output_path')
_ = require('underscore')
file_helper = require('./utils/file_helper')

class Compiler extends EventEmitter
	###*
	 * either 'build' or 'dev'
	 * @type {String}
	 * @public
	###
	mode: 'build'

	###*
	 * Emits an event to notify listeners that everything is compiled
	 * @return {undefined}
	 * @fires Compiler#finished
	###
	finish: ->
		@emit 'finished'

	###*
	 * [compile description]
	 * @param {[type]} file [description]
	 * @param {Compiler~doneCallback} cb
	 * @return {[type]} [description]
	###
	compile: (file, cb) ->
		matching_adapters = get_adapters_by_extension(
			path.basename(file).split('.').slice(1)
		)
		fh = file_helper(file)
		matching_adapters.forEach (adapter, i) =>
			intermediate = (matching_adapters.length - i - 1 > 0)
			
			# front matter stays intact until the last compile pass
			unless intermediate
				fh.parse_dynamic_content()

			console.log adapter
			adapter.compile fh.path, fh.locals(), (err, compiled) ->
				if err then return @emit 'error', err

				pass_through = ->
					fh.contents = compiled

				write = (content) ->
					console.log 'writing to ' + content
					fh.write content
					cb()

				write_file = ->
					if fh.layout_path
						fh.set_layout() # set up the layout if it's compiling to html
						compile_into_layout fh, adapter, compiled, (compiled_with_layout) ->
							write compiled_with_layout
					else
						write(compiled)

				if intermediate
					return pass_through()
				else
					return write_file()

	###*
	 * [copy description]
	 * @param {[type]} file [description]
	 * @param {Compiler~doneCallback} cb
	 * @return {[type]} [description]
	 * @uses Compiler.mode
	###
	copy: (file, cb) ->
		# TODO: Run the file copy operations as async (ncp)
		destination = output_path(file)
		extname = path.extname(file).slice(1)
		types = ['html', 'css', 'js']
		if types.indexOf(extname) > 0 && global.options.compress
			write_content = fs.readFileSync(file, 'utf8')
			write_content = compress(write_content, extname)
			fs.writeFileSync destination, write_content
		else
			if @mode is 'dev'
				# symlink in development mode
				fs.existsSync(destination) or fs.symlinkSync(file, destination)
			else
				shell.cp '-f', file, destination
		options.debug.log "copied #{file.replace(process.cwd(), '')}"
		cb()

###*
 * Called when the function that the callback was passed to is done
 * @callback Compiler~doneCallback
###

module.exports = Compiler

# @api private

plugin_path = path.join(process.cwd() + '/plugins')
plugins = fs.existsSync(plugin_path) and shell.ls(plugin_path)

###*
 * [get_adapters_by_extension description]
 * @param {[type]} extensions [description]
 * @return {[type]} [description]
 * @private
###
get_adapters_by_extension = (extensions) ->
	matching_adapters = []
	extensions.reverse().forEach (ext) =>
		for key of adapters
			matching_adapters.push adapters[key]  if adapters[key].settings.file_type is ext

	matching_adapters

###*
 * [compile_into_layout description]
 * @param {[type]} fh [description]
 * @param {[type]} adapter [description]
 * @param {[type]} compiled [description]
 * @param {Function} cb [description]
 * @return {[type]} [description]
###
compile_into_layout = (fh, adapter, compiled, cb) ->
	adapter.compile fh.layout_path, fh.locals(content: compiled), (err, layout) ->
		if err then return @emit('error', err)
		cb layout
