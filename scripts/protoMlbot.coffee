module.exports = (robot) ->
	robot.hear /test/, (msg) ->
		team = "mariners"
		city = "Seattle"

		getScore "today", (score) ->
			msg.send score

	getScore = (day, callback) ->
		day = '25'
		month = '03'
		year = '2016'

		url = 'http://mlb.mlb.com/gdcross/components/game/mlb/year_' + year + '/month_' + month + '/day_' + day + '/master_scoreboard.json'

		robot.http(url)
			.get() (err, res, body) ->
				gameData = JSON.stringify(body)
				callback(gameData)