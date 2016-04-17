require "./battleship_init"
require "./battleship_print"
require "./battleship_print_for_plurk"
require "./battleship_attack"
require "./battleship_end"
require "./battleship_pc"

game_size = 4

player1 = battleship_init(game_size)
player2 = battleship_init(game_size)

game_end = false


# puts player1.join("").join("")

while not game_end
	puts "attack on player 2: "
	cor = gets
	puts battleship_attack(player2, cor)
	battleship_print(player2, false)
	# puts battleship_print_for_plurk(player2, true)

	if battleship_end(player2)
		puts "player 1 wins!"
		game_end = true
		break
	end

	puts "attack on player 1: "
	cor = battleship_pc(player1)
	puts battleship_attack(player1, cor)
	battleship_print(player1, false)
	# puts battleship_print_for_plurk(player1, true)

	if battleship_end(player1)
		puts "player 2 wins!"
		game_end = true
		break
	end

end