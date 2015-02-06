aws.litcoffee
===========================

*Note:* Any code blocks preceeded by a **Implementation** is actual code and not code examples.

**Implementation**	

	Q = require 'q'

	module.exports = (grunt, niteoaws) ->

In order to test the interaction with [`niteoaws`](https://github.com/NiteoSoftware/niteoaws), we need to be abstract the object.  Therefore we need to allow that abstraction to be passed into the module.

**Implementation**

		if not niteoaws?
			niteoaws = require 'niteoaws'

We clear up namespaces here.

**Implementation**

		if not grunt.niteo?
			grunt.niteo = { }
		if not grunt.niteo.aws?
			grunt.niteo.aws = { }

findResources
---------------------

You can use this task to search for resource metadata within your [AWS](http://aws.amazon.com/) infrastructure by tags.

- *region* (Required) The region to do the search in.
- *outputKey* (Required) The key to use when placing the resulting metadata into [`grunt.option()`](http://gruntjs.com/api/grunt.option).
- *provider* (Optional) The [niteoaws](https://github.com/NiteoSoftware/niteoaws) resource provider to use for searching.  If one is not defined, the default provider is used.
- *tags* (Optional) The tags that represent your query.
- *resolved* (Optional) A function that is called when the metadata is retreived from AWS.  The signature is: `function(metadata) { ... }`

```javascript

niteoaws = require('niteoaws')

grunt.initConfig({
	findResources:
		findAmiId:
			region: 'us-east-1',
			provider: niteoaws.ec2ImagesProvider,
			tags: [
				{ Key: 'os', Value: 'windows' }
			],
			outputKey: 'windowsAmiMetadata',
			resolved: function(metadata) {
				console.log metadata
			}
});
```

In the example above, we're using the ['niteoaws.ec2ImagesProvider'](https://github.com/NiteoSoftware/niteoaws) to search for images within the `us-east-1` region.  The tags we're searching with are grabbing all AMIs with a key of `os` and a value of `windows`.  Once the results are found, we print them to the screen via the `resolved` callback then we place the value into `grunt.option('windowsAmiMetadata')` so we can use the data later on the the run.

**Implementation**

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

		#	Here we register the task.
		grunt.registerMultiTask 'findResources', grunt.niteo.aws.findResources

getResource
---------------------

You can use this task to retreive a single resource from your [AWS](http://aws.amazon.com/) infrastructure.

- *region* (Required) The region to do the search in.
- *outputKey* (Required) The key to use when placing the resulting metadata into [`grunt.option()`](http://gruntjs.com/api/grunt.option).
- *id* (Required) The tags that represent your query.
- *provider* (Optional) The [niteoaws](https://github.com/NiteoSoftware/niteoaws) resource provider to use for searching.  If one is not defined, the default provider is used.
- *resolved* (Optional) A function that is called when the metadata is retreived from AWS.  The signature is: `function(metadata) { ... }`

```javascript

niteoaws = require('niteoaws')

grunt.initConfig({
	getResource:
		findAmiId:
			region: 'us-east-1',
			provider: niteoaws.ec2ImagesProvider,
			id: 'some ami id'
			outputKey: 'windowsAmiMetadata',
			resolved: function(metadata) {
				console.log metadata
			}
});
```

In the example above, we're using the ['niteoaws.ec2ImagesProvider'](https://github.com/NiteoSoftware/niteoaws) to retreive an AMI from the `us-east-1` region.  Once the result is found, we print it to the screen via the `resolved` callback. We then place the value into `grunt.option('windowsAmiMetadata')` so we can use the data later on the the run.

**Implementation**

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

		#	Here we register the task.
		grunt.registerMultiTask 'getResource', grunt.niteo.aws.getResource