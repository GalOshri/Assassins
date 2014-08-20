
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

	var Contract = Parse.Object.extend("Contract");
	var contractQuery = new Parse.Query(Contract);

	contractQuery.get(contractId, {

		success:function(oldContract) {
			var assassin = oldContract.get("assassin");
			var target = oldContract.get("target");
			var game = oldContract.get("game");

			var targetContractQuery = new Parse.Query(Contract);
			targetContractQuery.equalTo("game", game);
			targetContractQuery.equalTo("assassin", target);
			targetContractQuery.equalTo("state", "Active");

			targetContractQuery.first({
				success: function(targetContract) {

					targetContract.set("state", "Failed");
					targetContract.save();
			      
			    	// If the game is over
			    	if (targetContract.get("target").id == assassin.id)
			    	{
			    		alert("HI WE ARE MATCH with game: " + game.id);
			    		// Complete the game
			    		var GameObject = Parse.Object.extend("Game");
			    		var gameQuery = new Parse.Query(GameObject);

						gameQuery.get(game.id, {
							success: function(game) {
						    
						    // Game state is over
						    game.set("state", "Completed");
						    game.set("winner", assassin);
							game.save();

							// Push notification to all players to announce the winner
							// TODO: INCREMENT EVERYONE'S GAME COUNT BY 1
							var User = Parse.Object.extend("User");
								var winnerQuery = new Parse.Query(User);
								winnerQuery.get(assassin.id, {
									success: function(winner) {
										console.log('hi: ' + winner.get("username"));

										var playersArray = game.get("players");

										var pushQuery = new Parse.Query(Parse.Installation);
										pushQuery.containedIn('user', playersArray);
										 
										Parse.Push.send({
										  where: pushQuery, // Set our Installation query
										  data: {
										  	alert: winner.get("username") + " just won the game!"
										  }
										}, {
										  success: function() {
										    response.success("Game is over");
										  },
										  error: function(error) {
										    response.error("push error: " + error.message);
										  }
										});
									},
									error: function(error) {
										response.error("winner error: " + error.message);
									}
								}); 
						    
						  },

							error: function(game, error) {
						    	alert("Couldn't find game");
						    	response.error("Couldn't find game with error: " + error.message);
						  }
						});
			    	}

			    	// Create new contract
			    	else
			    	{
					    var contract = new Contract();

					    contract.set("assassin", assassin);
					    contract.set("target", targetContract.get("target"));
					    contract.set("state", "Active");
					    contract.set("commentLocation", -1);
					    contract.set("game", game);

					    contract.save(null, {
					    	success: function(contract) {
					    		alert('New contract created');
					    		response.success("New contract created!");
					    	},
					    	error: function(contract, error) {
					    		response.error('contract creation failed with error: ' + error.message);
					    	}
					    });
					}

			    },
			    error: function(error) {
			    	response.error("Couldn't find target contract: " + error.message);
			    }
			});


		},
		error: function(error){
			response.error("couldn't find contract: " + error.message);
		}
	});
});

// Create game. Parameters are: game Name, list of users
Parse.Cloud.define("createGame", function(request, response) {
	var gameName = request.params.gameName;

	// Create game object
	var Game = Parse.Object.extend("Game");
	var game = new Game();

	game.set("name", gameName);
	game.set("state", "Active");


	// TODO: Parse list of users (not sure if we can pass up user objects or just a list of IDs)
	var userList = request.params.userList;

	// TODO: Populate game with user POINTERS
	var userObjectList;
	game.set("players", userObjectList);

	// Create contracts
	var contractList = [];
	var Contract = Parse.Object.extend("Contract");
	for (var i = 0; i < request.params.userList; i++) // this is the number of contracts we need
	{
		var assassin; // TODO: PICK USERS SOMEHOW REAL
		var target; // TODO: PICK USERS SOMEHOW REAL

		var contract = new Contract();

		contract.set("assassin", assassin);
	    contract.set("target", target);
	    contract.set("state", "Active");
	    contract.set("commentLocation", -1);
	    contract.set("game", game);

	    contract.save();

	    contractList.push(contract); // TODO: PUSH A POINTER, NOT THE FULL OBJECT
	}


	// Populate game object with the contracts
	game.set("contracts", contractList);

	// Save game
	game.save();
	/*game.save(null, {
    	success: function(contract) {
    		alert('New contract created');
    		response.success("New contract created!");
    	},
    	error: function(contract, error) {
    		response.error('contract creation failed with error: ' + error.message);
    	}
    });*/
}



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
