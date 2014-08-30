
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

	// TODO: go from facebook ID to parse ID
	// create Promises

	var userList = request.params.userList;
	var userObjectList = [];
	
	// perform query for users where Facebook ID contained in userList
	var userIdQuery = new Parse.Query(Parse.User);
	userIdQuery.containedIn("facebookId", userList);

	userIdQuery.find().then(function(gameParticipants) {
		//create promise
		var promise = Parse.Promise.as();
		for (var participant in gameParticipants)
		{
			// extend the promise with a function to add parse id to userobjectlist
			promise = promise.then(function() {
				userObject = new Parse.User();
				userObject.id = gameParticipants[participant].id;
				return userObjectList.push(userObject);
			});
		}
		return promise;

	}).then(function() {
		// userObjectList populated with other players
		// Add current user to userobjectlist
		var meUserId =  request.params.meUserId;
		var meUser = new Parse.User();
		meUser.id = meUserId;
		userObjectList.push(meUser);

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

			// 
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
			    		response.error("contract creation failed with error: " + error.code + " : " + error.message);
			    	}
			    });
			}
		  },
		  error: function(game, error) {
		    // Execute any logic that should take place if the save fails.
		    // error is a Parse.Error with an error code and description.
		    response.error("game creation failed with error: "+ error.code + " : " + error.message);
		  }
		});
	});
});
