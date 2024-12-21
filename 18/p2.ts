import { readFileSync } from "fs";

if (process.argv.length < 3) {
  console.error("No file included!");
  process.exit(1);
}

const [{width, height, elapsed}, coords]: [
  {width: number; height: number; elapsed: number},
  [number, number][]
] = (() => {
  const fp = process.argv[2];
  const fileContents = readFileSync(fp, "utf-8");
  const lines = fileContents.split("\n");
  const preambleLine = lines.shift();
  const preamble = {
    width: +(preambleLine?.match(/w=(\d+)/)?.at(1)!),
    height: +(preambleLine?.match(/h=(\d+)/)?.at(1)!),
    elapsed: +(preambleLine?.match(/f=(\d+)/)?.at(1)!)
  };
  const coords: [number, number][] = lines.map(line => {
    const [x, y] = line.split(",").map(n => +n);
    return [x, y];
  });
  return [preamble, coords];
})();

const splitCoord = (i: number): [number, number] => [i % width, Math.floor(i / width)];
const unifyCoord = ([x, y]: [number, number]): number => y * width + x;

function simulate(obstacles: Set<number>) {
  const visited = new Set<number>();
  const queue: [number, number][] = [[0, 0]];

  const isDisallowed = function (i: number): boolean {
    return (visited.has(i) || obstacles.has(i));
  }

  while (queue.length >= 1) {
    // console.log(queue);
    const [unified, count] = queue.shift()!;
    const [x, y] = splitCoord(unified);
    if (x == width - 1 && y == height - 1) {
      return count;
    }
    if (isDisallowed(unified)) {
      continue;
    } else {
      visited.add(unified);
    }
    if (x >= 1 && !isDisallowed(unifyCoord([x - 1, y]))) {
      queue.push([unifyCoord([x - 1, y]), count + 1]);
    }
    if (x < (width - 1) && !isDisallowed(unifyCoord([x + 1, y]))) {
      queue.push([unifyCoord([x + 1, y]), count + 1]);
    }
    if (y >= 1 && !isDisallowed(unifyCoord([x, y - 1]))) {
      queue.push([unifyCoord([x, y - 1]), count + 1]);
    }
    if (y < (width - 1) && !isDisallowed(unifyCoord([x, y + 1]))) {
      queue.push([unifyCoord([x, y + 1]), count + 1]);
    }
  }
  return -1;
}

function searchCutoff(coords: [number, number][]): number {
  let low = 0;
  let mid = 0;
  let high = coords.length - 1;
  const unifiedCoords = coords.map(unifyCoord);

  while (low < high) {
    mid = Math.floor((low + high) / 2);
    // console.log({ low, mid, high });
    const simResult = simulate(new Set(unifiedCoords.slice(0, mid)));
    if (simResult === -1) {
      high = mid;
    } else {
      low = mid + 1;
    }
  }
  return Math.floor((low + high) / 2);
}

const [x, y] = coords[searchCutoff(coords) - 1];

console.log(`${x},${y}`);