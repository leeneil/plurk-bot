def ooxx_pc(game, player, hard)

	require "./ooxx_score"

	if hard.nil?
		puts "hardness = " + hard.to_s
		hard = 0.6
	end
	puts "hardness = " + hard.to_s

	if rand > hard

		# random step
		puts "[random step]"
		move = rand(9)
		while game[move] != '_'
			move = rand(9)
		end
		game[move] = player
		return game

	else

		# best step
		if player == 'O'
			opp = 'X'
		else
			opp = 'O'
		end
		best_step = 0
		best_score = 0
		for u in 0..8
			score = 0
			if game[u] == '_'
				tmp1 = game.dup
				tmp1[u] = player
				tmp2 = game.dup
				tmp2[u] = opp
				score = ooxx_score(tmp1, player) + 0.5*ooxx_score(tmp2, opp)
				if score > best_score
					best_score = score
					best_step = u
				end
			end
		end
		game[best_step] = player
		return game

	end

end