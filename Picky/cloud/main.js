
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define(“updateCount”, function(request, response) {
  var Restaurant = Parse.Object.extend(“Restaurants”);
  var query = new Parse.Query(Restaurant);
});

