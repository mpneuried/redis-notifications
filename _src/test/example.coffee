RedisNotifications = require( "../." )

nf = new RedisNotifications()

nf.on "mail", ( subject, content )->
	console.log "SENDMAIL", subject, content
	return


nf.sendMulti( type, users )

nf.sendSingle( type, users )

nf.on "readUser", ( uid, cb )->
	# read the users settings
	cb( null,
		firstname: "John"
		lastname: "Do"
		email: "john.do@example.com"
		timezone: "+00"
		sendIntervall: "daily"		
	)
	return

