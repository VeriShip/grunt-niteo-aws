Q = require 'q'
should = require 'should'
S = require 'string'
niteo = require 'niteoaws'
sinon = require 'sinon'

grunt = null
thisPointer = null
providerFactoryStub = null
providerStub = null
resourceProvider = class
niteoClass = class extends resourceProvider
	constructor: ->
		niteoClass.instances.push this
		@findResources = sinon.stub().returns Q(true)
		@getResource = sinon.stub().returns Q(true)
niteoClass.resourceProvider = resourceProvider
niteoClass.tag = niteo.tag
niteoClass.instances = [ ]

getGruntStub = ->
	log:
		writeln: sinon.stub() 
		ok: sinon.stub()  #console.log
		error: sinon.stub() 
	verbose:
		writeln: sinon.stub() 
		ok: sinon.stub() 
	fail:
		warn: sinon.stub() 
		fatal: sinon.stub() 
	fatal: sinon.stub() 
	warn: sinon.stub() 
	_options: { }
	option: (key, value) ->
		if value?
			@_options[key] = value
		else
			@_options[key]
	registerTask: sinon.stub() 
	registerMultiTask: sinon.stub() 
	task:
		run: sinon.stub() 
		clearQueue: sinon.stub() 
	template:
		process: sinon.stub() 
	file:
		read: sinon.stub() 

getThisPointer = ->
	data: { }
	async: ->
		return ->

loadGrunt = (grunt) ->

	(require '../aws.js')(grunt, niteoClass)

beforeEachMethod = ->

	#	Setup the grunt stub.
	grunt = getGruntStub()
	loadGrunt(grunt)

	thisPointer = 
		data: { }
		async: ->
			return ->

	niteoClass.instances = [ ]

describe 'grunt', ->

	beforeEach beforeEachMethod
	
	describe 'niteo', ->

		it 'should define the grunt.niteo namespace when it does not already exist.', ->

			grunt.niteo.should.be.ok

		it 'should not overwrite the grunt.niteo namespace if it is already defined.', ->

			grunt = getGruntStub()
			grunt.niteo = 
				SomeOtherObject: { }

			loadGrunt(grunt)

			grunt.niteo.should.be.ok
			grunt.niteo.SomeOtherObject.should.be.ok

		describe 'aws', ->

			it 'should define the grunt.niteo.aws namespace when it does not already exist.', ->

				grunt.niteo.aws.should.be.ok

			it 'should not overwrite the grunt.niteo.aws namespace if it is already defined.', ->

				grunt = getGruntStub()
				grunt.niteo = 
					aws:
						SomeOtherObject: { }

				loadGrunt(grunt)

				grunt.niteo.aws.should.be.ok
				grunt.niteo.aws.SomeOtherObject.should.be.ok

			describe 'findResources', ->

				it 'should call grunt.fail.fatal if @data.region is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = ""

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.region is null.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = null
						thisPointer.data.outputKey = ""

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.outputKey is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = ""

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.outputKey is null.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = null
						thisPointer.data.region = ""

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should use the default provider if @data.provider is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should use the default provider if @data.provider is null.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.provider = null

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should use the default provider if @data.provider.factory is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.provider = { }

						grunt.niteo.aws.findResources.call(thisPointer)
						
				it 'should use the default provider if @data.provider.factory is null.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.provider = 
							factory: null

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call grunt.fail.fatal if the result from provider is not a niteo.resourceProvider object.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 0
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.provider = 
							factory: ->
								{ }

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call provider.findResources with the tags defined in @data.tags.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								niteoClass.instances[0].findResources.calledOnce.should.be.true
								niteoClass.instances[0].findResources.alwaysCalledWithExactly [
									{
										key: "Dummy Key"
										Value: "Dummy Value"
									},
									{
										key: "Dummy Key 1"
										Value: "Dummy Value 1"
									}
								]
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.tags = [
							{
								Key: "Dummy Key"
								Value: "Dummy Value"
							},
							{
								Key: "Dummy Key 1"
								Value: "Dummy Value 1"
							}
						]

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call grunt.fail.fatal if there is an exception.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true	
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.provider = 
							factory: ->
								throw 'Random Error'

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should call @data.resolve if it is a function and there is no error.', (done) ->

						thisPointer.async = -> 
							return ->
								thisPointer.data.resolved.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.resolved = sinon.stub()

						grunt.niteo.aws.findResources.call(thisPointer)

				it 'should place data result into grunt.option(@data.optionKey)', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.option("key").should.equal "Some Random Data"	
								done()

						niteoClassInstance = new niteoClass()
						niteoClassInstance.findResources.returns Q("Some Random Data")

						thisPointer.data.outputKey = "key"
						thisPointer.data.region = ""
						thisPointer.data.provider = 
							factory: ->
								niteoClassInstance

						grunt.niteo.aws.findResources.call(thisPointer)

			describe 'getResource', ->

				it 'should call grunt.fail.fatal if @data.region is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.id = ""
						thisPointer.data.outputKey = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.region is null.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = null
						thisPointer.data.id = ""
						thisPointer.data.outputKey = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.id is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = ""
						thisPointer.data.outputKey = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.id is null.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = ""
						thisPointer.data.id = null
						thisPointer.data.outputKey = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.outputKey is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = ""
						thisPointer.data.id = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if @data.outputKey is null.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.outputKey = null

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should use the default provider if @data.provider is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should use the default provider if @data.provider is null.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = null

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should use the default provider if @data.provider.factory is undefined.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = { }

						grunt.niteo.aws.getResource.call(thisPointer)
						
				it 'should use the default provider if @data.provider.factory is null.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = 
							factory: null

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if the result from provider is not a niteo.resourceProvider object.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 0
								grunt.fail.fatal.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = 
							factory: ->
								{ }

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call provider.getResource with the id defined in @data.id.', (done) ->

						thisPointer.async = -> 
							return ->
								niteoClass.instances.length.should.equal 1
								niteoClass.instances[0].getResource.calledOnce.should.be.true
								niteoClass.instances[0].getResource.alwaysCalledWithExactly "some id"
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = "some id"

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call grunt.fail.fatal if there is an exception.', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.fail.fatal.calledOnce.should.be.true	
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = 
							factory: ->
								throw 'Random Error'

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should call @data.resolve if it is a function and there is no error.', (done) ->

						thisPointer.async = -> 
							return ->
								thisPointer.data.resolved.calledOnce.should.be.true
								done()

						thisPointer.data.outputKey = ""
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.resolved = sinon.stub()

						grunt.niteo.aws.getResource.call(thisPointer)

				it 'should place data result into grunt.option(@data.optionKey)', (done) ->

						thisPointer.async = -> 
							return ->
								grunt.option("key").should.equal "Some Random Data"	
								done()

						niteoClassInstance = new niteoClass()
						niteoClassInstance.getResource.returns Q("Some Random Data")

						thisPointer.data.outputKey = "key"
						thisPointer.data.region = ""
						thisPointer.data.id = ""
						thisPointer.data.provider = 
							factory: ->
								niteoClassInstance

						grunt.niteo.aws.getResource.call(thisPointer)


