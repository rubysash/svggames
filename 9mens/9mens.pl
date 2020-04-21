#!/usr/bin/perl
 
# 9 Men's Morris Board done in SVG
# https://en.wikipedia.org/wiki/Nine_men%27s_morris

 
use strict;
use warnings;
use SVG;  # https://metacpan.org/pod/SVG
 
# with margins at .25, SCALE of 142*9.5 (last row of dots) fits on an A4
use constant SCALE 	=> '67';	# dots per inch scale, adjust to fit on your board
use constant DOTSIZE	=> '7';		# should be an odd number to exactly center
use constant LINEWIDTH	=> '3'; 	# should be an odd number to exactly center
use constant FILL 	=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE	=> 'black';	# can be 'rgb(0,0,0)'  too
 
# create an SVG object, canvas which we use for the rest of the draws
my $svg = SVG->new(
    width  => 9 * SCALE,
    height => 10 * SCALE,
);
 
#----------------------------------------------
# Define the dots, lines, squares, circles etc
# Order isn't important, all is eventually drawn
# SVG has max of 2-4k objects before browser gets sluggish
# keys are sorted alpha for debug reasons
#----------------------------------------------
# Dots are x,y cooridianates, in inches (scaled inches anyway).
my %dots = (
	# col1
	da => [.5,.5],
	db => [.5,4.5],
	dc => [.5,8.5],
	# col2
	dd => [1.5,1.5],
	de => [1.5,4.5],
	df => [1.5,7.5],
	# col3
	dg => [2.5,2.5],
	dh => [2.5,4.5],
	di => [2.5,6.5],
	# col4
	dj => [4.5,.5],
	dk => [4.5,1.5],
	dl => [4.5,2.5],
	dm => [4.5,6.5],
	dn => [4.5,7.5],
	do => [4.5,8.5],
	# col5
	dp => [6.5,2.5],
	dq => [6.5,4.5],
	dr => [6.5,6.5],
	# col6
	ds => [7.5,1.5],
	dt => [7.5,4.5],
	du => [7.5,7.5],
	# col7
	dv => [8.5,.5],
	dw => [8.5,4.5],
	dx => [8.5,8.5]
);
 
# Lines are xy start and xy stop coordinates, in inches
my %l = (
	# x  y   x   y
	la => [4.5,.5,4.5,2.5],		# N
	lb => [6.5,4.5,8.5,4.5],	# E
	lc => [4.5,6.5,4.5,8.5],	# S
	ld => [.5,4.5,2.5,4.5],		# W
);
 
# Squares are xy start then l,w in inches
my %sqs = (
	sa => [.5,.5,8,8],		# Outer
	sb => [1.5,1.5,6,6],	# Middle
	sc => [2.5,2.5,4,4]		# Inner
);
 
#----------------------------------------------
# Logic, no reason for sort but to help me see data
#----------------------------------------------
# make our squares
foreach my $sq (sort keys %sqs) {
	squares($sqs{$sq}[0],$sqs{$sq}[1],$sqs{$sq}[2],$sqs{$sq}[3]);
}
 
# add the dots
foreach my $cor (sort keys %dots) {
	dots($dots{$cor}[0],$dots{$cor}[1]);
}
 
# add some lines
foreach my $cor (sort keys %l) {
	lines($l{$cor}[0],$l{$cor}[1],$l{$cor}[2],$l{$cor}[3]);
}
 
 
# Text, at SCALE of 142, 6.5 letters per inch, Serif Font
# Text, at SCALE of 96, 5 letters per inche, Serif Font
# Take half of estimated lenght of title, subtract it from center
# that should start half before center, and then half after center
# adjust the /5 down to move left, up to move right
my $title = "9 Men's Morris";
my $ltitle = length($title);
my $xtitle = 4.5 * SCALE - ($ltitle/4.5 * SCALE)/2;
 
$svg->text(
    id => 'l1',
    x  => $xtitle,
    y  => SCALE * 9.5, 
	style     => {
        'font'      => 'Serif',
        'font-size' => 32,
        'fill'      => FILL,
    },
    )->cdata($title);
 
#----------------------------------------------
# square sub
#----------------------------------------------
sub squares {
 
	my $x = shift;
	my $y = shift;
	my $w = shift;
	my $h = shift;
 
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
	        'fill-opacity'   => 0,	# must be 0, for lines, or 1 for solid squares
	    }
	);
}
 
#----------------------------------------------
# dots sub
#----------------------------------------------
sub dots {
	# takes 2 arguments, makes  a dot
	my $x = shift;
	my $y = shift;
	$svg->circle(
		cx => $x * SCALE,
		cy => $y * SCALE,
		r  => DOTSIZE,
	);
}
 
#----------------------------------------------
# lines sub
# really a 2 point polygon, and lines
#----------------------------------------------
sub lines { 
	# 4 arguments, xstart, ystart, xstop, ystop
	my $xstart = SCALE * shift;
	my $ystart = SCALE * shift;
	my $xstop = SCALE * shift;
	my $ystop = SCALE * shift;
 
	my $path = $svg->get_path(
    	x => [$xstart,$xstop],
    	y => [$ystart,$ystop],
    	-type => 'polygon');
 
	$svg->polygon(
	    %$path,
	    style => {
	        'fill'           => FILL,
	        'stroke'         => STROKE,
	        'stroke-width'   => LINEWIDTH,
	        'stroke-opacity' => 1,
	        'fill-opacity'   => 1,
	    },
	);
}
 
 
 
 
# now render the SVG object, implicitly use svg namespace
print $svg->xmlify;