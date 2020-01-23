class Mine
  attr_accessor :revealed, :mine, :x, :y, :near_mines, :position, :mark, :first_press

  def initialize(revealed = false, x = nil, y = nil, near_mines = 0, position = nil, first_press = false)
    if defined?(@@mine_count)
      @@mine_count += 1
    else
      @@mine_count = 1
    end
    @x = x
    @y = y
    @first_press = first_press
    @revealed = revealed
    @near_mines = near_mines
    @position = position
    @@mine_count <= 10 ? @mine = true : @mine = false
  end

  def self.generate_mines
    @@mine_count = 0
    mines = Array.new
    64.times{mines << Mine.new}
    mines
  end

  def self.count
    puts @@mine_count
  end
end