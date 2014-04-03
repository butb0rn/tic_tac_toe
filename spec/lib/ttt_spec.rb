require 'spec_helper'
require 'ttt'

describe Game do
  context '.new' do
  	it "initializes a new board" do
  		game = Game.new
  		game.board.should == %w(
        - - -
  			- -	-
  			- - -)
		  game.turn.should == "x"
  	end	

  	it "initializes a game given a board and turn" do
  		game = Game.new(%w(
        - x -	
  			- - -
  			- o -), "o")
  		game.board.should == %w(
        - x -	
  			- - -
  			- o -)
		  game.turn.should == "o"
  	end
  end

  context '.move' do
  	it "makes a move" do
  		game = Game.new.move(0)
  		game.board.should == %w(
        x - - 
  			- - -
  			- - -)
  	end

  end

  context '.unmove' do
  	it "undo a move " do
  		game = Game.new.move(1).unmove
  		init = Game.new
  		game.board.should == init.board
  		game.turn.should == init.turn
  	end
  end

  context '.possible_moves' do
  	it "lists possible moves for initial game" do
  		Game.new.possible_moves.should == (0..8).to_a
  	end

  	it "lists possible moves for a game" do
  		Game.new.move(3).possible_moves.should == [0,1,2,4,5,6,7,8]
  	end  	
  end

  context '.win_lines' do
  	it "finds winning columns, rows, diagonals" do
  		win_lines = Game.new(%w(
        0 1 2
  			3 4 5
  			6 7 8)).win_lines
      win_lines.count.should == 8
  		win_lines.should include(["0","1","2"])
  		win_lines.should include(["3","4","5"])
  		win_lines.should include(["6","7","8"])
      win_lines.should include(["0","3","6"])
  		win_lines.should include(["1","4","7"])
  		win_lines.should include(["2","5","8"])
  		win_lines.should include(["0","4","8"])
  		win_lines.should include(["2","4","6"])
  	end
  end

  context '.win?' do
  	it "determines no win" do
  		Game.new.win?("x").should == false
  		Game.new.win?("o").should == false
  	end

  	it "determines a win for x" do
  		Game.new(%w(
        x x x
  			- - -
  			- o o)).win?("x").should == true
  	end

  	it "determines a win for o" do
  		Game.new(%w(
        x x -
  			- - -
  			o o o)).win?("o").should == true
  	end
  end

  context '.blocked' do
  	it "determines not blocked" do
  		Game.new.blocked?.should == false
  	end

  	it "determines blocked" do
  		Game.new(%w(
        x o x
  			o x x 
  			o x o)).blocked?.should == true
  	end
  end

  context '.evaluate_leaf' do
  	it "determines nothing from initial game" do
  		Game.new.evaluate_leaf.should == nil
  	end
  	
  	it "determines a won game for x" do
  		Game.new(%w(
        x - - 
  			o x - 
  			o - x)).evaluate_leaf.should == 100
  	end

  	it "determines a won game for o" do
  		Game.new(%w(
        o x - 
  			o x - 
  			o - x), "o").evaluate_leaf.should == -100
  	end

  	it "determines a blocked game" do
  		Game.new(%w(
        o x o 
  			o x - 
  			x o x), "x").evaluate_leaf.should == 0
  	end
  end

  context '.minimax' do
  	it "determines an already won game" do
  		Game.new(%w(
        x x - 
  			x o o 
  			x o o)).minimax.should == 100
  	end

  	it "determines a win in 1 for x" do
  		Game.new(%w(
        x x -
  			- - -
  			- o o), "x").minimax.should == 99
  	end

  	it "determines a win in 1 for o" do
  		Game.new(%w(
        x x -
  			- - -
  			- o o), "o").minimax.should == -99
  	end
  end

  context '.best_move' do
  	it "finds the winning move for x" do
  		Game.new(%w(
        x x -
  			- - -
  			- o o), "x").best_move.should == 2
  	end

  	it "finds the winning move for o" do
  		Game.new(%w(
        x x -
  			- - -
  			- o o), "o").best_move.should == 6
  	end
  end

  context '.end?' do
  	it "sees a game has not ended" do
  		Game.new.end?.should == false
  	end

  	it "sees a game has ended due to win for x" do
  		Game.new(%w(
        - - x
  			- - x
  			o o x)).end?.should == true
  	end

  	it "sees a game has ended due to win for o" do
  		Game.new(%w(
        - - x
  			- - x
  			o o o)).end?.should == true
  	end

  	it "sees a game has ended due to no more moves" do
  		Game.new(
        %w(x o x
  				 x o x
  				 o x o)).end?.should == true
  	end
  end

  context '#to_s' do
  	it "represents a game" do
  		Game.new.move(3).move(4).to_s.should == <<-EOS
   |   |   
-----------
 x | o |   
-----------
   |   |   
  	  EOS
  	end
  end
end

describe "TTT" do
  context '#ask_for_player' do
  	it "asks who would play first" do
	  	ttt = TTT.new
	  	ttt.stub(:gets => "1\n")
	  	ttt.stub(:puts)
	  	ttt.stub(:print)
	  	ttt.ask_for_player.should == "human"	
  	end
  end

  context '#ask_for_move' do
  	it "asks for a valid move" do
  		game = Game.new
  		ttt = TTT.new
	  	ttt.stub(:gets => "1\n")
	  	ttt.stub(:puts)
	  	ttt.stub(:print)
	  	ttt.ask_for_move(game).should == 1
  	end  	
  end
end