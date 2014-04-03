class Position
	X_WIN_SCORE = 100
	O_WIN_SCORE = -100
	TIE_SCORE   = 0

	attr_accessor :board, :turn

	def initialize board = nil, turn = "x"
	    @dim = 3
	    @size = @dim * @dim
		@board = board || Array.new(@size, "-")
		@turn, @movelist = turn, []
	end

	def next_turn
		@turn == "x" ? "o" : "x"
	end

	def move idx
		@board[idx] = @turn
		@turn = next_turn
		@movelist << idx
		self
	end

	def unmove
		@board[@movelist.pop] = "-"
		@turn = next_turn
		self
	end

	def possible_moves
		@board.map.with_index do |piece, idx| 
			piece == "-" ? idx : nil
		end.compact
	end

	def win_lines
		winning_lines = (0..@size.pred).each_slice(@dim).to_a
		winning_lines.concat((0..@size.pred).each_slice(@dim).to_a.transpose)
		winning_lines.concat([(0..@size.pred).step(@dim.succ).to_a])
		winning_lines.concat([(@dim.pred..(@size - @dim)).step(@dim.pred).to_a])

		winning_lines.map do |line| 
			line.map { |idx| @board[idx]  }
		end
	end

	def win?(piece)
		win_lines.any? do |line| 
			line.all? { |line_piece| line_piece == piece }
		end
	end

	def blocked?
		win_lines.all? do |line| 
			line.any? { |line_piece| line_piece == "x" } &&
			line.any? { |line_piece| line_piece == "o" }
		end		
	end

	def evaluate_leaf
		return X_WIN_SCORE if win?("x")
		return O_WIN_SCORE if win?("o")
		return TIE_SCORE   if blocked?
	end

	def minimax(idx=nil)
		move(idx) if idx
		leaf_value = evaluate_leaf
		return leaf_value if leaf_value
		possible_scores = possible_moves.map do |idx| 
			plus_or_minus = @turn == "x" ? :- : :+
			minimax(idx).send(plus_or_minus, @movelist.count + 1) 
		end
		max_or_min = @turn == "x" ? :max : :min
		possible_scores.send(max_or_min)
	ensure
		unmove if idx
	end

	def best_move
		max_or_min_by = @turn == "x" ? :max_by : :min_by
		possible_moves.send(max_or_min_by) do |idx| 
			minimax(idx)
		end
	end

	def end?
		win?("x") || win?("o") || @board.count("-") == 0
	end

	def to_s
		@board.each_slice(@dim).map do |line| 
			" "	+ line.map { |piece| piece == "-" ? " " : piece }.join(" | ") +
			" "
		end.join("\n-----------\n") + "\n"
	end
end


class TTT
	def ask_for_player
		puts "Who do you want to play first?"
		puts "1. Human"
		puts "2. Computer"
		while true
			print "choice: "	
			who_starts = gets.chomp
			return "human" 		if who_starts == "1"
			return "computer" 	if who_starts == "2"
		end
	end

	def ask_for_move position
		while true
			print "move: "
			next_move = gets.chomp
			if next_move =~ /^\d+$/ && position.board[next_move.to_i] == "-"
				return next_move.to_i
			end
		end
	end

	def other_player
		@player == "human" ? "computer" : "human"
	end

	def play_game
		@player = ask_for_player
		position = Position.new
		while !position.end?
			puts position
			puts
			move_position = @player == "human" ? ask_for_move(position) : position.best_move
			position.move(move_position)
			@player = other_player
		end
		puts position
		position.blocked? ? (puts "draw") : "winner: #{other_player}"
	end
end


if __FILE__ == $0
	TTT.new.play_game
end




