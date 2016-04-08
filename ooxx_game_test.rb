require "./print_ooxx"
require "./print_ooxx_for_plurk"
require "./ooxx_score"
require "./ooxx_pc"

game = "_________"
game[rand(9)] = 'X'

# print_ooxx(game)
print_ooxx_for_plurk(game)

counter = 1
win = false

while not win
	if counter > 3
		puts "和局！"
		break
	end
	player_done = false
	while not player_done
		player = gets.to_i
		if player < 1 or player > 9
			puts "請輸入 1~9 選擇位置"
		elsif game[player-1] != '_'
			puts "位置 " + player.to_s + " 已經下過了，請重選"
		else
			player_done = true
		end
	end
	game[player-1] = 'O'
	print_ooxx(game)
	print_ooxx_for_plurk(game)
	if ooxx_score(game, 'O') > 100
		win = true
		puts "玩家獲勝"
		break
	end
	game = ooxx_pc(game, 'X')
	print_ooxx(game)
	print_ooxx_for_plurk(game)
	if ooxx_score(game, 'X') > 100
		win = true
		puts "阿冷獲勝"
		break
	end
	counter = counter + 1
end
