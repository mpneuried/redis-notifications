module.exports = new ( class UserSchema extends require( "obj-schema" ) )(
	id: 
		required: true

	firstname: 
		type: "string"
		required: true

	lastname: 
		type: "string"
		required: true

	email: 
		type: "email"
		required: true

	timezone:
		type: "timezone"
		required: true		

	sendInterval:
		type: "string"
		required: true
		regexp: /^(0|i|p|d\d{4})$/

, name: "user" ).validateCb