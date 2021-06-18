require_relative 'amazon'
require_relative 'board'
require_relative 'game_engine'
require_relative 'matchmaker'
require_relative 'player'
require_relative 'table'
require_relative 'tile'

def print_instructions
    puts "\nPlayer Commands:\n"
    puts "> Input 'm' to start a move which will prompt you for the following:"
    puts "\t\t1) Coordinate of Amazon to move"
    puts "\t\t2) Destination of Amazon coordinate"
    puts "\t\t3) Arrow shot coordinate"
    puts "> Input 'f' to forfeit and end the game"
    puts "> Input 'i' to see the instructions again\n"
end

def get_coord_input(message)
    coord = ''
    while coord.length < 2 or coord.length > 3 or !(coord[0] =~ /[[:upper:]]/) or !(coord[1] =~ /\d/)
        print message
        coord = gets.chomp
    end
    return coord
end

def convert_coord_input(coord)
    x = 0
    y = 0
    
    if coord[0] == 'A'
        x = 0
    elsif coord[0] == 'B'
        x = 1
    elsif coord[0] == "C"
        x = 2
    elsif coord[0] == "D"
        x = 3
    elsif coord[0] == "E"
        x = 4
    elsif coord[0] == "F"
        x = 5
    elsif coord[0] == "G"
        x = 6
    elsif coord[0] == "H"
        x = 7
    elsif coord[0] == "I"
        x = 8
    elsif coord[0] == "J"
        x = 9
    end
    
    if(coord.length == 3)
        y = 9
    else
        y = coord[1].to_i - 1
    end

    return x*10 + y
end

def convert_number_to_code(code)
    arr = []
    code&.each do |c|
        x = (c / 10)
        if x == 0
            x = 'A'
        elsif x == 1
            x = 'B'
        elsif x == 2
            x = 'C'
        elsif x == 3
            x = 'D'
        elsif x == 4
            x = 'E'
        elsif x == 5
            x = 'F'
        elsif x == 6
            x = 'G'
        elsif x == 7
            x = 'H'
        elsif x == 8
            x = 'I'
        elsif x == 9
            x = 'J'
        end
        y = (c % 10 + 1).to_s
        arr.push(x+y)
    end
    arr
end

input = ""
rematch = true
request_result = nil
player1 = Player.new('player1', 1)
player1.set_game_colour(:white)
player2 = Player.new('player2', 2)
player2.set_game_colour(:black)

puts "Welcome to the Game of Amazons!\n\n"

table = Matchmaker.create_game(player1, player2)

print_instructions

while rematch
    active_player = player1

    while !input.casecmp?("f")
        player_color = active_player.get_game_colour.to_s
        print "\n[#{player_color}] Enter your command (i for instructions) >> "
        input = gets.chomp

        if input.casecmp?("m")
            # Select Amazon to move (gets valid moves in return)
            start_input = get_coord_input("[#{player_color}] Select your amazon (coordinate input - i.e. A1): ")
            start_tile = convert_coord_input(start_input)
            request_result = table.handle_player_request(active_player.get_player_id, :select, {:player_color => player_color, :tile_position => start_tile})

            if request_result[:display_data] != nil && !request_result[:display_data].empty?
                # Output valid Amazon moves
                puts "Valid Amazon Moves: " + convert_number_to_code(request_result[:display_data]).join(' ')

                # Move Amazon
                end_input = get_coord_input("[#{player_color}] Select the amazon destination (coordinate input - i.e. A1): ")
                end_tile = convert_coord_input(end_input)
                request_result = table.handle_player_request(active_player.get_player_id, :move, {:player_color => player_color, :start_tile => start_tile, :end_tile => end_tile})

                # Output valid arrow shots
                request_result = table.handle_player_request(active_player.get_player_id, :select, {:player_color => player_color, :tile_position => end_tile} )
                puts "Valid Arrow Shots: " + convert_number_to_code(request_result[:display_data]).join(' ')

                # Shoot arrow
                arrow_input = get_coord_input("[#{player_color}] Select the arrow destination (coordinate input - i.e. A1): ")
                arrow_tile = convert_coord_input(arrow_input)
                request_result = table.handle_player_request(active_player.get_player_id, :shoot, {:player_color => player_color, :start_tile => end_tile, :end_tile => arrow_tile})

                # Swap active player on UI after move turn based on display data
                if (request_result[:display_data] == :black)
                    active_player = player2
                elsif (request_result[:display_data] == :white)
                    active_player = player1
                end
            else
                puts "This tile has no moves you can make on it!"
            end
        elsif input.casecmp?("i")
            print_instructions
        end
    end

    request_result = table.handle_player_request(active_player.get_player_id, :forfeit, nil)

    puts "\nGame Over!"
    puts "The #{request_result[:display_data].to_s} player wins!"
    
    while !input.casecmp?("y") && !input.casecmp?("n")
        print "Would you like to rematch? (y/n): "
        input = gets.chomp

        if input.casecmp?("y")
            rematch = true
            request_result = table.handle_player_request(active_player.get_player_id, :rematch, nil)
        elsif input.casecmp?("n")
            rematch = false
        end
    end
end

puts "Thanks for playing!"