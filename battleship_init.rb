def battleship_init(game_size)
	
	game = []

	for t in 0..(game_size-1)
		game[t] = ['_'] * game_size
	end
	

	size_list = [2,3]


	for ship_size in size_list
		counter = 0
		while counter < ship_size
			counter = 0
			u = rand(game_size)
			v = rand(game_size-ship_size+1)
			ori = rand(2)
			if ori == 0
				for t in v..(v+ship_size-1)
					if game[u][t] == '_'
						counter = counter + 1
					end
				end
			else
				for t in v..(v+ship_size-1)
					if game[t][u] == '_'
						counter = counter + 1
					end
				end
			end	
		end		

		if ori == 0
			for t in v..(v+ship_size-1)
				game[u][t] = 'S'
			end
		else
			for t in v..(v+ship_size-1)
				game[t][u] = 'S'
			end
		end
	end

	return game

end