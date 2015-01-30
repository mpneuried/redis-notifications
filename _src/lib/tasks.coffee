## # RNTasks
# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)
#
# ### Exports: *Class*
# 

# **npm modules**
_ = require( "lodash" )

# **internal modules**

# [validateUser](./schemas/user.coffee.html)
validateUser = require( "./schemas/user" )
# [validateUser](./schemas/user.coffee.html)
validateMessageContent = require( "./schemas/message-content" )

class RNTasks extends require( "mpbasic" )()

	# ## defaults
	defaults: =>
		@extend super, {}

	constructor: ( @main, options )->
		@worker = @main.getWorker()
		@mailbuffer = @main.getMailbuffer()

		# wire tasks to worker 
		@worker.on "crNfcns", @dispatchUsers
		@worker.on "crNfcn", @createNotification
		@worker.on "chShdl", @checkSchedule
		@worker.on "sndMsg", @sendMail
		@worker.on "crMsg", @composeMessageReport
		@worker.on "checkMailBuffer", @checkMailBuffer
		super

	checkSchedule: ( data, next )=>
		@warning "checkSchedule", data
		next()
		return

	dispatchUsers: ( data, next )=>
		#@info "dispatchUsers", data
		for user_id in data.users
			@worker.send( "crNfcn", @extend( {}, _.omit( data, "users" ), user: user_id ) )

		next()
		return

	createNotification: ( data, next, msgid )=>
		#@info "createNotification", data, id
		@main.emit "readUser", data.user, ( err, userdata )=>
			if err
				@main.emit "error", err
				@warning "readUser", err
				next( false )
				return

			_verr = validateUser( userdata, true )
			if _verr
				@warning "validated user", _verr
				@main.emit "error", _verr
				next( false )
				return

			@_getMessageContent( msgid, data, userdata, next )
			return
		return

	checkMailBuffer: =>
		@mailbuffer.listUsers ( err, users )=>
			if err
				@error "checkMailBuffer:listusers", err
				return
			@debug "checkMailBuffer:listUsers", users
			for user_id in users
				@worker.send( "crMsg", user: user_id )
			return
		return

	composeMessageReport: ( data, next )=>
		uid = data.user
		@mailbuffer.userMsgs uid, ( err, msgs )=>
			if err
				@main.emit "error", err
				@warning "composeMessageReport", err
				next( false )
				return
			@debug "composeMessageReport", msgs
			if not msgs.length
				@warning "User with no messgaes"
				@mailbuffer.removeUser uid, 0, ( err )=>
					if err
						@main.emit "error", err
						@warning "sendMail", err
						next( false )
						return
					next()
					return
				return

			# get the userdata out of the first and newest message
			userdata = msgs[ 0 ].userdata
			@worker.send "sndMsg", { user: userdata, messages: _.pluck( msgs, "message" ), composed: true }, ( err )=>
				if err
					@main.emit "error", err
					@warning "getMessageContent:sndMsg", err
					next( false )
					return
				next()
				return
			return
		return

	sendMail: ( data, next )=>
		#@info "sendMail", data
		@main.emit "sendMail", data.user, data.messages, data.composed, ( err )=>
			if err
				@main.emit "error", err
				@warning "sendMail", err
				next( false )
				return

			if not data.composed
				# if it's an immediate send
				next()
				return

			# on composed send remove the data after successful send
			@mailbuffer.removeUser data.user.id, data.messages.length, ( err )=>
				if err
					@main.emit "error", err
					@warning "sendMail:removeUser", err
					next( false )
					return
				next()
				return
			return
		return

	_getMessageContent: ( msgid, data, userdata, next )=>
		#@info "_getMessageContent", data
		@main.emit "getContent", data.type, userdata, data.creator, data.additional, ( err, message )=>
			if err
				@main.emit "error", err
				@warning "getMessageContent", err
				next( false )
				return

			_verr = validateMessageContent( message, true )
			if _verr
				@warning "validated messagecontent", _verr
				@main.emit "error", _verr
				next( false )
				return

			# set the message id to set a unique identifier
			message.id = msgid

			@main.emit "createNotification", userdata, data.creator, message, ( err )=>
				if err
					@main.emit "error", err
					@warning "createNotification", err
					next( false )
					return

				# do not send mails if sendInterval is deactivated
				if userdata.sendInterval is "0"
					next()
					return

				# if the user has set "only prio" and the message is a non prio so stop here
				if not data.high and userdata.sendInterval is "p"
					next()
					return
				
				data.userdata = userdata

				# Send immediately if sendInterval ist set to i (immediately) or p (only prio)
				if userdata.sendInterval in [ "i", "p" ]

					@worker.send "sndMsg", { user: userdata, messages: [ message ], composed: false }, ( err )=>
						if err
							@main.emit "error", err
							@warning "getMessageContent:sndMsg", err
							next( false )
							return
						next()
						return
					return

				data.message = message

				@mailbuffer.write data, ( err )=>
					if err
						@main.emit "error", err
						@warning "createNotification", err
						next( false )
						return
					next()
					return
					
				return
			return
		return


#export this class
module.exports = RNTasks