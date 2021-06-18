require_relative 'tile'

class Board
  attr_reader :tiles

  def initialize
    reset
  end

  def get_moves_available(tile_position)
    moves = []
    shifts = [10, -10, 1, -1, 11, -11, 9, -9]

    shifts.each{ |shift|
      current_position = tile_position + shift
      while current_position >= 0 && current_position <= 99  && !@tiles[current_position].check_is_occupied do 
        # Checks that it does not add tiles from row above/below on horizontal check
        if (shift== 1 || shift == -1) && (current_position / 10).floor != (tile_position / 10).floor
          break
        
          # Checks that it stops on the boards 'right' edge
        elsif (shift == 11 || shift == -9) && current_position % 10 < tile_position % 10
          break

        # Checks that it stops on the boards 'left' edge
        elsif (shift == -11 || shift == 9) && current_position % 10 > tile_position % 10
          break
        end

        #Adds a valid position to the return list
        moves.push(current_position)
        current_position += shift
      end
    }

    #returns the list of valid moves
    moves
  end

  def get_territory(tile_position)
    # Gets and returns all of the tiles surrounding the
    # given tile that are empty to determine the ‘territory’
    # held by the Amazon piece at that position.
    if @tiles[tile_position].check_is_occupied == false || @tiles[tile_position].piece == 'arrow'
      raise("Tile position #{tile_position} does not have an amazon on it.")
    end
    @_list = []
    _analyse_territory([tile_position])
    @_list.delete_at(@_list.index(tile_position))
    @_list # Returns Array[int]
  end

  def move_amazon(start_position, end_position)
    # This method will move the Amazon at the
    # start_position Tile to the dest_position Tile, if the
    # path between the Tiles is not blocked.
    if check_tile_path_clear(start_position, end_position)
      temp = @tiles[start_position].piece
      @tiles[start_position].set_piece('empty')
      @tiles[end_position].set_piece(temp)
    end
    # Returns void
  end

  def shoot_arrow(start_position, end_position)
    # This method will display an Arrow at the
    # dest_position Tile, if the path between the
    # start_position Tile and the dest_position Tile is not
    # blocked.
    if check_tile_path_clear(start_position, end_position)
      @tiles[end_position].set_piece('arrow')
    end
    # Returns void
  end

  def reset
    @tiles = []
    (1..100).each { |_|
      @tiles.append(Tile.new)
    }

    #This array was copied from game_engine and is used so the amazons can be placed into the correct default position on the board
    amazon_start_pos = [3, 6, 30, 39, 60, 69, 93, 96]
    @tiles.each{ |x| x.set_piece('empty')}
    amazon_start_pos.each { |x| x > 50 ? @tiles[x].set_piece("white_queen") : @tiles[x].set_piece("black_queen")}
    nil
  end

  #methods below are private
  private

  def check_tile_path_clear(start_position, end_position)
    #Check if the 2 given positions form a valid move
    positive = start_position - end_position > 0

    #Invalid option, returns false
    if start_position == end_position
      return false 

    #check vertical
    elsif start_position % 10 == end_position % 10
      positive ? shift = 10 : shift = -10

    #check horizontal
    elsif (start_position/10).floor == (end_position/10).floor
      positive ? shift = 1 : shift = -1
    
    #check right diagonal
    elsif start_position % 11 == end_position % 11
      positive ? shift = 11 : shift = -11

    #check left diagonal
    elsif start_position % 9 == end_position % 9
      positive ? shift = 9 : shift = -9

    # The 2 positions do not form a valid line
    else
      return false
    end

    #create a list of all tiles between the start and end position including end
    current_position = end_position
    
    while current_position != start_position do
      if @tiles[current_position].check_is_occupied
        return false
      end

      current_position += shift
    end

    true
  end

  ## get_territory(tile_position) helper function ##
  def _analyse_territory(list)
    for tile in list do
      unless @_list.include? tile
        @_list.append(tile)
        breath = _probe(tile)
        # puts("Analysing #{tile}, breath = #{breath}")
        _analyse_territory(breath)
      end
    end
  end

  def _probe(tile)
    result = []
    # left side
    if tile % 10 != 0
      _add_tile_to_probe_result(tile-11, result)
      _add_tile_to_probe_result(tile-1, result)
      _add_tile_to_probe_result(tile+9, result)
    end
    # right side
    if tile % 10 != 9
      _add_tile_to_probe_result(tile-9, result)
      _add_tile_to_probe_result(tile+1, result)
      _add_tile_to_probe_result(tile+11, result)
    end
    # top & bottom
    _add_tile_to_probe_result(tile-10, result)
    _add_tile_to_probe_result(tile+10, result)
    result # Returns List[tile:int]
  end

  def _add_tile_to_probe_result(tile, result)
    if tile >= 0 && tile < 100
      if @tiles[tile].check_is_occupied == false
        result.append(tile)
      end
    end
  end
  ## end ##

end