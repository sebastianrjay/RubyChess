require 'byebug'
class Piece
  attr_accessor :position, :color, :board, :symbol, :off_sets

  def initialize(position, color, board)
    @board = board
    @position = position
    @color = color
  end

  def opponent_there? new_pos
    x, y = new_pos
    if board.in_bounds?(new_pos) && !board.grid[x][y].nil?
      return self.color != board.grid[x][y].color
    end
    false
  end

  def inspect
    symbol
  end

  def own_piece_there? new_pos
    x, y = new_pos
    unless board.grid[x][y].nil?
      return self.color == board.grid[x][y].color
    end
    false
  end

  def valid_moves player
    raise WrongPiece unless player.color == self.color
    piece_valid_moves = []
    i, j = self.position
    moves.each do |next_i, next_j|

      old_board = board.dup

      old_board.grid[next_i][next_j], old_board.grid[i][j] = old_board.grid[i][j], old_board.grid[next_i][next_j]
      old_board.grid[i][j] = nil

      piece_valid_moves << [next_i,next_j]

    end
    piece_valid_moves
  end
end

class SlidingPiece < Piece

  def moves(n=8)
    all_moves = []
    off_sets.each do |off_row, off_col|
      (1..n).each do |i|
        new_pos = [off_row * i + position[0], off_col * i + position[1]]
        if board.in_bounds?(new_pos) && !own_piece_there?(new_pos) && !opponent_there?(new_pos)
          all_moves << new_pos
        elsif opponent_there?(new_pos) #&& board.in_bounds?(new_pos)
          all_moves << new_pos
          break
        else
          break
        end
      end

    end
    all_moves
  end
end

class Bishop < SlidingPiece

  def initialize(position, color, board)
    super
    @symbol = "♗"
    @off_sets = [-1 ,1].product([ -1 ,1])
  end

end


class Rook < SlidingPiece
  def initialize(position, color, board)
    super
    @symbol = "♖"
    @off_sets = [[0, -1], [1,0], [-1, 0], [0, 1]]
  end
end


class Queen < SlidingPiece

  def initialize(position, color, board)
    super
    @symbol = "♕"
    @off_sets = [-1, 0 ,1].product([ -1, 0 ,1]).reject {|offset| offset == [0,0]}
  end
end

class SteppingPiece < SlidingPiece

  def moves(n = 1)
    super
  end
end

class King < SteppingPiece

  def initialize(position, color, board)
    super
    @symbol = "♔"
    @off_sets = [-1, 0 ,1].product([ -1, 0 ,1]).reject {|offset| offset == [0,0]}
  end

end

class Knight < SteppingPiece

  def initialize(position, color, board)
    super
    @symbol = "♘"
    @off_sets = [[2, -1],
    [-2,  1],
    [-1, -2],
    [-1,  2],
    [ 1, -2],
    [ 1,  2],
    [-2, -1],
    [ 2,  1]]
  end

end

class Pawn < Piece
  attr_accessor :has_moved, :kill_moves, :piece_valid_moves

    def initialize(position, color, board)
      super
      @symbol = "♙"
      @has_moved = false
      @off_sets = color == :black ? [1, 0] : [-1, 0]
      @kill_moves = color == :black ? [[1, -1],[ 1, 1]] : [[-1, 1], [-1, -1]]
    end

    def moves
      off_sets
      all_moves = []
      new_pos = [(position[0] + off_sets[0]), position[1]]
      all_moves << new_pos if board.grid[new_pos[0]][new_pos[1]].nil?
      all_moves
      if all_moves.include?(new_pos) && !has_moved
        new_pos = [(position[0] + 2 * off_sets[0]), position[1]]
        all_moves << new_pos if board.grid[new_pos[0]][new_pos[1]].nil?
      end
      kill_moves.each do |m_x, m_y|
        if opponent_there?([m_x + position[0], m_y + position[1]])
          all_moves << [m_x + position[0], m_y + position[1]]
        end
      end
      all_moves
    end
end
