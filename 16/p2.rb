# takes 9.19s on i7-11800H @ 4.6GHz

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
  attr_accessor :pos, :dir, :score, :prev

  def initialize(pos, dir)
    @pos = pos
    @dir = dir
    @score = 0
    @prev = nil
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
    cloned.prev = @prev
    return cloned
  end

  def route
    passed_by = Set.new
    reindeer = self
    while reindeer != nil
      passed_by.add(reindeer.pos)
      reindeer = reindeer.prev
    end
    return passed_by
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

# https://gist.github.com/pithyless/9738125
best_score = 4611686018427387903
best_seats = Set.new

while reindeers.length >= 1
  reindeer = reindeers.pop
  if reindeer.score > best_score
    break # no more reindeers can attain the best score now
  end
  x = reindeer.pos[0]
  y = reindeer.pos[1]
  if maze[y][x] == "E"
    best_score = reindeer.score
    best_seats.merge(reindeer.route)
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
  new_reindeer = reindeer.clone
  new_reindeer.move
  new_reindeer.prev = reindeer
  if visited_states.include?(new_reindeer.state)
    next
  end
  x = new_reindeer.pos[0]
  y = new_reindeer.pos[1]
  if maze[y][x] == "#"
    next
  end
  reindeers.push(new_reindeer)
end

puts best_seats.length