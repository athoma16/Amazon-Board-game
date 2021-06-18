# Description: This class is responsible for managing all Players from the Lobby that
# want to join a game. This class will place new Players requesting a game into a queue
# until they can be matched. When a sufficient number of Players are in the queue, the
# Matchmaker will attempt to create a Table hosting a game with two Players. A
# Matchmaker is only associated with a single Lobby, used for retrieving Players and
# passed in its construction.
require_relative 'table'

class Matchmaker
	def self.create_game(plr1, plr2)
		# Originally this method was used as a private method to be used
		# in junction with Lobby, but since we a re removing the online
		# portion, we changed the method to public and return type to table.
		table = Table.new
		table.add_player(plr1)
		table.add_player(plr2)
		table.setup_game
		table # Returns Table
	end
end