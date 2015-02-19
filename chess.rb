require_relative 'chess_errors.rb'
require_relative 'chess_cursor.rb'
require_relative 'chess_pieces.rb'
require_relative 'chess_player.rb'
require_relative 'chess_board.rb'
require_relative 'chess_session.rb'
require 'colorize'
require 'io/console'
require 'yaml'
require 'byebug'

class Game
  attr_accessor :board, :turn, :cursor, :session
  attr_reader :players

  def initialize
    @turn = 0
    @board = Board.new
    @cursor = Cursor.new
    @players = [Player.new(:white), Player.new(:black)]
    play
  end

  def play
    until board.checkmate?(players[turn])
      system "clear"
      display
      begin
      input_char = read_char

      #get controller input and perform functions
      case input_char
      when "\r" #RETURN
        x, y = cursor.position
        if cursor.selected_position.nil?
          unless board.grid[x][y].nil?
            cursor.selected_position = cursor.position.dup
          else
            raise NoPieceThere
          end
        elsif cursor.selected_position == cursor.position
          cursor.selected_position = nil
        else
          board.move_piece(cursor.selected_position, cursor.position, players[turn])
          self.turn = turn == 0 ? 1 : 0
          cursor.selected_position = nil
        end
      when "\e"
        puts "Are you sure you want to exit the game? (y/n)"
        if gets.chomp == "y"
          exit
        end
      when "\e[A" #up arrow
        cursor.move("up")
      when "\e[B" #down
        cursor.move("down")
      when "\e[C" #right
        cursor.move("right")
      when "\e[D" #left
        cursor.move("left")
      when "s"
        save_game
      when "l"
        load_game
      when "\u0003"
        puts "CONTROL-C"
        exit 0
      end

      rescue WrongPiece => e
        puts "Can't move opponent's piece!"
        retry
      rescue InvalidMove => e
        puts "Can't make that move!"
        retry
      rescue NoPieceThere => e
        puts "Can't select nonexistent piece!"
        retry
      end
    end
    puts "Checkmate #{players[turn].color.to_s}, you got destroyed"
  end

  def display
    s_x, s_y = cursor.selected_position
    x, y = cursor.position
    board.grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        cursor = true if [x, y] == [i, j]
        selected = true if [s_x, s_y] == [i, j]

        if el.nil?
          saved_display = "| "
        else
          saved_display = "|" + el.symbol
        end

        if cursor
          print saved_display
        elsif selected
          print saved_display.blue.on_red
        else
          unless el.nil?
            print saved_display.colorize(el.color).colorize(background: :red)
          else
            print saved_display.colorize(background: :red)
          end
        end
      end
      puts "|".colorize(background: :red)
    end
    puts
  end

  def read_char
    STDIN.getch
  end

  def save_game
    puts "enter file_name to save to without extension"
    file_name = gets.chomp
    File.new("#{file_name}.yaml", "w") {|f| f.puts self.to_yaml}
  end

  def load_game
    puts "enter file_name to load from without extension"
    file_name = gets.chomp

    session.running_game = File.open("#{file_name}.yaml") {|f| YAML.load(f)}
    session.running_game.play
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end
end

g = Game.new
