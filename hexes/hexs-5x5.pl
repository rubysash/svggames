#!/usr/bin/perl
 
# Hex Mapper
 
use strict;
use warnings;
use SVG;  # https://metacpan.org/pod/SVG
 
# using scale of 66 here, and then 66 in estlecam to create
# the CNC files to fit on an 11x11 board of wood
use constant SCALE      => '66';    # dots per inch scale, adjust to fit on your board
use constant DOTSIZE    => '7';     # should be an odd number
use constant LINEWIDTH  => '3';     # should be an odd number
use constant FILL       => 'black'; # can be 'rgb(0,0,0)'  too
use constant STROKE     => 'black'; # can be 'rgb(0,0,0)'  too

# title auto centers  
my $title = "5x5 Hex (Triad/Aboyne/Bolix/Abalone)";
 
# create an SVG object, canvas which we use for the rest of the draws
my $svg = SVG->new(
    width  => 11 * SCALE,
    height => 11 * SCALE,
);
 
# only adjust this for changing hexes per page
# 4x4= 2.5
# 5x5= 3.0  
# 6x6= 3.5
# Larger hexsize = smaller hexes
my $hexsize = 3; 

#----------------------------------------------
# Define the dots, lines, squares, circles etc
# everything is based off of the segment length
# of the circle radius, so "legs" of various length
# used throughout rest of the math
#----------------------------------------------
# 8 inch game board (11 inches with 1.5 inch boarder)
# done so I could scale easier to fit my workpiece
my $leg1 = (8/6);       # 1.3333333333 (does this matter?)
my $leg2 = ($leg1) * 2; # 2.6666666666
my $leg3 = ($leg1) * 3; # 3.9999999999
my $hex  = (SCALE/$hexsize);   # 
my $ctr  = 5.5; # because our board is 11x11, so 5.5x5.5 is center
 
# Squares are xy start then l,w in inches
my %squares = (
    sa => [0,0,11,11,0],        # border/edge of board
);
 
# color was used for debugging
my %c = (
    'b' => 'black',
    'r' => 'red',
    'l' => 'blue',
    'w' => 'white',
    'g' => 'green',
    'y' => 'yellow',
    'o' => 'orange',
    'k' => 'pink',
    'p' => 'purple',
    'e' => 'grey',
    'lg' => 'LightGray', # D3D3D3
    'bg' => 'Beige' # F5F5DC
);
 
# xysteps are how far to go until next hex
my $ystep = 0;
my $xstep = 0;
 
# what is the center of our board?
my $xs = $ctr * SCALE;
my $ys = $ctr * SCALE;
 
    my $hc = 100; # just a counter to start the hex ID
   
    # find the NW corner to start from
    my $ystart = hexstart(4,$hex,$xs,$ys,'y');
    my $xstart = hexstart(4,$hex,$xs,$ys,'x');
    hexes($hc, $hex , $xstart,$ystart, $c{w},'sw');
 
    # ok, do the rest, in a smaller and smaller radius, clockwise
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'sw');}
    for (0..3) {hexes($hc, $hex , $xs,$ys, $c{w},'se');}
    for (0..3) {hexes($hc, $hex , $xs,$ys, $c{w},'e');}
    for (0..3) {hexes($hc, $hex , $xs,$ys, $c{w},'ne');}
    for (0..3) {hexes($hc, $hex , $xs,$ys, $c{w},'nw');}
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'w');}
                hexes($hc, $hex , $xs,$ys, $c{w},'sw');
 
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'sw');}
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'se');}
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'e');}
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'ne');}
    for (0..2) {hexes($hc, $hex , $xs,$ys, $c{w},'nw');}
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'w');}
                hexes($hc, $hex , $xs,$ys, $c{w},'sw');
 
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'sw');}
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'se');}
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'e');}
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'ne');}
    for (0..1) {hexes($hc, $hex , $xs,$ys, $c{w},'nw');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'w');}
                hexes($hc, $hex , $xs,$ys, $c{w},'sw');
 
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'sw');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'se');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'e');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'ne');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'nw');}
    for (1..1) {hexes($hc, $hex , $xs,$ys, $c{w},'sw');}
                hexes($hc, $hex , $xs,$ys, $c{w},'sw');
 
#----------------------------------------------
# Logic, no reason for sort but to help me see data when debugging
#----------------------------------------------
# make our squares
foreach my $square (sort keys %squares) {
    squares($squares{$square}[0],$squares{$square}[1],$squares{$square}[2],$squares{$square}[3],$squares{$square}[4]);
}
 
# for SVG< keep - but will probably delete for boards
title($title);
 
#----------------------------------------------
# customs - accepts custom data paths
#----------------------------------------------
sub hexstart {
    my $hops  = shift;
    my $size  = shift;
    my $strtx = shift;
    my $strty = shift;
    my $xy = shift;
 
    my ($hx1,$hy1,$hx2,$hy2,$hx3,$hy3,$hx4,$hy4,$hx5,$hy5,$hx6,$hy6,$hx7,$hy7);
    $hy6 = $strty + ((sqrt(3)/2) * $size) * 2;
    $hy2 = $strty - ((sqrt(3)/2) * $size);
 
    if ($xy eq 'y') {return $strty + ($hy2 - $hy6) * $hops;}
    if ($xy eq 'x') {return $strtx - (1.5 * $size) * $hops;}
}
 
