	#!/usr/bin/env ruby
# encoding: utf-8
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

n = ARGV[0]

puts n.to_s

json = plurk.post("/APP/Timeline/plurkAdd", \
							{:limited_to=>"[13783845, 4017042]", \
							:content=>"阿冷第 " + n.to_s + " 次重開 (nottalking)", \
							:qualifier=>":"})

puts json
