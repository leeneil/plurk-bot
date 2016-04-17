def battleship_print(game, rival)
	
 

	for line in game
		line = line.join('')
		if rival
			line = line.gsub(/[_S]/, '?')
		end
		puts line
	end

end