sub hexes {
    #d='M 3130,5385 4012,5385 4453,6149 4012,6912 3130,6912 2689,6149 3130,5385  Z'
    # takes 6 points to make a hex.
    # takes xy start and builds hex with length from there
   
    my $id = shift;
    my $sz = shift;
    my $sx = shift;
    my $sy = shift;
    my $color = shift;
    my $dir = shift;
    my ($hx1,$hy1,$hx2,$hy2,$hx3,$hy3,$hx4,$hy4,$hx5,$hy5,$hx6,$hy6,$hx7,$hy7);
 
    # xy coorids for a scaled single hex based on sx and sy starts
    # begins at sw the goes clockwise for others, building custom string
    $hx1 = $sx - 1.5 * $sz;
    $hy1 = $sy + ((sqrt(3)/2) * $sz);
    $hx2 = $sx - 1.5 * $sz;
    $hy2 = $sy - ((sqrt(3)/2) * $sz);
    $hx3 = $sx;
    $hy3 = $sy - ((sqrt(3)/2) * $sz) * 2;
    $hx4 = $sx + .5 * 3 * $sz;
    $hy4 = $sy - ((sqrt(3)/2) * $sz);
    $hx5 = $sx + .5 * 3 * $sz;
    $hy5 = $sy + ((sqrt(3)/2) * $sz);
    $hx6 = $sx;
    $hy6 = $sy + ((sqrt(3)/2) * $sz) * 2;
    $hx7 = $hx1;
    $hy7 = $hy1;
 
    # step direction is which way to place the next hex
    # feed this sub a number of hexes and it goes that
    # direction, that many times.
    if ($dir eq 'nw') {
        $xstep = $sx - 1.5 * $sz;
        $ystep = $sy - ($hy6 - $hy2);
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir eq 'ne') {
        $xstep = $sx + 1.5 * $sz;
        $ystep = $sy - ($hy6 - $hy2);
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir eq 'se') {
        $xstep = $sx + 1.5 * $sz;
        $ystep = $sy + $hy6 - $hy2;
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir eq 'sw') {
        $xstep = $sx - 1.5 * $sz;
        $ystep = $sy + $hy6 - $hy2;
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir eq 'e') {
        $xstep = $sx + (1.5 * $sz) * 2;
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir eq 'w') {
        $xstep = $sx - (1.5 * $sz) * 2;
        $xs = $xstep;
        $ys = $ystep;
    } elsif ($dir == 0) {
        $xs = $ctr * SCALE;
        $ys = $ctr * SCALE;
    }
 
    # no real hex method for perl SVG module, so custom string it:
    my $string = "M $hx1,$hy1 $hx2,$hy2 $hx3,$hy3 $hx4,$hy4 $hx5,$hy5 $hx6,$hy6 $hx7,$hy7 Z";
   
    # add the object.
    my $tag = $svg->path(
        d => $string,
        id    => 'hex_'.$id,
        style => {
            'fill'           => $color,
            'stroke'         => STROKE,
            'stroke-width'   =>  3,
            'stroke-opacity' =>  1,
            'fill-opacity'   =>  1,
        },
    );
 
    # advance hex id counter
    $hc++;
}
#----------------------------------------------
# Text, at SCALE of 142, 6.5 letters per inch, Serif Font
# Text, at SCALE of 96, 5 letters per inche, Serif Font
# Text, at SCALE of 67, 4.5 bleh bleh
# Take half of estimated lenght of title, subtract it from center
# that should start half before center, and then half after center
# adjust the /5 down to move left, up to move right
#----------------------------------------------
sub title {
 
    my $ltitle = length($title);
    my $xtitle = 5.5 * SCALE - ($ltitle /4.5 * SCALE)/2;
 
    $svg->text(
        id => 'l1',
        x  => $xtitle,
        y  => SCALE * .95,
        style     => {
            'font'      => 'Serif',
            'font-size' => SCALE / 2,
            'fill'      => FILL,
        },
        )->cdata($title);
}
 
#----------------------------------------------
# square sub
#----------------------------------------------
sub squares {
    # accepts 6 values:
    #  x y coord, w h specs, fill opacity and line weight
    my $x = shift;
    my $y = shift;
    my $w = shift;
    my $h = shift;
    my $fop = shift;
 
    $svg->rectangle(
        x => $x * SCALE,
        y => $y * SCALE,
        width  => $w * SCALE,
        height => $h * SCALE,
        style => {
            'fill'           => FILL,
            'stroke'         => STROKE,
            'stroke-width'   => LINEWIDTH,
            'stroke-opacity' => 1,
            'fill-opacity'   => $fop,   # must be 0, for lines, or 1 for solid squares
        }
    );
}
 
# now render the SVG object, implicitly use svg namespace
print $svg->xmlify;