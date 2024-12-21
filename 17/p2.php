<?php
if ($argc < 2) {
    echo "No file included!\n";
    exit(1);
}

$lines = file($argv[1]);

$original_registers = [0, 0, 0];

for ($i = 1; $i < 3; $i++) {
    preg_match("/[0-9]+/", $lines[$i], $match);
    $original_registers[$i] = (int) $match[0];
}

preg_match("/[0-9]+(,[0-9]+)*/", $lines[4], $program);
$program = explode(",", $program[0]);
for ($i = 0; $i < sizeof($program); $i++) {
    $program[$i] = (int) $program[$i];
}

$registers = [];
$rip = 0;
$buffer = [];

function reset_machine($a) {
    global $registers, $original_registers, $rip, $buffer;
    $registers = $original_registers;
    $registers[0] = $a;
    $rip = 0;
    $buffer = [];
}

function quine_achieved() {
    global $buffer, $program;
    return $buffer === $program;
}

function opcode() {
    global $program, $rip;
    return $program[$rip];
}

function operand() {
    global $program, $rip;
    return $program[$rip+1];
}

function skip() {
    global $rip;
    $rip += 2;
}

function combo_operand($literal_operand) {
    global $registers;
    switch ($literal_operand) {
        case 0:
        case 1:
        case 2:
        case 3:
            return $literal_operand;
        case 4:
            return $registers[0];
        case 5:
            return $registers[1];
        case 6:
            return $registers[2];
        default:
            echo "WTF\n";
            exit(1);
    }
}

function _dv($i) {
    global $registers;
    $registers[$i] = $registers[0] >> combo_operand(operand());
    skip();
}

// opcode 0
function adv() {
    _dv(0);
}

// opcode 1
function bxl() {
    global $registers;
    $registers[1] ^= operand();
    skip();
}

// opcode 2
function bst() {
    global $registers;
    $registers[1] = combo_operand(operand()) % 8;
    skip();
}

// opcode 3
function jnz() {
    global $registers, $rip;
    if ($registers[0] == 0) {
        skip();
    } else {
        $rip = operand();
    }
}

// opcode 4
function bxc() {
    global $registers;
    $registers[1] ^= $registers[2];
    skip();
}

// opcode 5
function out() {
    global $buffer;
    $val = combo_operand(operand()) % 8;
    array_push($buffer, $val);
    skip();
}

// opcode 6
function bdv() {
    _dv(1);
}

// opcode 7
function cdv() {
    _dv(2);
}

function run_to_end($candidate_a) {
    global $rip, $program;
    reset_machine($candidate_a);
    while ($rip < sizeof($program)) {
        switch (opcode()) {
            case 0: adv(); break;
            case 1: bxl(); break;
            case 2: bst(); break;
            case 3: jnz(); break;
            case 4: bxc(); break;
            case 5: out(); break;
            case 6: bdv(); break;
            case 7: cdv(); break;
            default:
                echo "WTF 2.0\n";
                exit(1);
        }
    }
}

# https://todd.ginsberg.com/post/advent-of-code/2024/day17/
# basically, every 3 bit segment in register A corresponds to a number in the
# output buffer
# so the most significant 3 bits are the last number to be outputted by opcode 5
# since they are the last to get that mod 8 treatment 
# start by finding the most significant 3 bits and see if they yield the last
# number in the output, then get the next most significant 3 bits for the
# second last number, and so on until you reached the first output number
$candidates = [0];

for ($program_index = sizeof($program) - 1; $program_index >= 0; $program_index--) {
    $new_candidates = [];
    foreach ($candidates as $candidate) {
        $candidate <<= 3;
        foreach (range($candidate, $candidate+8) as $next_candidate) {
            run_to_end($next_candidate);
            if ($buffer[0] === $program[$program_index]) {
                array_push($new_candidates, $next_candidate);
            }
        }
    }
    $candidates = $new_candidates;
}

# sort candidates so we can find the smallest one
sort($candidates);

foreach ($candidates as $candidate) {
    run_to_end($candidate);
    if (quine_achieved()) {
        echo "$candidate\n";
        break;
    }
}
?>