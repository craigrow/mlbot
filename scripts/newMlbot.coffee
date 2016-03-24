module.exports = (robot) ->
	robot.hear /score (.*)/i, (msg) ->
		# Find the team's city
		team = msg.match[1]
		# Just setting this to Seattle for now
		city = 'Seattle'

		# Get game data for today
		# Setting the date static for now
		day = '23'
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
				msg.send 'Seattle is in game number: ' + gameNumber

				if gameData.data.games.game[gameNumber].status.status is 'Final'
					msg.send 'Game Over'
				else
					inning = gameData.data.games.game[gameNumber].status.inning
					inning_state = gameData.data.games.game[gameNumber].status.inning_state
					msg.send 'Seattle is still playing in the ' + inning_state + ' of the ' + inning
		# Check if the game is over

		# If yes, report the score