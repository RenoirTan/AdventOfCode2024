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
    perimeter := 0
    cell := farm[start / width][start % width]
    for len(queue) >= 1 {
        c := queue[0]
        queue = queue[1:]
        x := c % width
        y := c / width
        area++
        perimeter += 4
        // top
        if y >= 1 && farm[y-1][x] == cell {
            c = (y-1)*width + x
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
            perimeter--
        }
        if x >= 1 && farm[y][x-1] == cell {
            c = y*width + x-1
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
            perimeter--
        }
        if y < (height - 1) && farm[y+1][x] == cell {
            c = (y+1)*width + x
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
            perimeter--
        }
        if x < (width - 1) && farm[y][x+1] == cell {
            c = y*width + x+1
            if !(*visited)[c] {
                queue = append(queue, c)
                (*visited)[c] = true
            }
            perimeter--
        }
    }
    // fmt.Println(string(cell), area, perimeter)
    return area * perimeter
}