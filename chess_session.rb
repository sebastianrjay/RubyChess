
class Session
  attr_accessor :running_game

  def initialize

    @running_game = Game.new
  end
end
