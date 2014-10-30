
/* BT601
// Assassins CloudCode
// Created 3 August 2014
// 
*/

var MAX_HOURS_PENDING_SNIPES = 24;


Parse.Cloud.define("completedContract", function(request, response) {
	var contractId = request.params.contractId;
	var Contract = Parse.Object.extend("Contract");
	var contractQuery = new Parse.Query(Contract);

	Parse.Cloud.useMasterKey();

	contractQuery.get(contractId, {
		success:function(oldContract) {
			console.log("getting contract's target");
			var assassin = oldContract.get("assassin");
			var assassinName = oldContract.get("assassinName");
			var assassinFbId = oldContract.get("assassinFbId");
			var target = oldContract.get("target");
			var nameOfEliminatedPlayer = oldContract.get("targetName");
			var game = oldContract.get("game");

			var targetContractQuery = new Parse.Query(Contract);
			targetContractQuery.equalTo("game", game);
			targetContractQuery.equalTo("assassin", target);
			targetContractQuery.equalTo("state", "Active");

			targetContractQuery.first({
				success: function(targetContract) {
					console.log("got contract's target, setting state to failed");
					targetContract.set("state", "Failed");
					targetContract.save();
			      
			    	// If the game is over
			    	console.log("checking who is the winner");
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
						    game.set("winnerName", assassinName);
						    game.set("winnerFbId", assassinFbId);
							game.save();

							var playersArray = game.get("players");

							//increment everyone's lifetime games
							var playersIdArray = [];
							playersArray.forEach(function(player) 
							{ 
								playersIdArray.push(player.id);
							});
							
							var userQuery = new Parse.Query(Parse.User);
							userQuery.containedIn("objectId", playersIdArray);

							userQuery.find(
							{
								success: function(results) 
								{
									Parse.Cloud.useMasterKey();
									results.forEach(function(user) 
									{
										user.increment("lifetimeGames");
										user.save();
									});
								},
								error: function(error)
								{ 
									console.log("can't increment lifetimeGames");
								}
							});

							var userQuery = new Parse.Query(Parse.User);
							userQuery.each(function(user) {
								user.increment("lifetimeGames");
								user.save();
							});

							// Push notification to all players to announce the winner
							var winnerQuery = new Parse.Query(Parse.User);
							winnerQuery.get(assassin.id, {
								success: function(winner) {
									console.log('hi: ' + winner.get("username"));

									winner.increment("lifetimeSnipes");
									winner.save();

									var pushQuery = new Parse.Query(Parse.Installation);
									pushQuery.containedIn('user', playersArray);
									 
									Parse.Push.send({
									  where: pushQuery, // Set our Installation query
									  data: {
									  	alert: winner.get("username") + " just won game \""+ game.get("name") +"\"!",
									  	"gameId" : game.id
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
					    // create new contract
					    var contract = new Contract();
					    contract.set("assassin", assassin);
					    contract.set("assassinName", oldContract.get("assassinName"));
						contract.set("assassinFbId", oldContract.get("assassinFbId"));

					    contract.set("target", targetContract.get("target"));
					    contract.set("targetName", targetContract.get("targetName"));
					    contract.set("targetFbId", targetContract.get("targetFbId"));

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

						// assassins query to inrement kills
					    var assassinQuery = new Parse.Query(Parse.User);
						assassinQuery.get(assassin.id, {
							success: function(killer) {
								//  increment lifetime snipes
								killer.increment("lifetimeSnipes");
								killer.save();
							},
							error: function(error) {
								console.log("killer update lifetimeSnipes error: " + error.message);
							}

						});	

						// push notification
						var GameObject = Parse.Object.extend("Game");
			    		var gameObjectQuery= new Parse.Query(GameObject);

						// console.log("do we even get to set gameObjectQuery? game.id is " + game.id);

						gameObjectQuery.get(game.id, {
							success: function(gameInQuestion) {
								console.log("hi?");
								var players = gameInQuestion.get("players");
								// console.log("length of players is " + players.length);
								// console.log("nameOfEliminatedPlayer is " + nameOfEliminatedPlayer);

								// push here
								var pushQueryToNotify = new Parse.Query(Parse.Installation);
								pushQueryToNotify.containedIn('user', players);
								 
								Parse.Push.send({
								  where: pushQueryToNotify, // Set our Installation query
								  data: {
								  	alert: nameOfEliminatedPlayer + " has been eliminated from game: " + gameInQuestion.get("name"),
								  	"gameId" : game.id
								  	}
								  },{
								  success: function() {
								    console.log("pushed to users about assassination");
								  },
								  error: function(error) {
								    console.log("push error: " + error.message);
								  }
								});
							},
							error: function(error)
							{ 
								console.log("didn't push");
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
	var safeZones = request.params.safeZones;

	// Create game object
	var Game = Parse.Object.extend("Game");
	var game = new Game();

	game.set("name", gameName);
	game.set("safeZones", safeZones);
	game.set("state", "Active");
	game.set("numberPendingSnipes", 0);


	// Parse list of users (not sure if we can pass up user objects or just a list of IDs)

	// TODO: go from facebook ID to parse ID
	// create Promises

	var userList = request.params.userList;
	var userObjectPointerList = [];
	var userObjectList = []
	
	// perform query for users where Facebook ID contained in userList
	var userIdQuery = new Parse.Query(Parse.User);
	userIdQuery.containedIn("facebookId", userList);

	userIdQuery.find().then(function(gameParticipants) {
		//create promise
		var promise = Parse.Promise.as();
		for (var participant in gameParticipants)
		{
			// extend the promise with a function to add parse id to userobjectpointerlist
			promise = promise.then(function() {
				userObject = new Parse.User();
				userObject.id = gameParticipants[participant].id;
				userObjectPointerList.push(userObject);

				// create userobjectlist
				var userInfo = {"userObject": userObject, "username": gameParticipants[participant].get("username"), "facebookId": gameParticipants[participant].get("facebookId")};
				return userObjectList.push(userInfo);
			});
		}

		// send a push notification to all people in game
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.containedIn('user', userObjectPointerList);
		 
		Parse.Push.send({
		  where: pushQuery, // Set our Installation query
		  data: {
		  	alert: "You are now an assassin in the game: " + gameName
		  	}
		  },
			{
		  		success: function()
		  		{
		  			console.log("we pushed game creation");
		  		},
		  		error: function(error)
		  		{
		  			console.log("oh-oh game creation: " + respose.code + " " + response.error);
		  		}
		  	}
		);
		return promise;

	}).then(function() {

		// Populate game with user POINTERS
		game.set("players", userObjectPointerList);

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
				var assassinObject = userObjectList[i]; 
				if (i == userObjectList.length - 1) // This is the last user, his target is first user
					var targetObject = userObjectList[0]; 
				else
					var targetObject = userObjectList[i + 1];

				var contract = new Contract();
				console.log("assassin: " + assassinObject.userObject+ " target: " + targetObject.userObject);
				console.log("this contract will have assassinName " + assassinObject.username + " with fbid " + assassinObject.facebookId + " and targetname " + targetObject.username + " with fbid " + targetObject.facebookId);
				
				contract.set("assassin", assassinObject.userObject);
				contract.set("assassinName", assassinObject.username);
				contract.set("assassinFbId", assassinObject.facebookId);
			    contract.set("target", targetObject.userObject);
			    contract.set("targetName", targetObject.username);
				contract.set("targetFbId", targetObject.facebookId);
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

Parse.Cloud.define("startPendingContractProcess", function(request, response) {
	
	var gameId = request.params.gameId;
	var contractId = request.params.contractId;
	var targetName = request.params.targetName;

	var assassins = [];
	var assassinsList = [];

	//grab players with game ID
	var GameObject = Parse.Object.extend("Game");
	var gameQuery = new Parse.Query(GameObject);

	gameQuery.get(gameId, {
		success: function(game) {
			assassins = game.get("players");

			// increment and save number of pending snipes
			game.increment("numberPendingSnipes");
			game.save();

		},
		error: function(error)
		{
			console.log("Error: " + error.code + " " + error.message);
		}
	}).then(function() {
		/*
		var userList = new Parse.Query(Parse.User);

	    for(var i=0; i< assassins.length; i++)
	    	assassinsList.push(assassins[i].id);
	    Parse.Cloud.useMasterKey();

		userList.containedIn("objectId", assassinsList);
		userList.find({
			success: function(results) {
				console.log("results length is " + results.length);
				// increment snipesToVerify
				 results.forEach(function(user) {
					user.addUnique("snipesToVerify", contractId);
					user.save();
				});
			},
			error: function(error) {

				console.log("Error: " + error.code + " " + error.message);
			}
		});

	}).then(function() {*/


		// mark contract as pending
		var Contract = Parse.Object.extend("Contract");
		var pendingQuery = new Parse.Query(Contract);
		pendingQuery.get(contractId, {
			success: function(pendingContract)
			{
				var currentDate = new Date();
				pendingContract.set("state", "Pending");
				pendingContract.set("timePendingStarted", currentDate);
				pendingContract.set("invalidateVoters", []);
				pendingContract.save();
			},
			error: function(error)
			{
				console.log("could not make contract pending: " + error.message);
			}
		});

		// send push notification to all players in game
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.containedIn('user', assassins);
		 
		Parse.Push.send({
		  where: pushQuery, // Set our Installation query
		  data: {
		  	alert: targetName + " challenges a snipe! Help confirm",
		  	"contractId" : contractId
		  	}
		  },
			{
		  		success: function()
		  		{
		  			response.success("we pushed, yah?");
		  		},
		  		error: function(error)
		  		{
		  			response.error("oh-oh: " + respose.code + " " + response.error);
		  		}
		  	}
		);
	});
});



Parse.Cloud.define("checkInvalidatedSnipe", function(request, response) {
	//get variables from request and declare necessary variables
	var gameId = request.params.gameId;
	var contractId = request.params.contractId;
	var userId = request.params.userId; 

	var timePendingStarted; 
	var endDate;
	var currentDate = new Date(); 
	var numInvalidators;
	var numPlayers;
	var assassinId;
	var targetId;

	// grab contract 
	var Contract = Parse.Object.extend("Contract");
	var pendingContractQuery = new Parse.Query(Contract);
	pendingContractQuery.include("game");
	pendingContractQuery.get(contractId, 
	{
		success:function(pendingContract) 
		{
			// grab time added 
			timePendingStarted = pendingContract.get("timePendingStarted");
			endDate = new Date(timePendingStarted);
			endDate.setDate(endDate.getDate()+1);

			var game = pendingContract.get("game");
			var players = game.get("players");
			// game.increment("numberPendingSnipes", -1);
			// game.save();

			if(currentDate > endDate)
			{
				// change state from pending to complete
				pendingContract.set("state", "Completed");
				console.log("currentdate is " + currentDate + " and endDate is " + endDate);
				game.increment("numberPendingSnipes", -1);
				//send push notification that snipe was not overturned. 
				var pushQuery = new Parse.Query(Parse.Installation);
				pushQuery.containedIn('user', players);
				 
				Parse.Push.send({
					where: pushQuery, // Set our Installation query
					data: {
				  		alert: pendingContract.get("targetName") + "has been eliminated from the game \"" + game.get("name") + "\"",
				  		"gameId" : game.id
					}
					}, {
					  success: function() {
					    response.success("pending snipe not overturned");
					  },
					  error: function(error) {
					    response.error("pending snipe not overturned error: " + error.message);
					  }
				});
			}

			else
			{
				// add user ID to contract
				pendingContract.addUnique("invalidateVoters", userId);
				invalidateVoters = pendingContract.get("invalidateVoters");
				numInvalidators = invalidateVoters.length;

				var assassin = pendingContract.get("assassin");
				assassinId = assassin.id;
				var target = pendingContract.get("target");
				targetId = target.id;

				// console.log(" the assassin of the pending contract is " + assassinId);
				// console.log(" the target of the pending contract is " + targetId);

				numPlayers = players.length;

				// now do check for players
				if(numInvalidators > numPlayers/2)
				{
					// find assassin of contract, then send to checkContracts
					// at this point, we know we need to nullify contract
					pendingContract.set("state", "Overturned");
					Parse.Cloud.run("checkContracts", {"assassinId": assassinId, "gameId":gameId, "userIdToInsert":targetId, "originalContractId":contractId});
				}
			}

			//save items
			game.save();
			pendingContract.save();
			response.success("ohhi");
		},
		error:function(error)
		{
			response.error("contract error: " + error.code + " " + error.message);
		}
	});
});	

Parse.Cloud.define("checkContracts", function(request, response) {
	// define parameters passed:
	var originalContractId = request.params.originalContractId;
	var assassinId = request.params.assassinId;
	var gameId = request.params.gameId;
	var userIdToInsert = request.params.userIdToInsert;
	var targetId;
	var userToAddName;
	var bringBackToLife = 0;

	// create contract query and potential contracts to fill
	var Contract = Parse.Object.extend("Contract");
	var contractCheck = new Parse.Query(Contract);

	// grab all contracts where user is assassin in given game
	var Game = Parse.Object.extend("Game");
	var gameObject = new Game();
	gameObject.id = gameId;

	var assassinUser = new Parse.User();
	assassinUser.id = assassinId;

	contractCheck.equalTo("assassin", assassinUser);
	contractCheck.equalTo("game", gameObject);


    // order by date to get the latest one first
    contractCheck.descending("createdAt");
	contractCheck.first({
		success:function(lastContract)
		{

			var state = lastContract.get("state");
			var target = lastContract.get("target");
			targetId = target.id;

			if(state == "Completed")
			{
				// grab userId, and call function again
				console.log("assassinId is " + assassinId + ". recursive call");
				Parse.Cloud.run("checkContracts", {"assassinId": targetId, "gameId":gameId, "userIdToInsert":userIdToInsert});
			}

			// base case 
			if(state == "Active")
			{	
				console.log("we have an active case! Base Case!");
				// we make current contract nullified
				lastContract.set("state", "Nullified");
				bringBackToLife = 1;
				lastContract.save();
			}
		},
		error: function(error)
		{
			//response.error("error in grabbing last contract in recursive function: " + error.code + " " + error.message);
		}
	}).then(function() {
		if(bringBackToLife == 1)
		{
			var newContract1 = new Contract();
			var newContract2 = new Contract();
			var assassinFbId;
			var targetFbId;
			var userToAddFbId;
			var assassinName;
			var targetName;
			
			//PUT .THEN HERE
			var userQuery = new Parse.Query(Parse.User);
			var userQueryArray = [targetId, userIdToInsert, assassinId];
			userQuery.containedIn("objectId", userQueryArray);
			
			userQuery.find({
				success:function(users)
				{
					users.forEach(function(user) {
						// save new objects
						console.log("saving elements for new contracts for user " + user.id);
						if(user.id == assassinId)
						{
							assassinFbId =  user.get("facebookId");
							assassinName = user.get("username");

							console.log(" got assassin's name and Id. Name is " +assassinName);
						}

						else if(user.id == userIdToInsert)
						{
							userToAddFbId =  user.get("facebookId");
							userToAddName = user.get("username");

							console.log(" got added-user's name and Id. name is " + userToAddName);
						}

						else //assassin (who is actually now the target)
						{
							targetFbId =  user.get("facebookId");
							targetName = user.get("username");

							console.log(" got target's name and Id. name is " + targetName);;
						}
					});
					// response.success("save user info to new contracts");
				},
				error: function(error)
				{
					console.log("error in saving new contracts: " + error.code + " " + error.message);
					// response.error("error in saving new contracts: " + error.code + " " + error.message);
				}
			}).then(function() {
				// finish saving new contracts
				newContract1.set("state", "Active");
				newContract1.set("commentLocation", -1);
				newContract2.set("state", "Active");
				newContract2.set("commentLocation", -1);
				
				var userToInsert = new Parse.User();
				userToInsert.id = userIdToInsert;

				var targetUserToInsert = new Parse.User();
				targetUserToInsert.id = targetId;
				
				// first contract
				newContract1.set("game", gameObject);
			    newContract1.set("assassin", assassinUser);
			    newContract1.set("target", userToInsert);
			    newContract1.set("assassinName", assassinName);
			    newContract1.set("assassinFbId", assassinFbId);
			    newContract1.set("targetFbId", userToAddFbId);
			    newContract1.set("targetName", userToAddName);
			    // second contract
			    newContract2.set("game", gameObject);
			    newContract2.set("target", targetUserToInsert);
			    newContract2.set("assassin", userToInsert);
			    newContract2.set("assassinName", userToAddName);
			    newContract2.set("assassinFbId", userToAddFbId);
			    newContract2.set("targetFbId", targetFbId);
			    newContract2.set("targetName", targetName);

			    var saveContractArray = new Array();
			    saveContractArray.push(newContract1, newContract2);
			    console.log("save contract array has assassins "  + newContract1.get("state") + " + " + newContract2.get("state"));

			    Parse.Object.saveAll(saveContractArray,{
				    success: function(list) {
				      console.log("ok" ); 
				    },
				    error: function(error) {
				      // An error occurred while saving one of the objects.
				      console.log("failure on saving list " + error.code + " " + error.message);
				    },
				});

				// start doing things for push notifications and game
				Parse.Cloud.useMasterKey();

				// for all users involved, remove contractId from snipesToVerify
				var gameObjectRetrieval = Parse.Object.extend("Game");
				var gameQueryRemoveSnipe = new Parse.Query(gameObjectRetrieval);
				var usersToRemovePendingSnipe = [];

				gameQueryRemoveSnipe.get(gameId, {
					success: function(game) {
						// decrement number of pending snipes
						game.increment("numberPendingSnipes", -1);
						game.save();

						usersToRemovePendingSnipe = game.get("players");
						var userIdsToRemovePendingSnipe = [];

						for(var i=0; i< usersToRemovePendingSnipe.length; i++)
					    	userIdsToRemovePendingSnipe.push(usersToRemovePendingSnipe[i].id);
					   
					    
					    var userList = new Parse.Query(Parse.User);
						userList.containedIn("objectId", userIdsToRemovePendingSnipe);

						userList.find({
							success: function(results) {
								Parse.Cloud.useMasterKey();
								// remove snipe from snipesToVerify
								 results.forEach(function(user) {
									user.remove("snipesToVerify", originalContractId);
									user.save();
								});
							},
							error: function(error) {

								console.log("Error: " + error.code + " " + error.message);
							}
						});

						// send push notification to tell users that person is back to life. 
						var pushQuery = new Parse.Query(Parse.Installation);
						pushQuery.containedIn('user', usersToRemovePendingSnipe);
						 
						Parse.Push.send({
							where: pushQuery, // Set our Installation query
							data: {
						  		alert: userToAddName + " has been brought back to life for the game \"" + game.get("name") + "\"",
						  		"gameId" : game.id
							}
							}, {
							  success: function() {
							    response.success("pending snipe overturned");
							  },
							  error: function(error) {
							    response.error("pending snipe overturned error: " + error.message);
							  }
						});
					},
					error: function(error)
					{
						console.log("Error: " + error.code + " " + error.message);
					}
				});
			});
		}


		// we didn't bring back to life...
		else
		{

		}
	});
});

Parse.Cloud.job("invalidateExpiredPendingSnipes", function(request, status) 
{
	//current time
	var currentDate = Date.now();

	// query for all pending snipes
	var Contract = Parse.Object.extend("Contract");
	var contractQuery = new Parse.Query(Contract);

	contractQuery.each(function(pendingContract)
	{
		if(pendingContract.get("state") == "Pending")
		{
			var snipeTime = pendingContract.get("snipeTime");
			console.log("objectId is " + pendingContract.id);
			console.log("snipeTime is " + snipeTime);

			var deltaTime = currentDate - snipeTime;
			console.log("deltaTime is " + deltaTime + ". That's hours  = " + deltaTime/3600000);

			// if more than 24 hours invalidate
			if(deltaTime / (1000*60*60) > MAX_HOURS_PENDING_SNIPES)
			{
				pendingContract.set("state", "Completed");

				var game = pendingContract.get("game");
				// send push notification
				var GameObject = Parse.Object.extend("Game");
	    		var gameObjectQuery= new Parse.Query(GameObject);

				console.log("do we even get to set gameObjectQuery? game.id is " + game.id);

				gameObjectQuery.get(game.id, {
					success: function(gameInQuestion) {
						console.log("hi?");
						var players = gameInQuestion.get("players");

						// decrement number of pending contracts in games
						gameInQuestion.increment("numberPendingSnipes", -1);
						gameInQuestion.save();
						console.log("length of players is " + players.length);
						console.log("nameOfEliminatedPlayer is " + pendingContract.get("targetName"));

						// push here
						var pushQueryToNotify = new Parse.Query(Parse.Installation);
						pushQueryToNotify.containedIn('user', players);
						 
						Parse.Push.send({
						  where: pushQueryToNotify, // Set our Installation query
						  data: {
						  	alert: pendingContract.get("targetName") + " has been eliminated from game: " + gameInQuestion.get("name"),
						  	"gameId" : game.id
						  	}
						  },{
						  success: function() {
						    console.log("pushed to users about assassination");
						  },
						  error: function(error) {
						    console.log("push error: " + error.message);
						  }
						});
					},
					error: function(error)
					{ 
						console.log("didn't push");
					}
				});
			}
		}

		return pendingContract.save();
	}).then(function() 
	{
		// Set the job's success status
    	status.success("pending snipes cleaned successfully.");
	}, function(error) {
		// Set the job's error status
	    status.error("Uh oh, something went wrong.");
	});
});


