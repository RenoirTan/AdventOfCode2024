import kotlin.system.exitProcess
import java.io.File

fun main(args: Array<String>) {
    if (args.size < 1) {
        println("No file included!")
        exitProcess(1)
    }
    // before: {after, ...}
    val constraints = mutableMapOf<Int, MutableSet<Int>>().withDefault { mutableSetOf() }
    val inFile = File(args[0]).bufferedReader()
    var line: String? = inFile.readLine()
    while (line != null && line.length != 0) {
        val constraint = line.split("|")
        if (constraint.size == 2) {
            val before = constraint[0].toInt()
            val after = constraint[1].toInt()
            val here = constraints.getValue(before) // withDefault only works on get not set
            here.add(after)
            constraints[before] = here
        }
        line = inFile.readLine()
    }
    // updates
    var sum = 0;
    line = inFile.readLine()
    while (line != null) {
        val pages = line.split(",").map { it.toInt() }
        if (checkOrder(constraints, pages)) {
            val midIdx = pages.size / 2;
            sum += pages[midIdx];
        }
        line = inFile.readLine()
    }
    inFile.close()
    println(sum)
}

fun checkOrder(constraints: Map<Int, Set<Int>>, pages: List<Int>): Boolean {
    val visited = mutableSetOf<Int>()
    pages.forEach { page ->
        // pages before must not be required to come after the current page
        if (constraints.getValue(page).intersect(visited).size > 0) {
            return false;
        }
        visited.add(page)
    }
    return true
}