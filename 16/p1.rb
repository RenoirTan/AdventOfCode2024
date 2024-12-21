# takes 12.02s on i7-11800H @ 4.6GHz

require "matrix"
require "set"
require "pqueue"

UP_VECTOR = Vector[0, -1]
LEFT_VECTOR = Vector[-1, 0]
DOWN_VECTOR = Vector[0, 1]
RIGHT_VECTOR = Vector[1, 0]
DIR_VECTORS = [UP_VECTOR, LEFT_VECTOR, DOWN_VECTOR, RIGHT_VECTOR]

def calculate_cost_of_rotation(src, dest)
  if (src + dest).zero? # reverse
    return 2000
  elsif src.independent?(dest) # orthogonal
    return 1000
  else
    return 0
  end
end

class Reindeer
  attr_accessor :pos, :dir, :score

  def initialize(pos, dir)
    @pos = pos
    @dir = dir
    @score = 0
  end

  def move
    @pos += @dir
    @score += 1
  end

  def turn_to(dest)
    @score += calculate_cost_of_rotation(@dir, dest)
    @dir = dest
  end

  def state
    return [@pos, @dir]
  end

  def clone
    cloned = Reindeer.new(@pos.clone, @dir.clone)
    cloned.score = @score
    return cloned
  end
end

if ARGV.length < 1
  abort "No file included!"
end

maze = IO.readlines(ARGV[0], chomp: true)
height = maze.length
width = maze[0].length

pos = (-> {
  for y in 0..(height-1) do
    for x in 0..(width-1) do
      if maze[y][x] == "S"
        return Vector[x, y]
      end
    end
  end
  abort "Could not find start"
}).call

# move lower score reindeers first
reindeers = PQueue.new([Reindeer.new(pos, RIGHT_VECTOR)]) { |a, b| a.score < b.score }
visited_states = Set.new [[pos, RIGHT_VECTOR]]

while reindeers.length >= 1
  reindeer = reindeers.pop
  x = reindeer.pos[0]
  y = reindeer.pos[1]
  if maze[y][x] == "E"
    puts reindeer.score
    break
  end
  visited_states.add(reindeer.state)
  for dir_vec in DIR_VECTORS
    new_reindeer = reindeer.clone
    new_reindeer.turn_to(dir_vec)
    if visited_states.include?(new_reindeer.state)
      next
    end
    reindeers.push(new_reindeer)
  end
  reindeer.move
  if visited_states.include?(reindeer.state)
    next
  end
  x = reindeer.pos[0]
  y = reindeer.pos[1]
  if maze[y][x] == "#"
    next
  end
  reindeers.push(reindeer)
end