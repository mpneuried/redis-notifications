module.exports = new ( class CreatorSchema extends require( "obj-schema" ) )(
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

, name: "creator" ).validateCb