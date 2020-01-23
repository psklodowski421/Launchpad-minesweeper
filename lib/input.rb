module Input

  def mode_check(mine)
    case @mode
    when 1
      field_status(mine)
    when 2
      return if mine.revealed
      mark_mine(mine)
    when 3
    end
    win?
  end

  def mark_mine(mine)
    if mine.mark
      mine.mark = false
      light(3,mine.position,0)
      light(1,mine.position,2)
      @mark_count -= 1 if mine.mine
      puts "Marked mines #{@mark_count}" if mine.mine
    else
      mine.mark = true
      light(1,mine.position,0)
      light(3,mine.position,127)
      @mark_count += 1 if mine.mine
      puts "Marked mines #{@mark_count}" if mine.mine
    end
  end

  def field_status(mine)
    return first_press(mine) if @first_press
    if mine.mine == true
      render_board
      @game_over = 1
    elsif mine.near_mines > 0
      render_near_mines_field(mine)
    else
      reveal_empty_field(mine)
      fields_close(mine)
    end
    win?
  end

  def fields_close(mine)
    mine_close_friends_array =[]
    mine_close_friends_array << [mine.x-1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x+1, mine.y-1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y - 1 }.empty?
    mine_close_friends_array << [mine.x-1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y }.empty?
    mine_close_friends_array << [mine.x + 1, mine.y] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y }.empty?
    mine_close_friends_array << [mine.x - 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x - 1 && friend_mine.y == mine.y + 1 }.empty?
    mine_close_friends_array << [mine.x, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x && friend_mine.y == mine.y + 1 }.empty?
    mine_close_friends_array << [mine.x + 1, mine.y + 1] unless @board.flatten.select{|friend_mine| friend_mine.x  == mine.x + 1 && friend_mine.y == mine.y + 1 }.empty?
    reveal_friend_fields(mine_close_friends_array)
  end

  def reveal_friend_fields(fields_array)
    fields_array.each do |field|
      temp_mine = find(field)
      next if temp_mine.revealed
      if temp_mine.near_mines > 0
        render_near_mines_field(temp_mine)
      else
        reveal_empty_field(temp_mine)
        fields_close(temp_mine)
      end
    end
  end

  def render_near_mines_field(mine)
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
    mine.revealed = true
  end

  def reveal_empty_field(mine)
    mine.revealed = true
    @output.puts(144,mine.position,0)
  end

  def mine_select(note)
    mine = @board.flatten.select{|mine| mine.position == note[:data][1]}.first
    mode_check(mine)
  end
end