def battleship_pc(game)
	
	game_size = ( game.size ).to_i
 
	sel = 'M'

	while sel == 'M' or sel == 'H'
		u = rand(game_size)
		v = rand(game_size)
		sel = game[u][v]
	end

	# puts (u+65).chr + (v+1).to_s
	return (u+65).chr + (v+1).to_s

end