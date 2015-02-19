require_relative 'chess_pieces.rb'
require_relative 'chess_player.rb'

class Board
  attr_accessor :grid, :cursor

  def initialize(options = true)
    @grid = Array.new(8) {Array.new(8)}
    if options
      start_rook
      start_knight
      start_bishop
      start_queen
      start_king
      start_pawn
    end
    @cursor = [0, 0]
  end

  def dup
    new_board = self.class.new(false)
    self.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        next if piece.nil?
        new_board.grid[i][j] = piece.class.new([i,j], piece.color, new_board)
      end
    end
    new_board
  end

  def start_rook

    [0].product([0,7]).each do |x, y|
      grid[x][y] = Rook.new([x, y], :black, self)
    end

    [7].product([0,7]).each do |x, y|
      grid[x][y] = Rook.new([x, y], :white, self)
    end
  end

  def start_knight

    [0].product([1,6]).each do |x, y|
      grid[x][y] = Knight.new([x, y], :black, self)
    end

    [7].product([1,6]).each do |x, y|
      grid[x][y] = Knight.new([x, y], :white, self)
    end
  end

  def start_bishop

    [0].product([2,5]).each do |x, y|
      grid[x][y] = Bishop.new([x, y], :black, self)
    end

    [7].product([2,5]).each do |x, y|
      grid[x][y] = Bishop.new([x, y], :white, self)
    end
  end

  def start_queen
      grid[0][3] = Queen.new([0, 3], :black, self)

      grid[7][3] = Queen.new([7, 3], :white, self)
  end

  def start_king
    grid[0][4] = King.new([0, 4], :black, self)
    grid[7][4] = King.new([7, 4], :white, self)
  end

  def start_pawn
    8.times do |y|
      grid[1][y] = Pawn.new( [1, y], :black, self)
    end

    8.times do |y|
      grid[6][y] = Pawn.new( [6, y], :white, self)
    end
  end

  def in_bounds? new_pos
    x, y = new_pos
    (0..7) === x and (0..7) === y
  end

  def move_piece selected_pos, new_pos, moving_player
    x , y = selected_pos
    n_x, n_y = new_pos
    raise InvalidMove unless grid[x][y].valid_moves(moving_player).include? new_pos
    grid[x][y].position = [n_x, n_y]
    grid[x][y].has_moved = true if grid[x][y].is_a? Pawn
    grid[x][y], grid[n_x][n_y] = grid[n_x][n_y], grid[x][y]
    grid[x][y] = nil
  end

  def all_valid_moves player
    all_valid_moves = []
    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        next if el.nil? || el.color != player.color
        all_valid_moves << el.valid_moves(player)
      end
    end
    all_valid_moves.reject {|move| move.empty?}
  end


  def in_check?(player)
    king_position = []
    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        next if el.nil?
        if el.is_a?(King) && player.color == el.color
          king_position = [i, j]
          break
        end
      end
    end

    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        next if el.nil?
        unless el.color == player.color
          return true if el.moves.include?(king_position)
        end
      end
    end
    false
  end

  def checkmate? player
    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        next if el.nil?
        if el.is_a?(King) && player.color == el.color
          return false
        end
      end
    end
    true
  end
end
