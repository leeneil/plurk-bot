def ooxx_score(game, player)
	a = ["   ", "   ", "   "]
	a[0] = game[0..2]
	a[1] = game[3..5]
	a[2] = game[6..8]
	score = 0
	# check row&column
	for u in 0..2
		# check for 2-node 
		for v in 0..1
			if a[u][v] == player and a[u][v+1] == player
				score = score + 5
			end
			if a[v][u] == player and a[v+1][u] == player
				score = score + 5
			end
		end
		# check for 3-node
		if a[u][0] == player and a[u][1] == player and a[u][2] == player
				score = score + 100
		end
		if a[0][u] == player and a[1][u] == player and a[2][u] == player
				score = score + 100
		end
	end
	
	for u in 0..1
		# check \ direction
		if a[u][u] == player and a[u+1][u+1] == player
			score = score + 5
		end
		# check / direction
		if a[u][2-u] == player and a[u+1][1-u] == player
			score = score + 5
		end
	end
	# check for \ 3 node
	if a[0][0] == player and a[1][1] == player and a[2][2] == player
			score = score + 100
	end
	# check for / 3 node
	if a[0][2] == player and a[1][1] == player and a[2][0] == player
			score = score + 100
	end


	# puts score
	return score

end