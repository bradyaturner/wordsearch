#!/usr/bin/env ruby

require 'logger'

DIRECTIONS = [
  [-1,-1], # left, up (NW)
  [-1, 0], # left (W)
  [0,-1], # up (N)
  [1,-1], # right, up (NE)
  [1,0], # right (E)
  [1,1], # right, down (SE)
  [0,1], # down (S)
  [-1,1] # down, left (SW)
]

class WordSearch
  def initialize(path)
    @file = File.read path
    @logger = Logger.new(STDERR)
    @logger.level = Logger::INFO
    parse
  end

  def solve
    @words.each {|w| search w }
  end

private
  def search(word)
    puts "Searching word: \"#{word}\""
    start_coords = find_each_occurrence word[0]
    @logger.debug start_coords.inspect

    start_coords.each do |current_pos|
      @logger.debug "Locating word: #{word}, searching coords adjacent to #{current_pos.inspect}"
      DIRECTIONS.each do |direction|
        @coords = [current_pos]
        found = locate(word,1,current_pos,direction)
        if found
          puts @coords.inspect
          return
        end
      end
    end
  end

  def locate(word,depth,current_pos,direction)
    char = word[depth]
    next_coord = determine_coord(current_pos,direction)
    if next_coord[0] > @puzzle.length-1 || next_coord[1] > @puzzle.first.length-1 || next_coord[0] < 0 || next_coord[1] < 0
      return false
    end
    @logger.debug "\tlooking for char: #{char} at #{next_coord.inspect}"
    found = @puzzle[next_coord[0]][next_coord[1]] == char  # is char at next coord the one we're looking for?
    @logger.debug "\t\t#{found ? "found" : "not found"}"
    if !found
      return false
    end

    @coords << next_coord
    if depth == word.length-1
      return true
    else
      locate(word,depth+1,next_coord,direction)
    end
  end

  def find_each_occurrence(char)
    occurrences = []
    @puzzle.each_with_index do |row,ri|
      row.each_with_index do |rowpos, ci|
        if char == rowpos
          occurrences << [ri,ci]
        end
      end
    end
    occurrences
  end

  def determine_coord(current_pos,direction)
    # top left is 0,0
    x = current_pos[0] + direction[0]
    y = current_pos[1] + direction[1]
    [x,y]
  end

  def parse
    @words = @file.lines.first.strip.split(",")
    puts @words.inspect
    @puzzle = []
    @file.lines[1..-1].each {|line| @puzzle << line.strip.split(",")}
    @puzzle.each {|r| puts r.inspect}
  end
end

if __FILE__==$0
  if ARGV[0].nil?
    STDERR.puts "usage: #{__FILE__} INPUT_FILE"
    exit
  end

  ws = WordSearch.new ARGV[0]
  ws.solve
end
