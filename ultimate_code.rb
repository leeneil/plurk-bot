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

keywords = ["終極密碼"]

play_sessions = {}

while true 
	# add new friends
	json = plurk.post("/APP/FriendsFans/getFriendshipRequests")

	users = json["users"]

	if users.size < 1
		puts "no new friend requests"
	else
		for user in users
			puts "@" + user["nick_name"]
			puts user["display_name"]
			
		end
		rep_json = plurk.post("/APP/Alerts/addAllAsFriends")
		puts rep_json
	end

	# search for new games
	json = plurk.post("/APP/Polling/getPlurks", \
		{:offset=>last_time.strftime("%Y-%m-%dT%H:%M:%S")})

	users = json["plurk_users"]
	plurks = json["plurks"]

	if plurks.size < 1
		puts "no new plurks" + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
	else
		for p in plurks
			pid = p["plurk_id"]
			for keyword in keywords
				key_match = p["content"].match(keyword)
				unless key_match.nil?
					puts "Keyword " + keyword + " identified!"
					puts "@" + users[ p["owner_id"].to_s ]["nick_name"] \
						+ " \\ " + users[ p["owner_id"].to_s ]["display_name"]
						puts "\t" + p["content"]
					if play_sessions[ pid ].nil?
						puts "Starting a new game"
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
		end
	end

	# search for existing games
	json = plurk.post("/APP/Timeline/getUnreadPlurks")
	plurks = json["plurks"]
	if plurks.size < 1
		puts "no plurk responses" + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
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
						puts "new guess captured: " + new_guess.to_s
						play_sessions[ pid ][:last_guess] = new_guess
						play_sessions[ pid ][:player] = n_res
						play_sessions[ pid ][:bot] = n_res + 1
				
						if new_guess == ans
							puts "answer hit! (" + ans.to_s + ")"
							plurk.post("/APP/Responses/responseAdd", \
								{:plurk_id=>pid, \
								:content=>new_guess.to_s+"! 你爆炸惹 (LOL)", \
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
								puts msg
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
									puts msg
									plurk.post("/APP/Responses/responseAdd", \
									{:plurk_id=>pid, \
									:content=>msg, \
									:qualifier=>"feels"})
								else
									if new_guess > play_sessions[pid][:min]
										play_sessions[pid][:min] = new_guess
									end
									msg = play_sessions[pid][:min].to_s + " ~ " + play_sessions[pid][:max].to_s
									puts msg
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

