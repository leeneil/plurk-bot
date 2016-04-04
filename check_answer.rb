# encoding: utf-8
def check_answer(ans, guess)
	a_count = 0
	b_count = 0
	if guess < 1000 or guess > 9999
		return "您的答案必須是 1000 到 9999 之間的整數 (angry)"
	else
		guess_str = guess.to_s
		ans_str = ans.to_s
		for t in 0..3
			if guess_str[t] == ans_str[t]
				a_count = a_count + 1
			else
				for v in 0..3
					unless v == t
						if guess_str[t] == ans_str[v]
							b_count = b_count + 1
						end
					end
				end
			end
		end
		return a_count.to_s + "A" + b_count.to_s + "B"
	end
end