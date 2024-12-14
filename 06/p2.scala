//> using scala 3.6.2

import scala.io.Source
import scala.util.boundary, boundary.break
import scala.collection.mutable.Set
import scala.collection.mutable.Map

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
    var lab = Source.fromFile(filepath).getLines.toArray
    var state = State(lab)
    val obstacles: Set[(Int, Int)] = Set()
    // try putting an obstacle on the original path and see what happens
    while (!state.isOutOfBounds) {
        val (x, y) = state.pos
        if !obstacles.contains((x, y)) && tryObstacleHere(lab, x, y) then
            obstacles.add((x, y))
        state.update
    }
    println(s"${obstacles.size}")
    return 0

def findGuard(lab: Array[String]): (Int, Int) =
    boundary:
        for ((row, y) <- lab.view.zipWithIndex) do
            for (cell, x) <- row.view.zipWithIndex do
                if cell == '^' then break((x, y))
        return (0, 0)

def tryObstacleHere(lab: Array[String], x: Int, y: Int): Boolean =
    if lab(y)(x) != '.' then return false
    val oldRow = lab(y)
    var row = oldRow.slice(0, x) + '#' + oldRow.slice(x + 1, oldRow.size)
    lab(y) = row
    val cycleCreated = unescapable(lab)
    lab(y) = oldRow
    return cycleCreated

def unescapable(lab: Array[String]): Boolean =
    var state = State(lab)
    var visited: Map[(Int, Int), Set[Direction]] = Map().withDefault(_ => Set())
    while (!state.isOutOfBounds) do
        var directions = visited.apply(state.pos)
        if directions.contains(state.direction) then return true
        directions.add(state.direction)
        visited(state.pos) = directions
        state.update
    return false