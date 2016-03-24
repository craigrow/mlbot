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

		# Figure out if the team is home or away
				homeAway = ''

				if gameData.data.games.game[gameNumber].home_team_city is city
					homeAway = 'home'
				else if gameData.data.games.game[gameNumber].away_team_city is city
					homeAway = 'away'
				else
					homeAway = 'error'
					msg.send homeAway

		# Find the score of each team
				myTeamScore = ''
				opponentTeamScore = ''

				if city is gameData.data.games.game[gameNumber].home_team_city
					myTeamScore = gameData.data.games.game[gameNumber].linescore.r.home
					opponentTeamScore = gameData.data.games.game[gameNumber].linescore.r.away
				else if city is gameData.data.games.game[gameNumber].away_team_city
					myTeamScore = gameData.data.games.game[gameNumber].linescore.r.away
					opponentTeamScore = gameData.data.games.game[gameNumber].linescore.r.home
				else
					msg.send 'error'
				msg.send 'myTeamScore: ' + myTeamScore
		# Check if the game is over
				if gameData.data.games.game[gameNumber].status.status is 'Final'
					msg.send 'Game Over'
				else
					inning = gameData.data.games.game[gameNumber].status.inning
					inning_state = gameData.data.games.game[gameNumber].status.inning_state
		# If yes, report the score
					if myTeamScore > opponentTeamScore
						msg.send 'Seattle is leading in the ' + inning_state + ' of the ' + inning + ' ' + myTeamScore + '-' + opponentTeamScore
					else if myTeamScore < opponentTeamScore
						msg.send 'Seattle is trailing in the ' + inning_state + ' of the ' + inning + ' ' + opponentTeamScore + '-' + myTeamScore


