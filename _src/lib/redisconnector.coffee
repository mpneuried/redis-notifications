# # RedisConnector
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
#
# Basic module to handle a redis connection.
# Just call `@connect()` within the constructor to connect savely to redis
#
# ### Class-Vars
# 
# * **redis** *RedisClient* the generated redis client instance
# * **connected** *Boolean* Flag to mark if the module is currently connected to redis

# ### Events
# 
# * **connected**: emitted on redis connect.
# * **disconnect**: emitted on redis disconnect.
# * **redis:error**: emitted on redis error.
#   * **err** *Error* The passed error object

# **npm modules**
redis = require( "redis" )

class RedisConnector extends require( "mpbasic" )()

	# ## defaults
	defaults: =>
		return @extend super, 
			# **redis.host** *String* Redis host name
			host: "localhost"
			# **redis.port** *Number* Redis port
			port: 6379
			# **redis.options** *Object* Redis options
			options: {}
			# **redis.client** *RedisClient* Exsiting redis client instance
			client: null
			# **redis.prefix** *String* A general redis prefix
			prefix: ""


	###	
	## constructor 
	###
	constructor: ->
		super
		# define the `connected` flag
		@connected = false
		return

	###
	## connect
	
	`redisconnector.connect()`
	
	Connect to redis and add the renerated client th `@redis`
	
	@return { RedisClient } Return The Redis Client. Eventually not conneted yet. 
	
	@api public
	###
	connect: =>
		if @config.client?.constructor?.name is "RedisClient"
			# try to use the passed client
			@redis = @config.client
		else
			# generate a new client
			try
				redis = require("redis")
			catch _err
				@error( "you have to load redis via `npm install redis hiredis`" )
				return
			@redis = redis.createClient( @config.port or 6379, @config.host or "127.0.0.1", @config.options or {} )

		# check if this redis instance is allready conencted
		@connected = @redis.connected or false

		# listen to the redis connect event and set the class vars
		@redis.on "connect", =>
			@connected = true
			@debug "connected"
			@emit( "connected" )
			return

		# listen to redis errors
		@redis.on "error", ( err )=>
			# if it's a connection error emit the disconnect
			if err.message.indexOf( "ECONNREFUSED" )
				@connected = false
				@emit( "disconnect" )
			else
				@error( "Redis ERROR", err )
				@emit( "redis:error", err )
			return

		return @client

	###
	## _getKey
	
	`redisconnector._getKey( id, name )`
	
	Samll helper to prefix and get a redis key. 
	
	@param { String } id The key 
	@param { String } name the class name
	
	@return { String } Return The generated key 
	
	@api public
	###
	_getKey: ( id, name = @name )=>
		_key = @config.prefix or ""
		if name?
			_key += ":#{name}"
		if id?
			_key += ":#{id}"
		return _key

#export this class
module.exports = RedisConnector