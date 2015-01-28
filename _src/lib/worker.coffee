## # RNWorker
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
#
# Main Module to init the notifications to redis
# 

# **npm modules**
# [NPM:rsmq-worker](https://cdn.rawgit.com/mpneuried/rsmq-worker/master/_docs/README.md.html)
RSMQWorker = require( "rsmq-worker" ) 

class RNWorker extends require( "mpbasic" )()

	# ## defaults
	defaults: =>
		@extend super, 

			# **options.queuename** *String* The queuename to use for the worker
			queuename: "notifications"
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
		@worker = new RSMQWorker @config.queuename,
			interval: @config.interval
			customExceedCheck: @_customExceedCheck

			redis: @config.client
			redisPrefix: @config.prefix
			host: @config.host
			port: @config.port
			options: @config.options

		# wrap start method to only be active until the connection is established
		@worker.on "ready", @_start

		@worker.on "message", @_onMessage

		@worker.on "timeout", ( msg )=>
			@warning "task timeout", msg
			return

		@worker.start()
		return

	_start: =>
		@ready = true
		@emit "ready"
		return

	_customExceedCheck: ( msg )=>
		if msg.message is "check"
			return true
		return false

	_doCheck: ( next )=>
		# TODO implement teh check method
		next()
		return 

	send: ( type, msg, cb )=>
		@debug "send", type, msg
		@worker.send( JSON.stringify( mt: type, md: msg ), cb )
		return

	_onMessage: ( msg, next, id )=>
		@debug "_onMessage", msg

		if msg is "check"
			@_doCheck( next )
			return

		# dispatch the message
		_data = JSON.parse( msg )
		try
			@emit _data.mt, _data.md, next, id
		catch _err
			@error "execute message", _err, _err.stack

			next( false )
			return

		return

	getRsmq: =>
		return @worker._getRsmq()

	getRedisNamespace: =>
		return @getRsmq().redisns

	getRedis: =>
		return @getRsmq().redis


#export this class
module.exports = RNWorker