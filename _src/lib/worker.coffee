## # Worker
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
	default: =>
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
		super

		@worker = new RSMQWorker @config.queuename,
			interval: @config.interval
			customExceedCheck: @_customExceedCheck

			redis: @config.client
			redisPrefix: @config.prefix
			host: @config.host
			port: @config.port
			options: @config.options

		@start()
		# wrap start method to only be active until the connection is established
		@start = @_waitUntil( @_start, "ready", @worker )
		return

	_start: =>
		@debug "START"
		return

	_customExceedCheck: ( msg )=>
		if msg.message is "check"
			return true
		return false

#export this class
module.exports = new RNWorker()