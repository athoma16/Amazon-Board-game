# Description: This is the class representation of a Game session between two players.
# This class holds everything needed for the game including the Board and the Players,
# and the underlying GameEngine.
require 'terminal-table'

class Table
	# - game_board: Board
	# - game_engine: GameEngine
	# - player_lobby: Lobby
	# - game_players: Array (Player)

	def initialize
		@game_players = []
		@highlight = []
	end

	# Adds the Player to the array of game_players
	def add_player(new_player)
		@game_players.append(new_player)
	end

	# Response method to a user action sent from the
	# client, this method will take an action based on the request_type
	# The return value of this method has two notable
	# key-value pairs:
	#
	# :success → Set to true or false based on the return
	# result of the GameEngine’s method call.
	#
	# :display_data → Any additional information that
	# should be passed to the client as a result of the
	# requested, and can be null.
	def handle_player_request(player_id, request_type, request_params)
		success = false
		result = nil
		
		# “forfeit”: the end_game method will be called, 
		# and the returning value should be returned.
		if request_type == :forfeit
			result = end_game
			success = true
		
		# “move”: the move_amazon method of GameEngine
		# will be called.
		elsif request_type == :move
			success = @game_engine.move_amazon(request_params[:player_color], request_params[:start_tile], request_params[:end_tile])
			# update_ui
		
		# “rematch”: the reset_game method will be called.
		elsif request_type == :rematch
			success = reset_game
			update_ui

		# “select”: the select_amazon method of
		# GameEngine will be called.
		elsif request_type == :select
			result = @game_engine.select_amazon(request_params[:player_color], request_params[:tile_position])
			success = true
			@highlight = result
			update_ui
		
		# "shoot”: the place_arrow method of GameEngine
		# will be called. Since this is the final action required
		# for a Player’s turn, the toggle_current_turn method
		# of GameEngine should be invoked to set the turn
		# colour to the opposing Player.
		elsif request_type == :shoot
			success = @game_engine.place_arrow(request_params[:player_color], request_params[:start_tile], request_params[:end_tile])
			# Check if placing arrow failed, if so return the situation
			if success == false
				return { :success => false, :display_data => nil}
			else
				result = @game_engine.toggle_current_turn
				update_ui
			end
		end

		return { :success => success, :display_data => result}
	end

	# Sets up a new game session with the current
	# Players by creating a Board followed by a
	# GameEngine with the created Board.
	def setup_game
		@game_board = Board.new
		@game_engine = GameEngine.new(@game_board)
		update_ui
	end

	private

	# PRIVATE
	# Called in response to a Player’s request to forfeit
	# the game, this method calls determine_winner() of
	# GameEngine to get the winning player by piece
	# colour.
	# The winning player colour is returned at the end of
	# this method.
	# Returns symbol
	def end_game
		return @game_engine.determine_winner
	end

	# PRIVATE
	# Checks both Players of game_players and returns
	# the one matching the passed player_id.
	def find_player_by_id(player_id)
		return @game_players.detect{ |player| player.player_id == player_id }
	end

	# PRIVATE
	# This method will reset the Board and GameEngine
	# to support a rematch between Players by doing the
	# following:
	# 1. Calling the reset() method of Board
	# 2. Calling the reset_amazons() method of GameEngine
	# Returns void
	def reset_game
		@game_engine.reset_amazons
		@game_board.reset
	end

	# PRIVATE
	# Method to print out the updated board 
	def update_ui
		table = Terminal::Table.new do |t|
			t.style = { :border_bottom => false }
			for i in (0..9)
				row = [ ]

				if i == 0
					row.append("A")
				elsif i == 1
					row.append("B")
				elsif i == 2
					row.append("C")
				elsif i == 3
					row.append("D")
				elsif i == 4
					row.append("E")
				elsif i == 5
					row.append("F")
				elsif i == 6
					row.append("G")
				elsif i == 7
					row.append("H")
				elsif i == 8
					row.append("I")
				elsif i == 9
					row.append("J")
				end

				for j in (0..9)
			 		# Get index of item to add to table
					index = i*10 + j
					piece = @game_board.tiles[index].piece
					piece_str = nil
					if (piece == 'empty') || (piece == nil)
						if (@highlight.include? index)
							piece_str = '.'
						else
							piece_str = ' '
						end
					elsif (piece == 'white_queen')
						piece_str = 'W'
					elsif (piece == 'black_queen')
						piece_str = 'B'
					elsif (piece == 'arrow')
						piece_str = '*'
					end
					row.append(piece_str)
				end
				t << row
				if (i != 9)
					t.add_separator
				end
			end
			t.add_separator
			t << ['', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
		end
		@highlight = [] # reset highlighted moves
		puts _format_table(table)
	end

	def _format_table(table)
		table_str = table.to_s
		table_str.gsub!(/^\+---/, '    ')
		table_str.gsub!(/^\|/, ' ')
		table_str.gsub!(/\| (\d+) \|/, '  \1  ')
		table_str[-1] = ' '
		table_str # Returns string
	end

end
