use feature ':5.40';
use strict;
use warnings;

use Path::Tiny;
use builtin qw(trim);
use autodie;

if (!defined $ARGV[0]) {
    die "No file included!";
}

my $file = path($ARGV[0])->openr_utf8();

my @warehouse = ();

sub show_warehouse {
    for my $s (@warehouse) {
        say $s;
    }
}

while (my $line = $file->getline()) {
    $line = trim($line);
    if (length($line) == 0) {
        last;
    }
    $line =~ s/\./\.\./g;
    $line =~ s/#/##/g;
    $line =~ s/O/[]/g;
    $line =~ s/@/@./g;
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

for my $ty (0..($height-1)) {
    my $tx = index($warehouse[$ty], "@");
    if ($tx >= 0) {
        $x = $tx;
        $y = $ty;
        last;
    }
}

# generates @tower, an array of boxes where each box is either higher than or
# at the same height as the previous box
sub build_moveable_tower($dy) {
    my @tower = (); # a shitty binary tree
    my $adjacent = substr($warehouse[($y + $dy)], $x, 1);
    if ($adjacent eq "[") {
        push(@tower, [$x, $y + $dy]);
    } elsif ($adjacent eq "]") {
        push(@tower, [$x - 1, $y + $dy]);
    } else {
        return ();
    }
    my $i = 0;
    while ($i < scalar @tower) { # still have more unvisited blocks
        my $bx = $tower[$i][0];
        my $by = $tower[$i][1];
        # say $bx, " ", $by;
        my $next_left = substr($warehouse[$by + $dy], $bx, 1);
        my $next_right = substr($warehouse[$by + $dy], $bx + 1, 1);
        # if there is a wall, unmoveable
        if ($next_left eq "#" or $next_right eq "#") {
            return ();
        }
        if ($next_left eq "[") {
            push(@tower, [$bx, $by + $dy]);
        } elsif ($next_left eq "]") {
            push(@tower, [$bx - 1, $by + $dy]);
        }
        if ($next_right eq "[") {
            push(@tower, [$bx + 1, $by + $dy]);
        }
        $i++;
    }
    return @tower;
}

# assume that all boxes in @tower are either higher than or at the same height
# as the previous box
sub move_tower($tower_ref, $dy) {
    my @tower = @$tower_ref;
    for (my $i = $#tower; $i >= 0; $i--) {
        my $bx = $tower[$i][0];
        my $by = $tower[$i][1];
        substr($warehouse[$by + $dy], $bx, 2, "[]");
        substr($warehouse[$by], $bx, 2, "..");
    }
}

sub go_up {
    my @tower = build_moveable_tower(-1);
    if (@tower) {
        move_tower(\@tower, -1);
    }
    if (substr($warehouse[$y - 1], $x, 1) eq ".") {
        substr($warehouse[$y - 1], $x, 1, "@");
        substr($warehouse[$y], $x, 1, ".");
        $y--;
    }
}

sub go_down {
    my @tower = build_moveable_tower(1);
    if (@tower) {
        move_tower(\@tower, 1);
    }
    if (substr($warehouse[$y + 1], $x, 1) eq ".") {
        substr($warehouse[$y + 1], $x, 1, "@");
        substr($warehouse[$y], $x, 1, ".");
        $y++;
    }
}

sub go_right {
    my $sliced = substr($warehouse[$y], $x);
    my $los_length = index($sliced, ".") + 1;
    if ($los_length == 0 or index($sliced, "#") <= ($los_length - 2)) {
        return;
    }
    # my $line_of_sight = substr($warehouse[$y], $x, $los_length);
    my $updated = "." . "@" . ("[]" x (($los_length - 2) / 2));
    substr($warehouse[$y], $x, $los_length, $updated);
    $x++;
}

sub go_left {
    my $reversed = reverse(substr($warehouse[$y], 0, $x + 1));
    my $los_length = index($reversed, ".") + 1;
    if ($los_length == 0 or index($reversed, "#") <= ($los_length - 2)) {
        return;
    }
    # my $line_of_sight = substr($reversed, 0, $los_length);
    my $updated = "." . "@" . ("][" x (($los_length - 2) / 2));
    substr($warehouse[$y], $x-$los_length+1, $los_length, reverse($updated));
    $x--;
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

# show_warehouse();

my $sum = 0;
for my $ty (0..($height-1)) {
    for my $tx (0..($width-1)) {
        if (substr($warehouse[$ty], $tx, 1) eq "[") {
            $sum += $ty * 100 + $tx;
        }
    }
}

say $sum;