module.exports = (robot) ->
	robot.hear /score (.*)/i, (msg) ->
		# Find the team's city
		team = msg.match[1]
		# Just setting this to Seattle for now
		city = 'NY Yankees'

		# Get game data for today
		# Setting the date static for now
		day = '24'
		month = '03'
		year = '2016'
		url = 'http://mlb.mlb.com/gdcross/components/game/mlb/year_' + year + '/month_' + month + '/day_' + day + '/master_scoreboard.json'

		msg.http(url)
			.get() (err, res, body) ->
				gameData = JSON.parse(body)

		# Parse the data to see if team has a game today
				gameNumber = 0

				while gameData.data.games.game[gameNumber].home_team_city != city & gameData.data.games.game[gameNumber].away_team_city != city
					gameNumber++
					if gameData.data.games.game[gameNumber] is undefined
						msg.send 'Seattle did not play'
						break
				msg.send 'Your team is in game number: ' + gameNumber

				myGame = gameData.data.games.game[gameNumber]
				msg.send 'home team is: ' + myGame.home_team_city

		# Figure out if the team is home or away
				homeAway = ''

				if myGame.home_team_city is city
					homeAway = 'home'
				else if myGame.away_team_city is city
					homeAway = 'away'
				else
					homeAway = 'error'
				msg.send 'Your team is: ' + homeAway

		# Find the score of each team
				myTeamScore = ''
				opponentTeamScore = ''

				if city is myGame.home_team_city
					myTeamScore = myGame.linescore.r.home
					opponentTeamScore = myGame.linescore.r.away
				else if city is myGame.away_team_city
					myTeamScore = myGame.linescore.r.away
					opponentTeamScore = myGame.linescore.r.home
				else
					msg.send 'error'
				msg.send 'myTeamScore: ' + myTeamScore

		# Check if the game is over
				if myGame.status.status is 'Final'
					msg.send 'Game Over'
				else
					inning = myGame.status.inning
					inning_state = myGame.status.inning_state
		# If yes, report the score
					if myTeamScore > opponentTeamScore
						msg.send 'Seattle is leading in the ' + inning_state + ' of the ' + inning + ' ' + myTeamScore + '-' + opponentTeamScore
					else if myTeamScore < opponentTeamScore
						msg.send 'Seattle is trailing in the ' + inning_state + ' of the ' + inning + ' ' + opponentTeamScore + '-' + myTeamScore


