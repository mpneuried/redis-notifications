module.exports = new ( class CreatorSchema extends require( "./schema" ) )(
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