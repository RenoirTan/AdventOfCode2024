<?php
if ($argc < 2) {
    echo "No file included!\n";
    exit(1);
}

$lines = file($argv[1]);

$registers = [0, 0, 0];

for ($i = 0; $i < 3; $i++) {
    preg_match("/[0-9]+/", $lines[$i], $match);
    $registers[$i] = (int) $match[0];
}

preg_match("/[0-9]+(,[0-9]+)*/", $lines[4], $program);
$program = explode(",", $program[0]);
for ($i = 0; $i < sizeof($program); $i++) {
    $program[$i] = (int) $program[$i];
}

$rip = 0;
$buffer = [];

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
echo implode(",", $buffer);
echo "\n";
?>