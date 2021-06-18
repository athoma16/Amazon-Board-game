# Description: Class that validates the interactions between the Players and the Board.
# All requests are received from the associated Table, processed here, and delegated to
# the Board if marked as valid. The GameEngine ensures that the Players take turns in
# the correct order, and respond to requests related to a Players’ turn actions.

require 'set'
require_relative 'amazon'

class GameEngine

	#attr_accessor :AMAZON_START_POSITIONS, :game_board, :game_pieces, :current_turn

	# - AMAZON_START_POSITIONS: Array[int]
	# - game_board: Board
	# - game_pieces: Array[Amazon]
	# - current_turn: Symbol(:black, :white)

	def initialize(game_board)
		@game_board = game_board
		@AMAZON_START_POSITIONS = Array[3, 6, 30, 39, 60, 69, 93, 96]
		reset_amazons
	end

	# Determines the winner of the current game by
	# checking the remaining territory of each Player’s
	# Amazons and determining which Player has the
	# most possible remaining moves. The winning piece
	# colour is returned.
	# Returns player_colour
	def determine_winner
		#Unique territories with no double/triple/quadruple counting
		white_territory = Set.new
		black_territory = Set.new

		@game_pieces.each_with_index do |game_piece, index|
			piece_position = game_piece.get_tile_position
			piece_territory = @game_board.get_territory(piece_position)

			if game_piece.colour == :white
				piece_territory.each do |positionControlled|
					white_territory.add(positionControlled)
				end
			else #game_piece is black
				piece_territory.each do |positionControlled|
					black_territory.add(positionControlled)
				end
			end
		end

		white_remaining_moves = white_territory.length
		black_remaining_moves = black_territory.length

		if white_remaining_moves > black_remaining_moves
			return :white
		elsif black_remaining_moves > white_remaining_moves
			return :black
		elsif white_remaining_moves == black_remaining_moves
			if @current_turn == :white
				return :black
			else #currently blacks turn
				return :white
			end
		end
	end

	# Searches for the Amazon at the given start tile
	# position using find_amazon(), and if found calls the
	# Board’s move_amazon method to move the
	# Amazon on the start_tile to the given position given
	# as dest_tile.
	# If the request was valid, true is returned, else, false
	# is returned.
	# Returns bool
	def move_amazon(player_colour, start_tile, dest_tile)
		if find_amazon(player_colour, start_tile)
			@game_board.move_amazon(start_tile, dest_tile)
			@game_pieces.each_with_index do |game_piece, index|
				if game_piece.get_tile_position == start_tile && game_piece.colour == player_colour.to_sym
					game_piece.set_tile_position(dest_tile)
				end
			end
            find_amazon(player_colour, start_tile) == false ? true : false
		end
		#Return false on unfound amazon
		false
	end

	# Checks that the player_colour making the request
	# matches the current_turn colour, and if it does, calls
	# the Board’s set_tile_piece method to display an
	# arrow on the Board.
	# If the request was valid, true is returned, else, false
	# is returned.
	# Returns bool
	def place_arrow(player_colour, start_position, tile_position)
		if @current_turn == player_colour.to_sym
			@game_board.shoot_arrow(start_position, tile_position) # should be (start_position, tile_position)? Who knows/ This is likely broken because I don't have the current position
		end
	end

	# Searches for the Amazon at the given start tile
	# position using find_amazon(), and if found, calls the
	# Board’s get_available_moves method returning the
	# resulting array.
	# Returns Array[int]
	def select_amazon(player_colour, tile_position)
		
		return @game_board.get_moves_available(tile_position) if find_amazon(player_colour, tile_position)

		return []
	end

	# Switches the current_turn variable to be set to the
	# opposite colour. (:black => :white), and vise versa.
	# Returns void
	def toggle_current_turn
		@current_turn = @current_turn == :white ? :black : :white
	end

	# Called during the construction of a GameEngine,
	# this will create the eight Amazon game pieces
	# needed for the game, setting their positions using
	# the AMAZON_START_POSITIONS array values,
	# and setting four of them to have the :white colour,
	# and four to have the :black colour respectively.
	# Returns void
	def reset_amazons
		@game_pieces = []
		@current_turn = :white
		
		@AMAZON_START_POSITIONS.each_with_index do |start_position, index|
			if index < 4
				amazon = Amazon.new(:black)
			else
				amazon = Amazon.new(:white)
			end

			amazon.set_tile_position(start_position)
			@game_pieces.append(amazon)
		end
	end

	private

	# PRIVATE
	# This method will iterate through GameEngine’s list
	# of Amazon pieces, and finds the one matching the
	# given Tile position. If a matching Amazon is found,
	# its associated colour will be checked with the one
	# passed to make sure that the user trying to interact
	# with the Amazon is allowed to do so. The result of
	# the search and validity check is returned as a
	# boolean value.
	#Returns bool
	def find_amazon(player_colour, tile_position)
		@game_pieces.each_with_index do |game_piece, index|
			if game_piece.get_tile_position == tile_position && game_piece.colour == player_colour.to_sym
				return true
			end
		end
		false
	end

	# PRIVATE
	# Determines if a Player has won the game by
	# checking if the Player about to take a turn has no
	# moves remaining. If so, the winning Player colour is
	# returned.
	# Returns symbol(black, white)
	def has_won
		#Unique territories with no double/triple/quadruple counting
		next_player_territory = Set.new

		@game_pieces.each_with_index do |game_piece, index|
			piece_position = game_piece.get_tile_position
			piece_territory = @game_board.get_territory(piece_position)

			next_player_colour = @current_turn == :white ? :black : :white

			piece_territory.each { |position_controlled| next_player_territory.add(position_controlled) } if game_piece.colour == next_player_colour
		end

		next_player_remaining_moves = next_player_territory.length

		if next_player_remaining_moves == 0
			return @current_turn
		end

		return false

	end
end
