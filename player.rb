# Description: This class is used to represent a user connected to the system. It holds
# basic attributes for identification when matchmaking and attributes and methods used
# when playing a game.

class Player
	def initialize(name, playerId)
		@name = name
		@player_id = playerId
	end

	# Returns the Player’s game colour.
	def get_game_colour
		@colour
	end

	# Returns the object's player_id
	def get_player_id
		@player_id
	end

	# Sets the Player’s colour for a Game.
	# colour:symbol
	def set_game_colour(colour)
		@colour = colour
	end
end