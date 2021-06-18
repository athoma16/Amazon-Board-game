# Description: This class represents an individual Tile stored by a Board, and has
# attributes and methods for monitoring when its set to hold a specific game piece type.

class Tile

	attr_accessor :piece

	# - piece: string (I recommend we use those: ('white_queen', 'black_queen', 'arrow', 'empty') @Alex)
	# - is_occupied: boolean

	def initialize
		@is_occupied = false
		@piece = nil
	end

	def check_is_occupied
		# Returns whether or not this Tile is occupied by a
		# game piece, i.e. an Amazon or arrow.
		@is_occupied # Returns bool
	end

	def set_piece(new_piece)
		# Called by the parent Board class to set its piece
		# property to the one passed, and is_occupied to
		# true. If the passed piece string is “none”,
		# is_occupied is instead set to false.
		if (new_piece == 'empty') || (new_piece == nil)
			@is_occupied = false
		elsif (new_piece == 'white_queen') or (new_piece == 'black_queen') or (new_piece == 'arrow')
			@is_occupied = true
		else
			raise("`new_piece` may only be: 'white_queen', 'black_queen', 'arrow', 'empty'.")
		end
		@piece = new_piece
		nil # Returns void
	end

end
