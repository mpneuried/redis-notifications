    var RedisNotifications = require( "redis-notifications" );

    var nf = new RedisNotifications();

    // REQUIRED EVENT LISTENERS
    // listen to errors
    nf.on( "error", function( err ){
        console.error( err, err.stack );
    });

    // Hock to read details of an user
    nf.on( "readUser", function( user_id, cb ){

        // here you have to query your database and return a valid user with at least these fields
        var user = {
            // required fields
            id: user_id,                                // unique user id
            firstname: "John",          
            email: "john.do@mail.com",
            timezone: "CET",                        // a moment-timezone valid timezone
            sendInterval: "i",                      // when to send a mail 

            // optional fields
            lastname: "Do",             

            // custom fields
            custom_lang: "DE"                       // it is possible to add custom fields
        };
        cb( null, user );
    });

    // Hook to generate the message content for the notification and the mail
    nf.on( "getContent", function( type, user, editor, additional, cb ){

        // here you have to generate your message by type. Usually you would use a template-engine
        
        var content = {
            // required fields
            subject: "This is my message subject",
            body: "Lorem ipsum dolor ...",          

            // custom fields
            custom_field: additional.custom_key,    // it is possible to add custom fields to the content
            custom_lang: user.custom_lang           // reuse the custom field from user
        };
        cb( null, content );
    });

    // Hook to write/send the notification to the user. Is is done immediately on every create
    nf.on( "createNotification", function( user, editor, message, cb ){

        // here you have to write the notification to your db and/or send it immediately to the user

        cb( null );
    });

    // Hook to send a report to a user.
    // This is only done if `sendInterval` is `d{time}`, `i` or `p`
    // Only on `d{time}` a report is generated witch could contain more than one message
    nf.on( "sendMail", function( user, messages, isReport, cb ){

        // here you have to do create of the mail content and mail send it.

        cb( null );
    });

    // INIT
    // you have to initialize the module until the required listeners has been added
    nf.init();

    // METHODS

    // define the data of the editor
    var editor = {
        // required fields
        id: "ABCDE",

        // optional fields
        firstname: "William",
        lastname: "Creator",
        email: "william.create@example.com",

        // custom fields
        custom_lang: "DE"
    };


    // create a notification for multiple users without callback
    var errCrM = nf.createMulti( editor, {
        type: "notification_type",                  // A type to differ the content in the `getContent` hook
        users: [ 123, 456, 789 ],                   // An array of user that will receive this notification
        high: true                                  // A flag to define this notification as high prio.
    });
    if( errCrM ){
        console.error( errCrM );
    }
    // High means:
    // - This message will be send by mail immediately.
    // - Users with `sendInterval = "p"` (only high prio) will also get this notification.

    // create a notification to a single user
    nf.create( editor, {
        type: "notification_type",                  // A type to differ the content in the `getContent` hook
        user: 123,                                  // The user id that will receive this notification
        high: false,                                // A flag to define this notification as high prio.
        additional: {
            custom_icon: "info"                     // additional data that later can be used with in the `getContent` hook
        }
    }, function( err, msgid ){
        if( err ){
            console.error( err );
        }
    });