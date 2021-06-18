# Description: This class represents the Amazon game piece that a Player can move
# between Tiles on the board. Instances of this class can be placed on any Tile of the
# board that is not obstructed by a piece, and that is in the same row, column or is in the
# diagonal from the starting location

class Amazon
	attr_reader :colour
	# - colour: symbol(:black, :white)
	# - tile_position: int

	def initialize(colour)
		@colour = colour
	end

	def get_tile_position
		# Method used to get the Amazon's tile position on a
		# Board.
		@tile_position # Returns int
	end

	def set_tile_position(pos)
		#Method used to set the Amazon's tile position on a Board.
		@tile_position = pos
	end

end
