def battleship_end(game)
	

	s_count = 0
	for line in game
		line = line.join('')
		s_count = s_count + line.scan(/S/).size
	end

	if s_count > 0
		return false 
	else
		return true
	end

end