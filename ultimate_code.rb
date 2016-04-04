#!/usr/bin/env ruby
# encoding: utf-8
require "time"
require "../PlurkOAuth/plurk.rb"

lines = STDIN.read.split("\n")
CONSUMER_KEY = lines[0]
COMSUMER_SECRET = lines[1]
ACCESS_TOKEN = lines[2]
ACCESS_TOKEN_SECRET = lines[3]

plurk = Plurk.new(CONSUMER_KEY, \
	COMSUMER_SECRET)

plurk.authorize(ACCESS_TOKEN, \
	ACCESS_TOKEN_SECRET)

last_time = Time.now.utc

game_keywords = ["終極密碼"]
# keywords = ["每日一冷", "冷知識", "你知道嗎", "阿冷","難過","還是會","下雨","那一年","那些年","無言","掰噗","林怡","芋頭","盧董","五月天"]
responses = {"每日一冷"=>"今天好熱，你每日一冷了嗎？ (sick) \n  www.dailycold.tw/?redirect_to=random (本日冷知識)", \
	"冷知識"=>"想找 www.dailycold.tw/?redirect_to=random (冷知識)？問阿冷就對惹  (griltongue) \n 你知道嗎？ ", \
	"你知道嗎"=>"你知道嗎？ (woot) \n www.dailycold.tw/?redirect_to=random (本日冷知識)", \
	"阿冷"=>"安安，我是阿冷 (wave) \n 在你的河道上噗**冷知識**我會提供一則冷知識給您 \n 噗**終極密碼**可以跟阿冷玩遊戲唷！  (goodluck)", \
	"那一年"=>"默默無言只能選擇離開 :-( \n https://www.youtube.com/watch?v=2Ii0kpKi8kI", \
	"那些年"=>"戳鍋der大魚 \n https://www.youtube.com/watch?v=xWzlwGVQ6_Q", \
	"難過"=>"的是？ \n https://www.youtube.com/watch?v=2Ii0kpKi8kI", \
	"無言"=>"只能選擇離開  (tears)\n https://www.youtube.com/watch?v=2Ii0kpKi8kI", \
	"56"=>"56不能亡！ \n https://www.youtube.com/watch?v=2Ii0kpKi8kI",\
	"五六"=>"五六不能亡！ \n https://www.youtube.com/watch?v=2Ii0kpKi8kI",\
	"5566"=>"56不能亡！ \n https://www.youtube.com/watch?v=2Ii0kpKi8kI",\
	"五五六六"=>"五六不能亡！ \n https://www.youtube.com/watch?v=2Ii0kpKi8kI",\
	"還是會"=>"害怕  :-o \n https://www.youtube.com/watch?v=eGNqW9sybyU", \
	"下雨天"=>"下雨天了怎麼辦我好想你 \n https://www.youtube.com/watch?v=HYFJcEJ20KU",\
	"下雨"=>"的聲音 \n https://www.youtube.com/watch?v=F2uX6ByoW7A", \
	"下大雨"=>"九索！",\
	"掰噗"=>"阿冷希望有一天也可以成為跟掰噗一樣的機器人！", 
	"林怡"=>"01 是每日一冷的女神 (worship)", \
	"盧董"=>"盧董以前可是很瘦的", \
	"芋頭"=>"阿冷最討厭吃芋頭了QQ",\
	"五月天"=>"突然好想你 你會在哪裡？\n https://www.youtube.com/watch?v=GtDRcXtDg-4",\
	"佐藤光"=>"佐藤光是阿亮最大的對手",\
	"塔矢亮"=>"塔矢亮是小光最大的對手",\
	"sai"=>"sai只是個軟體 (LOL)",\
	"alphago"=>"alphago 只是個軟體 (LOL)",\
	"初音"=>"初音只是個軟體 (goodluck)",\
	"真的"=>"真的假不了 (woot)",\
	"跑跑"=>"跑跑卡丁車 (woot)",\
	"噗噗"=>"did you mean: **噗浪**？",\
	"噗浪"=>"我愛噗浪 噗浪愛我 <3",\
	"好冷"=>"對不起QQ",\
	"好熱"=>"那來點 www.dailycold.tw/?redirect_to=random (冷知識) 吧 (heart) \n ",\
	"飲冰室茶集"=>"好兆，明天準是好天了。"}

# build keyword list
keywords = []
responses.each do |key, value|
	keywords << key
end

play_sessions = {}

puts "listening... @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")

