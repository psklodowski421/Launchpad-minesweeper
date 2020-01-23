require_relative 'mine'
require_relative 'input'

class Board
  attr_accessor :board, :mines, :mark_count, :notes, :mode, :win
  include Input

  def initialize
    @output = UniMIDI::Output.first
    @input = UniMIDI::Input.first
    generate_mines
    notes
    generate_board
    render_new_game
    set_game_control
  end

  def win?
    if @win == 0
      if (@mark_count == @board.flatten.select{|mine| mine.mine == true}.count && @mark_count == @board.flatten.select{|mine| mine.mark == true}.count ) ||
          @board.flatten.select{|mine| mine.mine == false}.count == @board.flatten.select{|mine| mine.mine == false && mine.revealed == true}.count
        @win = 1
        clear_board
        clear_top_panel
        end_text
      end
    end
  end

  def end_text
    sysex_msg = [240, 0, 32, 41, 2, 24, 20, 20, 0 ,89, 111, 117, 32, 87, 111, 110, 247]
    @output.puts(sysex_msg)
  end

  def first_press(mine)
    temp_mine_pos = mine.position
    @first_press = false
    if mine.mine
      @board.flatten.select{|mine| mine.mine == false}.sample.mine = true
      mine.mine = false
    end
    mine.first_press = true
    first_press_friends(mine)
    mines_count_check
    field_status(@board.flatten.select{|mine| mine.position == temp_mine_pos}.first)
  end

  def first_press_friends(mine)
    first_press_friends=[]
    first_press_friends << [mine.x-1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y - 1 }.empty?
    first_press_friends << [mine.x, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y - 1 }.empty?
    first_press_friends << [mine.x+1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y - 1 }.empty?
    first_press_friends << [mine.x-1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y }.empty?
    first_press_friends << [mine.x + 1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y }.empty?
    first_press_friends << [mine.x - 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y + 1 }.empty?
    first_press_friends << [mine.x, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y + 1 }.empty?
    first_press_friends << [mine.x + 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y + 1 }.empty?
    friend_mines_remove(first_press_friends)
  end

  def friend_mines_remove(array_of_cords)
    mines_count = 0
    array_of_cords.each do |mine|
      if find(mine).mine
        find(mine).mine = false
        mines_count += 1
      end
      find(mine).first_press = true
    end
    puts mines_count
    mines_count.times{@board.flatten.select{|mine| mine.mine == false && mine.first_press == false}.sample.mine = true}
  end

  def set_game_control
    @win = 0
    @first_press = true
    @game_over = 0
    clear_top_panel
    @mark_count = 0
    @mode = 1
    light(1,104, 2 )
  end

  def light(mode, note, color)
    case mode
    when 1
      (11..89).include?(note) ? mode = 144 : mode = 176
    when 2
      (11..89).include?(note) ? mode = 145 : mode = 177
    when 3
      (11..89).include?(note) ? mode = 146 : mode = 178
    end
    @output.puts(mode, note, color)
  end

  def render_new_game
    notes.each do |note|
      @output.puts(144,note,2)
    end
  end

  def mines_count_check
    @board.flatten.each do |mine|
      next if mine.mine == true
      mine_close_friends(mine)
    end
  end

  def mine_close_friends(mine)
    mine_close_friends_array =[]
    mine_close_friends_array << [mine.x-1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x+1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x-1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y }.empty?
    mine_close_friends_array << [mine.x + 1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y }.empty?
    mine_close_friends_array << [mine.x - 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y + 1 }.empty?
    mine_close_friends_array << [mine.x, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y + 1 }.empty?
    mine_close_friends_array << [mine.x + 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y + 1 }.empty?
    friends_count(mine, mine_close_friends_array)
  end

  def find(cord)
    x = cord[0]
    y = cord[1]
    @board.flatten.select{|mine| mine.x == x && mine.y == y }.first
  end

  def friends_count(mine, mine_friends_array)
    mine_friends_array.each do |cord|
      if find(cord).mine
        mine.near_mines += 1
      end
      return regenerate_board if mine.near_mines > 3
    end
  end

  def notes
    @notes = [
      81,82,83,84,85,86,87,88,
      71,72,73,74,75,76,77,78,
      61,62,63,64,65,66,67,68,
      51,52,53,54,55,56,57,58,
      41,42,43,44,45,46,47,48,
      31,32,33,34,35,36,37,38,
      21,22,23,24,25,26,27,28,
      11,12,13,14,15,16,17,18
    ]
  end

  def generate_mines
    @mines = Array.new
    @mines = Mine.generate_mines
  end

  def render_board
    @board.each do |row|
      row.each do |mine|
        if mine.mine == true
          @output.puts(146, mine.position, 127)
        elsif mine.near_mines > 0
          case mine.near_mines
          when 1
            @output.puts(144, mine.position, 45)
          when 2
            @output.puts(144, mine.position, 19)
          when 3
            @output.puts(144, mine.position, 5)
          when 4
            @output.puts(144, mine.position, 126)
          else
            @output.puts(144, mine.position, 57)
          end
        else
          @output.puts(144, mine.position, 0)
        end
      end
    end
  end

  def mine_position(mine)
    mine.keys.first
  end

  def generate_board
    @board = Array.new(8){[]}
    x = 0
    y = 0
    @board.each do |sub_array|
      8.times{sub_array << temp_mine = @mines.sample;temp_mine.position = @notes.shift; temp_mine.x = x; temp_mine.y = y; @mines.delete(temp_mine);x +=1}
      y += 1
      x = 0
    end
  end

  def clear_board
    notes.each{|note| @output.puts(144,note,0)}
  end

  def input_check?
    unless @input.buffer.empty?
      if @input.buffer.first[:data][2] == 127
        if (11..89).include?(@input.buffer.first[:data][1])
          mine_select(@input.buffer.first) unless game_over && win == 1
        else
          control_buttons_select
        end
      end
      @input.buffer.clear
    end
  end

  def control_buttons_select
    case @input.buffer.first[:data][1]
    when 104
      return if @mode == 1
      reveal_mode
    when 105
      return if @mode == 2
      mark_mode
    when 106
      return if @mode == 2
    when 111
      regenerate_board
    end
  end

  def clear_top_panel
    (104..111).each do |note|
      light(1,note,0)
    end
  end

  def mark_mode
    @mode = 2
    clear_top_panel
    light(1,105,2)
  end

  def reveal_mode
    @mode = 1
    clear_top_panel
    light(1,104,2)
  end

  def regenerate_board
    generate_mines
    notes
    generate_board
    render_new_game
    set_game_control
  end

  def game_over
    true if @game_over == 1
  end
end