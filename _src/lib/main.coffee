# # RedisNotifications

# ### extends [RedisConnector](./redisconnector.coffee.html)

#
# ### Exports: *Class*
#
# Main Module to init the heartbeat to redis
# 

# **internal modules**
# [Redisconnector](./redisconnector.coffee.html)
Redisconnector = require( "./redisconnector" ) 

class RedisNotifications extends Redisconnector

	# ## defaults
	default: =>
		@extend super, 
			# **RedisNotifications.foo** *Number* This is a example default option
			foo: 23
			# **RedisNotifications.bar** *String* This is a example default option
			bar: "Buzz"

	###	
	## constructor 
	###
	constructor: ( options )->
		super
		
		# wrap start method to only be active until the connection is established
		@start = @_waitUntil( @_start, "connected" )
		

		@start()
		@connect()

		return

	_start: =>
		@debug "START"
		return

#export this class
module.exports = RedisNotifications