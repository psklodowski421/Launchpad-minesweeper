$:.unshift(Dir.pwd)

require 'rubygems'
require 'bundler/setup'
require 'csv'
Bundler.require

require_relative 'board'

board = Board.new
set title: "Minesweeper", background: "random"

on :key do |event|
  if event.type == :down
    case event.key
    when "w"
      board.clear_board
    when "q"
      board.regenerate_board
    when "escape"
      board.clear_board
      board.clear_top_panel
      close
    end
  end
end

update do
  board.input_check?
end

show
