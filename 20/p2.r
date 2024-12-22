library(collections, warn.conflicts = FALSE)
library(readr)

king_moves <- list(
  c(1, 0),
  c(-1, 0),
  c(0, 1),
  c(0, -1)
)

cheat_moves <- list()

for (s in 2:20) {
  for (i in 0:(s - 1)) {
    j <- s - i
    cheat_moves[[length(cheat_moves) + 1]] <- c(j, i)
    cheat_moves[[length(cheat_moves) + 1]] <- c(-i, j)
    cheat_moves[[length(cheat_moves) + 1]] <- c(-j, -i)
    cheat_moves[[length(cheat_moves) + 1]] <- c(i, -j)
  }
}

argv <- commandArgs(TRUE)

stopifnot(length(argv) >= 1)

maze <- read_lines(argv[1])

height <- length(maze)
width <- nchar(maze[1])

ch_at <- function(s, i) {
  substr(s, i, i)
}

maze_at <- function(x, y) {
  ch_at(maze[y], x)
}

in_bounds <- function(x, y) {
  (x >= 1 && x <= width && y >= 1 && y <= height)
}

for (y in 1:height) {
  x <- unlist(gregexpr("S", maze[y]))[1]
  if (x != -1) {
    sx <- x
    sy <- y
  }
  x <- unlist(gregexpr("E", maze[y]))[1]
  if (x != -1) {
    ex <- x
    ey <- y
  }
}

# matrix of distances from end
maze_vals <- matrix(-1, nrow = height, ncol = width)
prev <- c(0, 0)
curr <- c(ex, ey)
distance <- 0

while (any(curr != c(sx, sy))) {
  x <- curr[1]
  y <- curr[2]
  maze_vals[y, x] <- distance
  for (move in king_moves) {
    new_pos <- curr + move
    neighbour <- maze_at(new_pos[1], new_pos[2])
    if ((neighbour == "." || neighbour == "S") && any(new_pos != prev)) {
      prev <- curr
      curr <- new_pos
      break
    }
  }
  distance <- distance + 1
}
maze_vals[sy, sx] <- distance # for the starting position

# try all available shortcuts
more_than_100 = 0
for (y in 1:height) {
  for (x in 1:width) {
    distance <- maze_vals[y, x]
    if (distance == -1) { # not a valid cell
      next
    }
    for (cheat in cheat_moves) {
      skipped_to <- c(x, y) + cheat
      if (!in_bounds(skipped_to[1], skipped_to[2])) {
        next
      }
      next_dist <- maze_vals[skipped_to[2], skipped_to[1]]
      if (next_dist == -1) {
        next
      }
      cheat_time = sum(abs(cheat))
      savings <- distance - next_dist - cheat_time
      if (savings >= 100) {
        more_than_100 <- more_than_100 + 1
      }
    }
  }
}

print(more_than_100)