def battleship_print_for_plurk(game, rival)
	msg = ""
	game_size = game.size
 

	for u in 0..(game_size-1)
		for v in 0..(game_size-1)
			msg = msg + '[' + (u+97).chr + (v+1).to_s + ']'
		end
	end


	for u in 0..(game_size-1)
		for v in 0..(game_size-1)
			offset = u*(4*game_size) + 4*v
			c = game[u][v]
			if c == 'S' and not rival
				msg[offset..(offset+3)] = "[sp]"
			elsif c == 'M'
				msg[offset..(offset+3)] = "[wt]"
			elsif c == 'H'
				msg[offset..(offset+3)] = "[rd]"
			end
		end
	end

	msg2 = ""

	for u in 0..(game_size-1)
		msg2 = msg2 + msg[ (u*game_size*4)..((u+1)*4*game_size-1) ] + "\n      \n      \n"
	end

	return msg2

end

					
				 	 