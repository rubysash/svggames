#!/usr/bin/perl
 
 
# Pretwa Board done in SVG
 
use strict;
use warnings;
use SVG;  # https://metacpan.org/pod/SVG
 
# with margins at .25, SCALE of 142*9.5 (last row of dots) fits on an A4
use constant SCALE 		=> '67';	# dots per inch scale, adjust to fit on your board
use constant DOTSIZE	=> '7';	# should be an odd number
use constant LINEWIDTH	=> '3'; 	# should be an odd number
use constant FILL 		=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE		=> 'black';	# can be 'rgb(0,0,0)'  too
 
my $title = "Pretwa";
 
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
 
# everything is based off of the segment length
# of the circle radius, so "legs" of various length
# used throughout rest of the math
my $leg1 = (8/7);		# 1.1428571429
my $leg2 = (8/7) * 2; 	# 2.2857142857
my $leg3 = (8/7) * 3;	# 3.4285714286
my $leg4 = (8/7) * 4;	# 4.5714285714
my $leg5 = (8/7) * 5;	# 
my $leg6 = (8/7) * 6;	# 
my $leg7 = (8/7) * 7;	# 
my $ctr  = (8/7) * 4;	# 4.5714285714, for code readability
 
 
# Circles
my %cs = (
	# x, y, size, fill
	ca => [$ctr,$ctr,$leg1,0],
	cb => [$ctr,$ctr,$leg2,0],
	cc => [$ctr,$ctr,$leg3,0],
);
 
# Line Coorids calculated based off of knowing that the
# hex was made up of equilateral isoceles triangles
# known formulas for calculating all coorids based on 
# legs only.   I only had to draw an X in the right spot
# the horizontal line didn't need much math.
# NW to SE
my $nwx = $ctr - .5 * $leg3;
my $nwy = $ctr - (sqrt(3)/2)*$leg3;
my $sex = $ctr + .5 * $leg3;
my $sey = $ctr + (sqrt(3)/2)*$leg3;
 
# SW to NE
my $swx = $ctr - .5 * $leg3;
my $swy = $ctr + (sqrt(3)/2)*$leg3;
my $nex = $ctr + .5 * $leg3;
my $ney = $ctr - (sqrt(3)/2)*$leg3;
 
# Lines are xy start and xy stop coordinates, in inches
my %l = (
	# x  y   x   y
	lb => [$nwx,$nwy,$sex,$sey],	# NW to SE
	lc => [$swx,$swy,$nex,$ney],	# SW to NE
	ld => [$leg1,$leg4,$leg7,$leg4],# E to W
);
 
# Dots started with hash of arrays containing the central xy
my %dots = (
	0 => [$ctr,$ctr],
);
 
# make the coorindate dots not on the cetner line
# 4 permutations, 3 different variables per permutation
# chose to loop over instead of manually write up all dots
my $counter = 1;
foreach my $leg ($leg1,$leg2,$leg3) {
	my $dx1 = $ctr - .5 * $leg;
	my $dy1 = $ctr - (sqrt(3)/2)*$leg;
	$dots{$counter}[0] = $dx1;
	$dots{$counter}[1] = $dy1; $counter++;
	
	$dx1 = $ctr + .5 * $leg;
	$dy1 = $ctr + (sqrt(3)/2)*$leg;
	$dots{$counter}[0] = $dx1;
	$dots{$counter}[1] = $dy1; $counter++;
 
	$dx1 = $ctr - .5 * $leg;
	$dy1 = $ctr + (sqrt(3)/2)*$leg;
	$dots{$counter}[0] = $dx1;
	$dots{$counter}[1] = $dy1; $counter++;
 
	$dx1 = $ctr + .5 * $leg;
	$dy1 = $ctr - (sqrt(3)/2)*$leg;
	$dots{$counter}[0] = $dx1;
	$dots{$counter}[1] = $dy1; $counter++;
 }
 
# all of the dots on the center line
foreach my $leg ($leg1,$leg2,$leg3,$leg4,$leg5,$leg6,$leg7) {
	$dots{$counter}[0] = $leg;
	$dots{$counter}[1] = $ctr;
	$counter++;
}
 
 
#----------------------------------------------
# Logic, no reason for sort but to help me see data
#----------------------------------------------
# make our circles
foreach my $cs (sort keys %cs) {
	circles($cs{$cs}[0],$cs{$cs}[1],$cs{$cs}[2],$cs{$cs}[3]);
}
 
# add some lines
foreach my $cor (sort keys %l) {
	lines($l{$cor}[0],$l{$cor}[1],$l{$cor}[2],$l{$cor}[3]);
}
 
# add the dots
foreach my $cor (sort keys %dots) {
	dots($dots{$cor}[0],$dots{$cor}[1]);
}
 
# Text, at SCALE of 142, 6.5 letters per inch, Serif Font
# Text, at SCALE of 96, 5 letters per inche, Serif Font
# Take half of estimated lenght of title, subtract it from center
# that should start half before center, and then half after center
# adjust the /5 down to move left, up to move right
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
# dots sub - basically small circles on xy coorids
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
# circles - x,y start, radius and fill opacity
#----------------------------------------------
sub circles {
	my $x = shift;
	my $y = shift;
	my $r = shift;
	my $fop = shift;
 
	$svg->circle(
	    cx => $x * SCALE,
	    cy => $y * SCALE,
	    r  => $r * SCALE,
	    style => {
        	'fill'           => FILL,
        	'stroke'         => STROKE,
        	'stroke-width'   =>  3,
        	'stroke-opacity' =>  1,
        	'fill-opacity'   =>  $fop,
    	},
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
 
	#print "$xstart,$ystart,$xstop,$ystop\n";
 
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
