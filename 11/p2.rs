use std::env;
use std::fs::OpenOptions;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("No file included!");
    }
    let file = OpenOptions::new().read(true).open(&args[1]).unwrap();
    let reader = BufReader::new(file);
    let line = reader.lines().next().unwrap().unwrap();
    let stones: Vec<u64> = line.split(" ")
        .map(|s| s.parse::<u64>().unwrap())
        .collect();
    let mut engine = Engine::new(stones);
    // println!("{:?}", stones);
    for _ in 0..75 {
        // println!("{:?}", engine.counter);
        engine.update();
        // println!("{:?}", stones);
    }
    println!("{}", engine.count());
}

struct Engine {
    pub counter: HashMap<u64, usize>
}

impl Engine {
    fn new(stones: Vec<u64>) -> Self {
        let mut counter = HashMap::new();
        for stone in stones {
            if let Some(count) = counter.get_mut(&stone) {
                *count += 1;
            } else {
                counter.insert(stone, 1_usize);
            }
        }
        Self { counter }
    }

    fn update(&mut self) {
        let mut new_counter = HashMap::new();
        for (stone, count) in &self.counter {
            let stone = *stone;
            let count = *count;
            for new_stone in new_stones(stone) {
                if let Some(new_count) = new_counter.get_mut(&new_stone) {
                    *new_count += count;
                } else {
                    new_counter.insert(new_stone, count);
                }
            }
        }
        self.counter = new_counter;
    }

    fn count(&self) -> usize {
        self.counter.values().sum()
    }
}

#[inline]
fn new_stones(stone: u64) -> Vec<u64> {
    //let stone = *stone;
    if stone == 0 {
        vec![1]
    } else {
        let d = count_digits(stone);
        if d % 2 == 0 {
            let cutoff: u64 = 10_u64.pow((d / 2) as u32);
            vec![stone/cutoff, stone%cutoff]
        } else {
            vec![stone*2024]
        }
    }
}

#[inline]
fn count_digits(stone: u64) -> u64 {
    stone.ilog10() as u64 + 1
}