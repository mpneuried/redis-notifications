## # RNMailBuffer
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
#
# Main Module to init the notifications to redis
# 

# **npm modules**
moment = require( "moment-timezone" )

# [utils](./utils.coffee.html)
utils = require( "./utils" ) 

class RNMailBuffer extends require( "mpbasic" )()

	# ## defaults
	defaults: =>
		@extend super, 
			keyUserlist: "users_with_messages"
			keyMsgsPrefix: "msgs"
			# **options.prefix** *String* A general redis prefix
			prefix: "notifications"

	###	
	## constructor 
	###
	constructor: ( @main, options )->
		@ready = false
		super

		@write = @_waitUntil( @_write )

		@main.on "ready", @_start
		return

	_start: =>
		@redis = @main.getRedis()
		@ready = true
		@emit "ready"
		return

	_write: ( data, cb )=>
		console.log "WRITE 2 BUFFER", data
		@_getRedisTime ( err, sec, ms )=>
			if err
				cb( err )
				return

			data.created = sec

			_ud = data.userdata
			rM = []
			rM.push( [ "ZADD", @_getKey( @config.keyUserlist ), @_calcSendAt( ms, _ud.sendInterval, _ud.timezone ), _ud.id ] )
			rM.push( [ "LPUSH", @_getKey( @config.keyMsgsPrefix, _ud.id ), JSON.stringify( data )] )

			@redis.multi( rM ).exec ( err, results )=>
				if err
					cb( err )
					return
				cb()
				return
			return

		return

	_calcSendAt: ( now, interval, timezone="CET" )=>
		type = interval[0]
		# handle daily
		if type is "d"
			time = interval[1..]
			_m = moment( now ).tz( timezone )

			_next = moment( _m ).hour( parseInt( time[..1], 10 ) ).minute( parseInt( time[2..], 10 ) ).seconds(0).milliseconds(0)

			if _next <= _m
				_next.add( 1, "d" )
			    
			return _next.valueOf()

	###
	## _getKey
	
	`redisconnector._getKey( id, name )`
	
	Samll helper to prefix and get a redis key. 
	
	@param { String } name the key name
	@param { String } id The key 
	
	@return { String } Return The generated key 
	
	@api public
	###
	_getKey: ( name, id )=>
		_key = @main.getRedisNamespace() or ""
		if name?
			if _key[ _key.length-1 ] isnt ":"
				_key += ":"
			_key += "#{name}"
		if id?
			if _key[ _key.length-1 ] isnt ":"
				_key += ":"
			_key += "#{id}"
		return _key

	_getRedisTime: ( cb )=>
		@redis.time ( err, time )=>
			if err
				cb( err )
				return		
			
			[ s, ns ] = time
			ns = utils.lpad( ns, 6, "0" )[0..5]
			ms = Math.round( (parseInt( s + ns , 10 ) / 1000 ) )

			cb( null, parseInt( s, 10 ), ms ) 
			return
		return

#export this class
module.exports = RNMailBuffer