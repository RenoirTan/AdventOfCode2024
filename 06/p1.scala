//> using scala 3.6.2

import scala.io.Source
import scala.util.boundary, boundary.break
import scala.collection.immutable.Set

enum Direction:
    case Up, Right, Down, Left

    def rotateClockwise90Deg = this match {
        case Up => Right
        case Right => Down
        case Down => Left
        case Left => Up
    }

// direction: 0 -> up, 1 -> right, 2 -> down, 3 -> left
class State(val lab: Array[String]):
    val width = lab(0).length
    val height = lab.length
    var (x, y) = findGuard(lab)
    var direction =
        lab(y)(x) match {
            case '^' => Direction.Up // only case
            case '>' => Direction.Right
            case 'v' => Direction.Down
            case '<' => Direction.Left
            case _ => throw new Exception(s"wtf is this: ${lab(y)(x)}")
        }
    
    def pos: (Int, Int) = (x, y)
    
    def isOutOfBounds: Boolean = x < 0 || x >= width || y < 0 || y >= height
    
    def update: Unit = direction match {
        case Direction.Up => moveUp
        case Direction.Right => moveRight
        case Direction.Down => moveDown
        case Direction.Left => moveLeft
    }

    def moveUp: Unit =
        if (y <= 0) y -= 1
        else if (lab(y-1)(x) == '#') direction = direction.rotateClockwise90Deg
        else y -= 1
    
    def moveRight: Unit =
        if (x >= width-1) x += 1
        else if (lab(y)(x+1) == '#') direction = direction.rotateClockwise90Deg
        else x += 1
    
    def moveDown: Unit =
        if (y >= height-1) y += 1
        else if (lab(y+1)(x) == '#') direction = direction.rotateClockwise90Deg
        else y += 1
    
    def moveLeft: Unit =
        if (x <= 0) x -= 1
        else if (lab(y)(x-1) == '#') direction = direction.rotateClockwise90Deg
        else x -= 1

@main
def main(filepath: String): Int =
    val lab = Source.fromFile(filepath).getLines.toArray
    var state = State(lab)
    var visited: Set[(Int, Int)] = Set()
    while (!state.isOutOfBounds) {
        visited += state.pos
        state.update
    }
    println(s"${visited.size}")
    return 0

def findGuard(lab: Array[String]): (Int, Int) =
    boundary:
        for ((row, y) <- lab.view.zipWithIndex) do
            for (cell, x) <- row.view.zipWithIndex do
                if cell == '^' then break((x, y))
        return (0, 0)