while true 
	# add new friends
	json = plurk.post("/APP/FriendsFans/getFriendshipRequests")

	users = json["users"]

	if users.size < 1
		no_request = true
		# puts "no new friend requests"
	else
		for user in users
			puts "@" + user["nick_name"] + " \\ " + user["display_name"]	
		end
		rep_json = plurk.post("/APP/Alerts/addAllAsFriends")
		puts rep_json
	end

	# search for new plurks
	json = plurk.post("/APP/Polling/getPlurks", \
		{:offset=>last_time.strftime("%Y-%m-%dT%H:%M:%S")})

	users = json["plurk_users"]
	plurks = json["plurks"]

	if plurks.size < 1
		no_plurk = true
		# puts "no new plurks" + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
	else
		for p in plurks
			pid = p["plurk_id"]
			puts "@" + users[ p["owner_id"].to_s ]["nick_name"] \
				+ " \\ " + users[ p["owner_id"].to_s ]["display_name"]
			puts "says: " + p["content_raw"]
			# search for new games first
			for keyword in game_keywords
				key_match = p["content_raw"].match(keyword)
				unless key_match.nil?
					puts "Keyword " + keyword + " identified!"
	
					if play_sessions[ pid ].nil?
						puts "Starting a new game" + " (" + pid.to_s + ")" 
						ans = rand(9999)
						puts "Ans = " + ans.to_s
						play_sessions[ pid ] \
							= {:ans=>ans, :last_guess=>-1, :end=>false, :bot=>1, :player=>-1, :min=>0, :max=>9999}
						plurk.post("/APP/Responses/responseAdd", \
							{:plurk_id=>pid, \
							:content=>"遊戲開始！ 0~9999", \
							:qualifier=>"is"})	

					end
				end
			end
			# otherwise search for other keywords
			for keyword in keywords
				key_match = p["content"].match(keyword)
				unless key_match.nil?
					puts "Keyword " + keyword + " identified!"
					msg = responses[keyword]
					puts "reply: " + msg
					plurk.post("/APP/Responses/responseAdd", \
						{:plurk_id=>pid, \
						:content=>msg, \
						:qualifier=>"says"})	
				end
			end
			# mark as read
			plurk.post("/APP/Timeline/markAsRead", \
				{:ids=>[pid]})
		end
	end

	# search for existing games
	json = plurk.post("/APP/Timeline/getUnreadPlurks")
	plurks = json["plurks"]
	if plurks.size < 1
		no_plurk = true
		# puts "no plurk responses" + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
	else
		for p in plurks
			pid = p["plurk_id"]
				unless play_sessions[ pid ].nil? or play_sessions[ pid ][:end]
					res_json = plurk.post("/APP/Responses/get", \
						{:plurk_id=>pid})
					n_res = res_json["response_count"]
					# puts n_res
					# puts play_sessions[pid][:bot]
					ans = play_sessions[ pid ][:ans]
					if n_res > play_sessions[pid][:bot]
						last_guess = play_sessions[pid][:last_guess]
						new_guess = res_json["responses"][n_res-1]["content_raw"].to_i
						puts "new guess captured: " + new_guess.to_s  + " (" + pid.to_s + ")" 
						play_sessions[ pid ][:last_guess] = new_guess
						play_sessions[ pid ][:player] = n_res
						play_sessions[ pid ][:bot] = n_res + 1
				
						if new_guess == ans
							msg = new_guess.to_s+"! 你爆炸惹 (LOL)" 
							puts msg + " (" + pid.to_s + ")"  + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
							plurk.post("/APP/Responses/responseAdd", \
								{:plurk_id=>pid, \
								:content=>msg, \
								:qualifier=>"loves"})
							play_sessions[ pid ] \
								= {:ans=>ans, :last_guess=>new_guess, :end=>true, :bot=>n_res+1, :player=>n_res}
						else
							if new_guess > ans and new_guess < play_sessions[pid][:max]
								play_sessions[pid][:max] = new_guess
							end
							if new_guess < ans and new_guess > play_sessions[pid][:min]
								play_sessions[pid][:min] = new_guess
							end
							if play_sessions[pid][:max] - play_sessions[pid][:min] == 2
								msg = "我的村民都只會講英語，看來我該讓賢惹 :-&"
								puts msg
								plurk.post("/APP/Responses/responseAdd", \
								{:plurk_id=>pid, \
								:content=>msg, \
								:qualifier=>"was"})
								msg = "正確答案是 " + ans.to_s + "，恭喜你挑戰成功！ (wave) (wave) (wave)"
								puts msg + " (" + pid.to_s + ")"  + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
								plurk.post("/APP/Responses/responseAdd", \
								{:plurk_id=>pid, \
								:content=>msg, \
								:qualifier=>"has"})
								play_sessions[ pid ] \
								= {:ans=>ans, :last_guess=>new_guess, :end=>true, :bot=>n_res+1, :player=>n_res}
							else
								if new_guess > ans
									if new_guess < play_sessions[pid][:max]
										play_sessions[pid][:max] = new_guess
									end
									msg = play_sessions[pid][:min].to_s + " ~ " + play_sessions[pid][:max].to_s
									puts msg + " (" + pid.to_s + ")" 
									plurk.post("/APP/Responses/responseAdd", \
									{:plurk_id=>pid, \
									:content=>msg, \
									:qualifier=>"feels"})
								else
									if new_guess > play_sessions[pid][:min]
										play_sessions[pid][:min] = new_guess
									end
									msg = play_sessions[pid][:min].to_s + " ~ " + play_sessions[pid][:max].to_s
									puts msg + " (" + pid.to_s + ")" 
									plurk.post("/APP/Responses/responseAdd", \
									{:plurk_id=>pid, \
									:content=>msg, \
									:qualifier=>"feels"})

								end
							end	
						end
					end


				end
			# mark as read
			plurk.post("/APP/Timeline/markAsRead", \
								{:ids=>[pid]})
		end
	end
	last_time = Time.now.utc
	sleep(5)
end

