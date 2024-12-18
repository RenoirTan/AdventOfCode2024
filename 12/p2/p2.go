package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
    if (len(os.Args) < 2) {
        fmt.Fprintln(os.Stderr, "No file included!")
        os.Exit(1)
    }

    raw_farm, err := os.ReadFile(os.Args[1])
    if err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
    farm := strings.Split(string(raw_farm),"\n")
    height := len(farm)
    width := len(farm[0])
    visited := make(map[int]bool)
    sum := 0
    for y := range height {
        for x := range width {
            sum += GetCost(y*width+x, height, width, farm, &visited)
        }
    }
    fmt.Println(sum)
}

func GetCost(
    start int,
    height, width int,
    farm []string,
    visited *map[int]bool,
) int {
    if (*visited)[start] {
        return 0
    }
    (*visited)[start] = true
    queue := make([]int, 1)
    queue[0] = start
    area := 0
    corners := 0 // between 2 sides is one corner, since the sides are "closed", corners == sides
    cell := farm[start / width][start % width]
    for len(queue) >= 1 {
        c := queue[0]
        queue = queue[1:]
        x := c % width
        y := c / width
        area++
        tt := y >= 1 && farm[y-1][x] == cell
        ll := x >= 1 && farm[y][x-1] == cell
        bb := y < (height - 1) && farm[y+1][x] == cell
        rr := x < (width - 1) && farm[y][x+1] == cell
        tl := x >= 1 && y >= 1 && farm[y-1][x-1] == cell
        tr := x < (width - 1) && y >= 1 && farm[y-1][x+1] == cell
        bl := x >= 1 && y < (height - 1) && farm[y+1][x-1] == cell
        br := x < (width - 1) && y < (height - 1) && farm[y+1][x+1] == cell
        // convex corners
        if (!tt && !ll) { corners++ }
        if (!tt && !rr) { corners++ }
        if (!bb && !ll) { corners++ }
        if (!bb && !rr) { corners++ }
        // concave corners
        if (tt && ll && !tl) { corners++ }
        if (tt && rr && !tr) { corners++ }
        if (bb && ll && !bl) { corners++ }
        if (bb && rr && !br) { corners++ }
        // top
        if y >= 1 && farm[y-1][x] == cell {
            c = (y-1)*width + x
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
        }
        if x >= 1 && farm[y][x-1] == cell {
            c = y*width + x-1
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
        }
        if y < (height - 1) && farm[y+1][x] == cell {
            c = (y+1)*width + x
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
        }
        if x < (width - 1) && farm[y][x+1] == cell {
            c = y*width + x+1
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
        }
    }
    // fmt.Println(string(cell), area, perimeter)
    return area * corners
}