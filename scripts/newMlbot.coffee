module.exports = (robot) ->
	robot.hear /(.*) score/i, (msg) ->
		# Find the team's city
		team = msg.match[1]
		msg.send 'Your team is: ' + team
		# Just setting this to Seattle for now
		city = getCity(team)
		msg.send 'Your city is: ' + city

		# Get game data for today
		# Setting the date static for now
		day = getDay()
		month = getMonth()
		year = getYear()
		url = 'http://mlb.mlb.com/gdcross/components/game/mlb/year_' + year + '/month_' + month + '/day_' + day + '/master_scoreboard.json'

		msg.http(url)
			.get() (err, res, body) ->
				gameData = JSON.parse(body)

		# Parse the data to see if team has a game today
				gameNumber = 0

				while gameData.data.games.game[gameNumber].home_team_city != city & gameData.data.games.game[gameNumber].away_team_city != city
					gameNumber++
					if gameData.data.games.game[gameNumber] is undefined
						msg.send team + 'does not play today'
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

		# Find the opponent's name
				opponentTeam = ''
				if myGame.home_team_city is city
					opponentTeam = myGame.away_team_city
				else if myGame.away_team_city is city
					opponentTeam = myGame.home_team_city
				else
					opponentTeam = 'error'

		# Figure out if the game is in progress.
				msg.send 'Game status: ' + myGame.status.status
				if myGame.status.status is "Pre-Game" or myGame.status.status is "Preview"
					awayProbablePitcher = myGame.away_probable_pitcher.last
					homeProbablePitcher = myGame.home_probable_pitcher.last
					matchup = awayProbablePitcher + ' vs ' + homeProbablePitcher

					if homeAway is 'home'
						msg.send 'The ' + team + ' are playing ' + opponentTeam + ' at home today. ' + matchup
					else if homeAway is 'away'
						msg.send 'The ' + team + ' are playing in ' + opponentTeam + ' today. ' + matchup
						
		# Find the score of each team
				if myGame.status.status is not 'Pre-Game' or myGame.status.status is not 'Preview'
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
					msg.send "Your team's score: " + myTeamScore
					msg.send "Opponent's score: " + opponentTeamScore

		# Check if the game is over
				if myGame.status.status is 'Final'
					if myTeamScore > opponentTeamScore
						msg.send 'The ' + team + ' beat ' + opponentTeam + ' today! ' + myGame.linescore.r.away + '-' + myGame.linescore.r.home
					else if myTeamScore < opponentTeamScore
						msg.send 'The ' + team + ' lost to ' + opponentTeam + ' today ' + myGame.linescore.r.away + '-' + myGame.linescore.r.home
				
				else if myGame.status.status is 'In-Progress'
					inning = myGame.status.inning
					inning_state = myGame.status.inning_state

					if myTeamScore > opponentTeamScore
						msg.send 'The ' + team + ' are leading ' + opponentTeam + ' in the ' + inning_state + ' of inning ' + inning + ': ' + myGame.linescore.r.away + '-' + myGame.linescore.r.home
					else if myTeamScore < opponentTeamScore
						msg.send 'The ' + team + ' are trailing ' + opponentTeam + ' in the ' + inning_state + ' of inning ' + inning + ': ' + myGame.linescore.r.away + '-' + myGame.linescore.r.home

	getDay = () ->
		today = new Date
		dd = today.getDate()
		if dd < 10
			dd = '0' + dd
		else dd

	getMonth = () ->
		today = new Date
		mm = today.getMonth()
		mm = mm + 1
		if mm < 10
			mm = '0' + mm
		else mm

	getYear = () ->
		today = new Date
		yyyy = today.getFullYear()

	getCity = (team) ->
		if team is "Mariners" or team is "mariners"
			city = "Seattle"
		else if team is "Angels" or team is "angels"
			city = "LA Angels"
		else if team is "Astros" or team is "astros"
			city = "Houston"
		else if team is "Rangers" or team is "rangers"
			city = "Texas"
		else if team is "Athletics" or team is "athletics" or team is "a's" or team is "A's"
			city = "Oakland"
		else if team is "Royals" or team is "royals"
			city = "Kansas City"
		else if team is "Twins" or team is "twins"
			city = "Minnesota"
		else if team is "White Sox" or team is "white sox"
			city = "Chi White Sox"
		else if team is "Tigers" or team is "tigers"
			city = "Detroit"
		else if team is "Indians" or team is "indians"
			city = "Cleveland"
		else if team is "Orioles" or team is "orioles"
			city = "Baltimore"
		else if team is "Red Sox" or team is "red sox" or team is "sox" or team is "Sox"
			city = "Boston"
		else if team is "Yankees" or team is "yankees"
			city = "NY Yankees"
		else if team is "Blue Jays" or team is "blue jays" or team is "Jays" or team is "jays"
			city = "Toronto"
		else if team is "Dodgers" or team is "dodgers"
			city = "LA Dodgers"
		else if team is "Giants" or team is "giants"
			city = "San Francisco"
		else if team is "Padres" or team is "padres"
			city = "San Diego"
		else if team is "Rockies" or team is "rockies"
			city = "Colorado"
		else if team is "Reds" or team is "reds"
			city = "Cincinnati"
		else if team is "Cubs" or team is "cubs" or team is "cubbies" or team is "Cubbies"
			city = "Chi Cubs"
		else if team is "Brewers" or team is "brewers"
			city = "Milwaukee"
		else if team is "Cardinals" or team is "cardinals" or team is "cards" or team is "Cards"
			city = "St. Louis"
		else if team is "Pirates" or team is "pirates"
			city = "Pittsburgh"
		else if team is "Phillies" or team is "phillies"
			city = "Philadelphia"
		else if team is "Mets" or team is "mets"
			city = "NY Mets"
		else if team is "Braves" or team is "braves"
			city = "Atlanta"
		else if team is "Marlins" or team is "marlins"
			city = "Miami"
		else if team is "Nationals" or team is "nationals" or team is "Nats" or team is "nats"
			city = "Washington"
		else if team is "Rays" or team is "rays"
			city = "Tampa Bay"
		else
			city = "I don't know the " + team

