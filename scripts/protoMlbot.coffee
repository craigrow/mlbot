module.exports = (robot) ->
	robot.hear /test/, (msg) ->
		team = "mariners"
		city = "Seattle"

		testData = {}
		testData.elementOne = "bazinga"
		msg.send testData.elementOne

		getScore "today", (gameData) ->
			msg.send gameData.homeCity

	getScore = (day, callback) ->
		gameData = {}
		day = '25'
		month = '03'
		year = '2016'

		url = 'http://mlb.mlb.com/gdcross/components/game/mlb/year_' + year + '/month_' + month + '/day_' + day + '/master_scoreboard.json'

		robot.http(url)
			.get() (err, res, body) ->
				data = JSON.parse(body)
				gameData.homeCity = data.data.games.game[0].home_team_city

				callback(gameData)