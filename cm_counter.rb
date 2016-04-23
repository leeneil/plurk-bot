def cm_counter(counter)
	words = "廣東炒麵"
	k = 0.5 * (-9 + Math.sqrt(81+8*counter))
	n = 0.5* (9*k.floor+(k.floor)**2)
	# puts "k = " + k.to_s
	# puts "n = " + n.to_s
	if n - counter == 0
		return "辣"
	elsif counter - n < 5
		return words[ counter - n - 1 ]
	else
		return "辣"
	end
end