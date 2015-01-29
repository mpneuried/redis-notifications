# # RedisNotifications
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
#
# Main Module to init the notifications to redis
# 

# **internal modules**
# [RNWorker](./worker.coffee.html)
Worker = require( "./worker" ) 
# [RNTasks](./tasks.coffee.html)
Tasks = require( "./tasks" ) 
# [RNMailBuffer](./mailbuffer.coffee.html)
MailBuffer = require( "./mailbuffer" ) 

# [validateCreator](./schemas/creator.coffee.html)
validateCreator = require( "./schemas/creator" )
# [validateMultiCreate](./schemas/create-multi.coffee.html)
validateMultiCreate = require( "./schemas/create-multi" )
# [validateSingleCreate](./schemas/create-single.coffee.html)
validateSingleCreate = require( "./schemas/create-single" )

# ** configurations**
# **RequiredEvents** *String[]* A list of events that has to be binded to this module
RequiredEvents = [ "readUser", "getContent", "createNotification", "sendMail", "error" ]

class RedisNotifications extends require( "mpbasic" )()

	# ## defaults
	defaults: =>
		@extend super, 
			# **options.queuename** *String* The queuename to use for the worker
			queuename: "rnqueue"
			# **options.interval** *Number[]* An Array of increasing wait times in seconds
			interval: [ 0, 1, 5, 10 ]

			# **options.host** *String* Redis host name
			host: "localhost"
			# **options.port** *Number* Redis port
			port: 6379
			# **options.options** *Object* Redis options
			options: {}
			# **options.client** *RedisClient* Exsiting redis client instance
			client: null
			# **options.prefix** *String* A general redis prefix
			prefix: "notifications"

	###	
	## constructor 
	###
	constructor: ( options )->
		@ready = false
		super
		@worker = new Worker( @config )
		@mailbuffer = new MailBuffer( @, @config )
		@tasks = new Tasks( @, @config )

		# wrap start method to only be active until the connection is established
		@init = @_waitUntil( @_init, "ready", @worker )
		return

	_init: =>
		if @ready
			return

		@_checkListeners()

		@ready = true
		@emit "ready"
		return

	_checkListeners: =>
		for evnt in RequiredEvents when not @listeners( evnt ).length
			@_handleError( null, "EMISSINGLISTENER", evname: evnt )

		return

	createMulti: ( creator, options, cb = true )=>
		_verrC =  validateCreator( creator, cb )
		_verrM = validateMultiCreate( options, cb )
		if _verrC? or _verrM?
			@emit "error", ( _verrC or _verrM )
			return

		options.creator = creator

		@worker.send( "crNfcns", options )
		return

	create: ( creator, options, cb = true )=>
		_verrC =  validateCreator( creator, cb )
		_verrS = validateSingleCreate( options, cb )
		if _verrC? or _verrS?
			@emit "error", ( _verrC or _verrS )
			return

		options.creator = creator

		@worker.send( "crNfcn", options )
		return

	getWorker: =>
		return @worker

	getMailbuffer: =>
		return @mailbuffer

	getRsmqWorker: =>
		return @worker.getRsmqWorker()
		
	getRsmq: =>
		return @worker.getRsmq()

	getRedis: =>
		return @worker.getRedis()

	getRedisNamespace: =>
		return @worker.getRedisNamespace()


	ERRORS: =>
		return @extend {}, super, 
			"EMISSINGLISTENER": [ 404, "Missing Event Listener. Please make sure you've added a event listener to `<%= evname %>`" ]

#export this class
module.exports = RedisNotifications