def ooxx_tie(game)

	require "./ooxx_score"
	require "./ooxx_pc"

	game = game.dup

	if ooxx_score( ooxx_pc(game, 'O', 1.0), 'O' ) < 100 and ooxx_score( ooxx_pc(game, 'X', 1.0), 'X' ) < 100
		return true
	else
		return false
	end

end