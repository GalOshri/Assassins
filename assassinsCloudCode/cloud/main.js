
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

	// change state from Active to Pending
	query.get(request.objectId, {
		success: function(query)
		{
			query.set("state", "pending");
			query.save();
			console.log("saved it brah!");
		},
		error: function(error)
		{
			console.error("Got an error " + error.code + " : " + error.message);
		}
	});

	response.success("updated contract");
});

