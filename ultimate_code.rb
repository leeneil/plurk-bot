#!/usr/bin/env ruby
# encoding: utf-8
require "time"
require "../PlurkOAuth/plurk.rb"
require "./check_answer"

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

code_keywords = ["終極密碼"]
aabb_keywords = ["猜數字"]
# keywords = ["每日一冷", "冷知識", "你知道嗎", "阿冷","難過","還是會","下雨","那一年","那些年","無言","掰噗","林怡","芋頭","盧董","五月天"]

responses = JSON.parse( open("responses.json").read )

# build keyword list
keywords = []
responses.each do |key, value|
	keywords << key
end

random_emojis = ["(gfuu)", "(gyay)", "(gbah)", "(gtroll)", "(gaha)", "(gwhatever)", "(gpokerface)", "(gyea)"]


code_sessions = {}
aabb_sessions = {}

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

	last_time = Time.now.utc
	
	users = json["plurk_users"]
	plurks = json["plurks"]

	if plurks.size < 1
		no_plurk = true
		# puts "no new plurks" + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
	else
		for p in plurks
			replied = false
			pid = p["plurk_id"]
			puts "@" + users[ p["owner_id"].to_s ]["nick_name"] \
				+ " \\ " + users[ p["owner_id"].to_s ]["display_name"]
			puts "says: " + p["content_raw"]
			# search for new games first
			# ultimate code game
			for keyword in code_keywords
				key_match = p["content_raw"].match(keyword)
				unless key_match.nil?
					puts "Keyword " + keyword + " identified!"
	
					if code_sessions[ pid ].nil?
						puts "Starting a new ultimate code game" + " (" + pid.to_s + ")" 
						ans = rand(9999)
						puts "Ans = " + ans.to_s
						code_sessions[ pid ] \
							= {:ans=>ans, :last_guess=>-1, :end=>false, :bot=>1, :player=>-1, :min=>0, :max=>9999}
						plurk.post("/APP/Responses/responseAdd", \
							{:plurk_id=>pid, \
							:content=>"遊戲開始！ 0~9999 (code)", \
							:qualifier=>"is"})
						replied = true			

					end
				end
			end
			# AABB game
			for keyword in aabb_keywords
				key_match = p["content_raw"].match(keyword)
				unless key_match.nil? or replied
					puts "Keyword " + keyword + " identified!"
	
					if aabb_sessions[ pid ].nil?
						puts "Starting a new AABB game" + " (" + pid.to_s + ")" 
						ans = 1000 + rand(9000)
						puts "Ans = " + ans.to_s
						aabb_sessions[ pid ] \
							= {:ans=>ans, :last_guess=>-1, :end=>false, :bot=>1, :player=>-1}
						plurk.post("/APP/Responses/responseAdd", \
							{:plurk_id=>pid, \
							:content=>"遊戲開始！ 1000~9999 (code_okok)", \
							:qualifier=>"is"})
						replied = true	

					end
				end
			end
			# otherwise search for other keywords
			
			for keyword in keywords
				key_match = p["content"].match(keyword)
				unless key_match.nil? or  replied
					puts "Keyword " + keyword + " identified!"
					msg = responses[keyword]
					puts "reply: " + msg
					plurk.post("/APP/Responses/responseAdd", \
						{:plurk_id=>pid, \
						:content=>msg, \
						:qualifier=>"says"})
					replied = true			
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
				# continue ultimate code game
				unless code_sessions[ pid ].nil? or code_sessions[ pid ][:end]
					res_json = plurk.post("/APP/Responses/get", \
						{:plurk_id=>pid})
					n_res = res_json["response_count"]
					# puts n_res
					# puts code_sessions[pid][:bot]
					ans = code_sessions[ pid ][:ans]
					if n_res > code_sessions[pid][:bot]
						last_guess = code_sessions[pid][:last_guess]
						new_guess = res_json["responses"][n_res-1]["content_raw"].to_i
						puts "new guess captured: " + new_guess.to_s  + " (" + pid.to_s + ")" 
						code_sessions[ pid ][:last_guess] = new_guess
						code_sessions[ pid ][:player] = n_res
						code_sessions[ pid ][:bot] = n_res + 1
				
						if new_guess == ans
							msg = new_guess.to_s+"! 你爆炸惹 (taser_okok)" 
							puts msg + " (" + pid.to_s + ")"  + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
							plurk.post("/APP/Responses/responseAdd", \
								{:plurk_id=>pid, \
								:content=>msg, \
								:qualifier=>"loves"})
							code_sessions[ pid ] \
								= {:ans=>ans, :last_guess=>new_guess, :end=>true, :bot=>n_res+1, :player=>n_res}
						else
							if new_guess > ans and new_guess < code_sessions[pid][:max]
								code_sessions[pid][:max] = new_guess
							end
							if new_guess < ans and new_guess > code_sessions[pid][:min]
								code_sessions[pid][:min] = new_guess
							end
							if code_sessions[pid][:max] - code_sessions[pid][:min] == 2
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
								code_sessions[ pid ] \
								= {:ans=>ans, :last_guess=>new_guess, :end=>true, :bot=>n_res+1, :player=>n_res}
							else
								if new_guess > ans
									if new_guess < code_sessions[pid][:max]
										code_sessions[pid][:max] = new_guess
									end
									msg = code_sessions[pid][:min].to_s + " ~ " + code_sessions[pid][:max].to_s
									puts msg + " (" + pid.to_s + ")" 
									plurk.post("/APP/Responses/responseAdd", \
									{:plurk_id=>pid, \
									:content=>msg, \
									:qualifier=>"feels"})
								else
									if new_guess > code_sessions[pid][:min]
										code_sessions[pid][:min] = new_guess
									end
									msg = code_sessions[pid][:min].to_s + " ~ " + code_sessions[pid][:max].to_s
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
				# continue AABB game
				unless aabb_sessions[ pid ].nil? or aabb_sessions[ pid ][:end]
					res_json = plurk.post("/APP/Responses/get", \
						{:plurk_id=>pid})
					n_res = res_json["response_count"]
					ans = aabb_sessions[ pid ][:ans]
					if n_res > aabb_sessions[pid][:bot]
						new_guess = res_json["responses"][n_res-1]["content_raw"].to_i
						puts "new guess captured: " + new_guess.to_s  + " (" + pid.to_s + ")" 
						aabb_sessions[ pid ][:last_guess] = new_guess
						aabb_sessions[ pid ][:player] = n_res
						aabb_sessions[ pid ][:bot] = n_res + 1
						if new_guess == ans
							msg = "4A0B！恭喜你挑戰成功！ (dance_bzz) (dance_bzz) (dance_bzz)"
							puts msg + " (" + pid.to_s + ")"  + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
							plurk.post("/APP/Responses/responseAdd", \
							{:plurk_id=>pid, \
							:content=>msg, \
							:qualifier=>"hates"})
							aabb_sessions[ pid ][:end] = true
						else
							emoji = random_emojis[ rand(random_emojis.size) ]
							msg = check_answer(ans, new_guess) + " " + emoji
							puts msg + " (" + pid.to_s + ")"  + " @ " + Time.now.strftime("%Y-%m-%dT%H:%M:%S")
							plurk.post("/APP/Responses/responseAdd", \
							{:plurk_id=>pid, \
							:content=>msg, \
							:qualifier=>"feels"})
						end
					end
				end
			# mark as read
			plurk.post("/APP/Timeline/markAsRead", \
								{:ids=>[pid]})
		end
	end
	
	sleep(5)
end

