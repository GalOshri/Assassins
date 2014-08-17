
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

Parse.Cloud.define("completedContract", function(request, response) {
	var contractId = request.params.contractId;

	var contractQuery = new Parse.Query("Contract");

	contractQuery.get(contractId, {

		success:function(oldContract) {
			var assassin = oldContract.get("assassin");
			var target = oldContract.get("target");
			var gameId = oldContract.get("gameId");

			var targetContractQuery = new Parse.Query("Contract");
			targetContractQuery.equalTo("gameId", gameId);
			targetContractQuery.equalTo("assassin", target);
			targetContractQuery.equalTo("state", "Active");

			targetContractQuery.first({
				success: function(targetContract) {
			      
			    var Contract = Parse.Object.extend("Contract");
			    var contract = new Contract();

			    contract.set("assassin", assassin);
			    contract.set("target", targetContract.get("target"));
			    contract.set("state", "Active");
			    contract.set("commentLocation", -1);
			    contract.set("gameId", gameId);

			    contract.save(null, {
			    	success: function(contract) {
			    		alert('New contract created');
			    		response.success("Success!");
			    	},
			    	error: function(contract, error) {
			    		alert('error: ' + error.message);
			    	}
			    });

			    },
			    error: function() {
			      response.error("Contract creation failed");
			    }
			});


		},
		error: function(){
			response.error("couldn't find contract");
		}
	});
});



/* after save cloud code
// update contracts
*/
/*
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
*/
