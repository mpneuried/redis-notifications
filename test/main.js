(function() {
  var Module, should, _moduleInst;

  should = require('should');

  Module = require("../.");

  _moduleInst = null;

  describe("----- redis-notifications TESTS -----", function() {
    before(function(done) {
      _moduleInst = new Module();
      done();
    });
    after(function(done) {
      done();
    });
    describe('Main Tests', function() {
      it("first test", function(done) {
        done();
      });
    });
  });

}).call(this);
