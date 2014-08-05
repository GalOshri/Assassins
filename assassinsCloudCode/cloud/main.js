
/* BT601
// Assassins CloudCode
// Created 3 August 2014
// 
*/

// Grab image file submitted 
Parse.Cloud.define("hello", function(request, response) 
{
  response.success("Hello world!");
});



/* after save cloud code
// update contracts
*/
Parse.Cloud.afterSave("Contract", function(request, response) 
{	
	var Contract = Parse.Object.extend("Contract");
	var query = new Parse.Query(Contract);
	console.log("request object id: " + request.object.id);

	// change state from Active to Pending
	query.get(request.object.id, {
		success: function(query)
		{
			query.set("state", "Pending");
			query.save();
			console.log("saved it brah!");

			var pushQuery = new Parse.Query(Parse.Installation);
			  pushQuery.equalTo('objectId', 'IpbnC5txgv');
			    
			  Parse.Push.send({
			    where: pushQuery, // Set our Installation query
			    data: {
			      alert: "You got sniped!",
			      contractId: request.object.id
			    }
			  }, {
			    success: function() {
			      // Push was successful
			    },
			    error: function(error) {
			      throw "Got an error " + error.code + " : " + error.message;
			    }
			  });
		},
		error: function(error)
		{
			console.error("Got an error " + error.code + " : " + error.message);
		}
	});
});

