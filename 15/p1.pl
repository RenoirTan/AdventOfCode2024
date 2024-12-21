use feature ':5.40';
use strict;
use warnings;

use Path::Tiny;
use builtin qw(trim);
use autodie;

if (!defined $ARGV[0]) {
    say "No file included!";
}

my $file = path($ARGV[0])->openr_utf8();

my @warehouse = ();

while (my $line = $file->getline()) {
    $line = trim($line);
    if (length($line) == 0) {
        last;
    }
    push(@warehouse, $line);
}

my $moves = "";

while (my $line = $file->getline()) {
    $moves .= trim($line);
}

close($file);

my $height = @warehouse;
my $width = length($warehouse[0]);
my $x = 0;
my $y = 0;

sub show_warehouse {
    for my $s (@warehouse) {
        say $s;
    }
}

for my $ty (0..($height-1)) {
    my $tx = index($warehouse[$ty], "@");
    if ($tx >= 0) {
        $x = $tx;
        $y = $ty;
        last;
    }
}

sub make_move($line_of_sight) {
    my $los_length = length($line_of_sight);
    return "." . "@" . ("O" x ($los_length - 2));
}

sub go_up {
    my $line_of_sight = "";
    for (my $ty = $y; $ty >= 0; $ty--) {
        my $cell = substr($warehouse[$ty], $x, 1);
        if ($cell eq "#") {
            return;
        }
        $line_of_sight .= $cell;
        if ($cell eq ".") {
            last;
        }
    }
    my $los_length = length($line_of_sight);
    my $updated = make_move($line_of_sight);
    my $translation = index($updated, "@");
    for my $dy (0..($los_length-1)) {
        substr($warehouse[$y-$dy], $x, 1, substr($updated, $dy, 1));
    }
    $y -= $translation;
}

sub go_down {
    my $line_of_sight = "";
    for (my $ty = $y; $ty < $height; $ty++) {
        my $cell = substr($warehouse[$ty], $x, 1);
        if ($cell eq "#") {
            return;
        }
        $line_of_sight .= $cell;
        if ($cell eq ".") {
            last;
        }
    }
    my $los_length = length($line_of_sight);
    my $updated = make_move($line_of_sight);
    my $translation = index($updated, "@");
    for my $dy (0..($los_length-1)) {
        substr($warehouse[$y+$dy], $x, 1, substr($updated, $dy, 1));
    }
    $y += $translation;
}

sub go_right {
    my $sliced = substr($warehouse[$y], $x);
    my $los_length = index($sliced, ".") + 1;
    if ($los_length == 0 or index($sliced, "#") <= ($los_length - 2)) {
        return;
    }
    my $line_of_sight = substr($warehouse[$y], $x, $los_length);
    my $updated = make_move($line_of_sight);
    my $translation = index($updated, "@");
    substr($warehouse[$y], $x, $los_length, $updated);
    $x += $translation;
}

sub go_left {
    my $reversed = reverse(substr($warehouse[$y], 0, $x + 1));
    my $los_length = index($reversed, ".") + 1;
    if ($los_length == 0 or index($reversed, "#") <= ($los_length - 2)) {
        return;
    }
    my $line_of_sight = substr($reversed, 0, $los_length);
    my $updated = make_move($line_of_sight);
    my $translation = index($updated, "@");
    substr($warehouse[$y], $x-$los_length+1, $los_length, reverse($updated));
    $x -= $translation;
}

# show_warehouse();

for my $move (split("", $moves)) {
    # say $move;
    if ($move eq "^") {
        go_up();
    } elsif ($move eq "v") {
        go_down();
    } elsif ($move eq "<") {
        go_left();
    } elsif ($move eq ">") {
        go_right();
    } else {
        die $move;
    }
    # show_warehouse();
}

show_warehouse();

my $sum = 0;
for my $ty (0..($height-1)) {
    for my $tx (0..($width-1)) {
        if (substr($warehouse[$ty], $tx, 1) eq "O") {
            $sum += $ty * 100 + $tx;
        }
    }
}

say $sum;