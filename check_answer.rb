# encoding: utf-8
def check_answer(ans, guess)
	a_count = 0
	b_count = 0
	a_taken = [false, false, false, false]
	b_taken = [false, false, false, false]
	if guess < 1000 or guess > 9999
		return "您的答案必須是 1000 到 9999 之間的整數 (no_dance)"
	else
		guess_str = guess.to_s
		ans_str = ans.to_s
		for t in 0..3
			if guess_str[t] == ans_str[t]
				a_taken[t] = true
				b_taken[t] = true
				a_count = a_count + 1
			end
		end
		# puts taken
		for t in 0..3 # answer position
			for v in 0..3 # guess position
				unless v == t or a_taken[t] or b_taken[v]
					if guess_str[v] == ans_str[t]
						a_taken[t] = true
						b_taken[v] = true
						b_count = b_count + 1
					end
				end
			end
		end
		# puts taken
		return a_count.to_s + "A" + b_count.to_s + "B"
	end
end