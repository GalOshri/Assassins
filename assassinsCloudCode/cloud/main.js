
/* BT601
// Assassins CloudCode
// Created 3 August 2014
// 
*/


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

							// Not needed: var User = Parse.Object.extend("User");
							var userQuery = new Parse.Query(Parse.User);
							userQuery.each(function(user) {

								var numGames = user.get("lifetimeGames");
								user.set("lifetimeGames", numGames + 1);
								user.save();
							});

							// Push notification to all players to announce the winner
							var winnerQuery = new Parse.Query(Parse.User);
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


	// Parse list of users (not sure if we can pass up user objects or just a list of IDs)
	// DEFAULT: each userObject looks like this:
	/*
		(
	        {
		        "first_name" = Gal;
		        id = 10154590671315045;
		        "last_name" = Oshri;
		        name = "Gal Oshri";
		        picture =         {
		            data =             {
		                height = 100;
		                "is_silhouette" = 0;
		                url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/v/t1.0-1/c50.49.618.618/s100x100/60089_10152163890980045_192814225_n.jpg?oh=fc7fe63a0c4f4cc93736968ccf96ecc0&oe=547F59CD&__gda__=1416039518_536274aacda429f6fbb173085d508537";
		                width = 100;
		            };
		        };
		    }
		)
	*/

	// TODO: go from facebook ID to parse ID
	var userList = request.params.userList;
	console.log("userlist is " + userList + " with length " + userList.length);
	var userObjectList = [];
	for (var i = 0; i < userList.length; i++)
	{
		console.log("facebook ID is " + userList[i].id);
		var userObject = new Parse.User();
		var parseId;

		// TODO: grab Parse objectID
		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("facebookId", userList[i].id);

		userQuery.first({
			success: function(object) 
			{
				// Successfully retrieved the object.
				parseId = object.id;
				console.log("successfully made userQuery");
				// console.log("fbID was " + userList[i].id + " and parse id is " + parseId);
			},

			error: function(error) 
			{
				alert("Error from userQuery: " + error.code + " " + error.message);
			}
	});

		userObject.id = parseId;
		userObjectList.push(userObject);
	}

	// add self to userObjectList
	var meUserObject = new Parse.User();
	meUserObject.id = request.params.meId;
	userObjectList.push(meUserObject);
	// console.log(meUserObject);

	// Populate game with user POINTERS
	game.set("players", userObjectList);

	// Shuffle list of users. Important to do this AFTER you save it as the game object so that
	// the order of the contracts can't be seen by the players
	var currentIndex = userObjectList.length, temporaryValue, randomIndex;

	// While there remain elements to shuffle...
	while (0 !== currentIndex) 
	{
		// Pick a remaining element...
		randomIndex = Math.floor(Math.random() * currentIndex);
		currentIndex -= 1;

		// And swap it with the current element.
		temporaryValue = userObjectList[currentIndex];
		userObjectList[currentIndex] = userObjectList[randomIndex];
		userObjectList[randomIndex] = temporaryValue;
	}

	game.save(null, {
	  success: function(game) {
	    // Execute any logic that should take place after the object is saved.
	    // Create contracts
		var contractList = [];
		var Contract = Parse.Object.extend("Contract");
		for (var i = 0; i < userObjectList.length; i++) // this is the number of contracts we need
		{
			var assassin = userObjectList[i]; 
			if (i == userObjectList.length - 1) // This is the last user, his target is first user
				var target = userObjectList[0]; 
			else
				var target = userObjectList[i + 1];

			var contract = new Contract();

			contract.set("assassin", assassin);
		    contract.set("target", target);
		    contract.set("state", "Active");
		    contract.set("commentLocation", -1);
		    var gamePointer = {__type: "Pointer", className: "Game", objectId: game.id};
		    contract.set("game",gamePointer);

		    contract.save(null, {
		    	success: function(contract) {
		    		var contractPointer = {__type: "Pointer", className: "Contract", objectId: contract.id};
		    		contractList.push(contractPointer);
		    		if (contractList.length == userObjectList.length)
		    		{
		    			game.set("contracts", contractList);
		    			game.save(null, {
		    				success: function(game) {
		    					response.success(game);
		    				},
		    				error: function(game, error) {
		    					response.error("game update failed");
		    				}
		    			});
		    			
		    		}
		    	},
		    	error: function(contract, error) {
		    		response.error("contract creation failed");
		    	}
		    });
		}
	  },
	  error: function(game, error) {
	    // Execute any logic that should take place if the save fails.
	    // error is a Parse.Error with an error code and description.
	    alert('Failed to create new object, with error code: ' + error.message);
	    response.error("game creation failed");
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
