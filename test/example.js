(function() {
  var RedisNotifications, nf;

  RedisNotifications = require("../.");

  nf = new RedisNotifications();

  nf.on("mail", function(subject, content) {
    console.log("SENDMAIL", subject, content);
  });

  nf.sendMulti(type, users);

  nf.sendSingle(type, users);

  nf.on("readUser", function(uid, cb) {
    cb(null, {
      firstname: "John",
      lastname: "Do",
      email: "john.do@example.com",
      timezone: "+00",
      sendIntervall: "daily"
    });
  });

}).call(this);
