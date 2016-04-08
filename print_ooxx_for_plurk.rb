def print_ooxx_for_plurk(game)
	buffer \
		= "[_1][_2][_3]" \
		+ "[_4][_5][_6]" \
		+ "[_7][_8][_9]"
	for u in 0..8
		if game[u] == 'O'
			buffer[ (4*u+0)..(4*u+3) ] = "[_o]"
		elsif game[u] == 'X'
			buffer[ (4*u+0)..(4*u+3) ] = "[_x]"
		end
	end
	buffer \
		= buffer[00..11] + "   \n   \n" \
		+ buffer[12..23] + "   \n   \n" \
		+ buffer[24..35]
	# puts buffer
	return buffer	
end