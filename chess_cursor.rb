class Cursor
  attr_accessor :position, :selected_position

  def initialize
    @position = [0, 0]
    @selected_position = nil
  end

  def move direction
    case direction
    when "up"
      @position = position[0] - 1, position[1]
    when "down"
      @position = position[0] + 1, position[1]
    when "left"
      @position = position[0], position[1] - 1
    when "right"
      @position = position[0], position[1] + 1
    end
    force_in_bounds
  end

  def force_in_bounds
    position.each_with_index do |coord, index|
      position[index] = 0 if coord > 7
      position[index] = 7 if coord < 0
    end
    position
  end

  # def in_bounds?
  #   (0..7) === position[0] && (0..7) === position[1]
  # end
end
