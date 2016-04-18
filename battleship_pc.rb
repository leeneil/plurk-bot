def battleship_pc(game)
	
	game_size = ( game.size ).to_i
 

	best_u = -1
	best_v = -1 
	best_score = 0

	for u in 0..(game_size-1)
		for v in 0..(game_size-1)
			if game[u][v] == 'M' or game[u][v] == 'H' 
				next
			end
			score = 0
			unless u == 0
				if game[u-1][v] == 'H'
					score = score + 10
				end
			end
			unless u == game_size-1
				if game[u+1][v] == 'H'
					score = score + 10
				end
			end
			unless v == 0
				if game[u][v-1] == 'H'
					score = score + 10
				end
			end
			unless v == game_size-1
				if game[u][v+1] == 'H'
					score = score + 10
				end
			end
			if score > best_score
				best_u = u
				best_v = v
				best_score = score
			end

		end
	end
	puts "best score: " + best_score.to_s
	if best_score == 0
		puts "[random step["
		sel = 'M'
		while sel == 'M' or sel == 'H'
			best_u = rand(game_size)
			best_v = rand(game_size)
			sel = game[best_u][best_v]
		end
	end

	# puts (u+65).chr + (v+1).to_s
	return (best_u+65).chr + (best_v+1).to_s

end