	Q = require 'q'

	module.exports = (grunt, niteoaws) ->

		if not niteoaws?
			niteoaws = require 'niteoaws'

		if not grunt.niteo?
			grunt.niteo = { }
		if not grunt.niteo.aws?
			grunt.niteo.aws = { }

		grunt.niteo.aws.findResources = ->
			
			done = @async()

			Q.try =>

				if not @data.region?
					throw "You need to define a region."

				if not @data.outputKey?
					throw "You need to define an outputKey."

				provider = null
				tags = null

				if @data.provider?.factory?
					provider = @data.provider.factory @data.region
				else
					grunt.verbose.writeln "Using the base niteo resource provider."
					provider = new niteoaws @data.region

				if !(provider instanceof niteoaws.resourceProvider)
					throw "The provider provided is not an instance of niteoaws.resourceProvider."

				if @data.tags?
					tags = niteoaws.tag.createTags @data.tags
				else
					tags = [ ]

				grunt.verbose.writeln "Tags: #{JSON.stringify(tags, null, 4)}"

				return provider.findResources tags

			.then (result) =>
				if @data.resolved?
					@data.resolved result
				grunt.option(@data.outputKey, result)
			.catch (err) ->
				grunt.fail.fatal err
			.done =>
				done()

		grunt.registerMultiTask 'findResources', grunt.niteo.aws.findResources

		grunt.niteo.aws.getResource = ->

			done = @async()

			Q.try =>

				if not @data.region?
					throw "You need to define a region."

				if not @data.id?
					throw "You need to define the id of the resource."

				if not @data.outputKey?
					throw "You need to define an outputKey."

				provider = null

				if @data.provider? and @data.provider.factory?
					provider = @data.provider.factory @data.region
				else
					grunt.verbose.writeln "Using the base niteo resource provider."
					provider = new niteoaws @data.region

				if !(provider instanceof niteoaws.resourceProvider)
					throw "The provider provided is not an instance of niteoaws.resourceProvider."

				return provider.getResource @data.id

			.then (data) =>
				if @data.resolved?
					@data.resolved data
				grunt.option(@data.outputKey, data)
			.catch (err) ->
				grunt.fail.fatal err
			.finally ->
				done()

		grunt.registerMultiTask 'getResource', grunt.niteo.aws.getResource