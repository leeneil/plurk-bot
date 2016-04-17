def battleship_attack(game, cor)
	
	msg = ''

	game_size = game.size

	if game_size == 4
		if cor.scan(/[a-dA-D][1-4]/).empty?
			msg = "Wrong coordinate"
			return msg
		end
		cor = cor.scan(/[a-dA-D][1-4]/)[0]
	elsif game_size == 6
		if cor.scan(/[a-fA-F][1-6]/).empty?
			msg = "Wrong coordinate"
			return msg
		end	
		cor = cor.scan(/[a-fA-F][1-4]/)[0]
	elsif game_size == 9
		if cor.scan(/[a-iA-I][1-9]/).empty?
			msg = "Wrong coordinate"
			return msg
		end
		cor = cor.scan(/[a-iA-I][1-9]/)[0]
	end




	# dict = {'A'=>0, 'a'=>0, 'B'=>1, 'b'=>1, 'C'=>2, 'c'=>2, 'D'=>3, 'd'=>3, 'E'=>4, 'e'=>4, 'F'=>5, 'f'=>5}
	row = cor[0].upcase.ord-65
	col = cor[1].to_i - 1

	if game[row][col] == '_'
		msg = 'miss!'
		game[row][col] = 'M'
	elsif game[row][col] == 'S'
		msg = 'hit!!'
		game[row][col] = 'H'
	else
		msg = 'this spot has been previously taken...'
	end
	
	return msg	

end