#!/usr/bin/perl
 
# Solomon's Game Board done in SVG
 
use strict;
use warnings;
use SVG;  # https://metacpan.org/pod/SVG
 
# with margins at .25, SCALE of 142*9.5 (last row of dots) fits on an A4
use constant SCALE 	=> '67';	# dots per inch scale, adjust to fit on your board
use constant DOTSIZE	=> '7';		# should be an odd number
use constant LINEWIDTH	=> '3';		# should be an odd number
use constant FILL 	=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE	=> 'black';	# can be 'rgb(0,0,0)'  too
 
my $title = "Solomon's Game";
 
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
 
# Line Coorids calculated based off of knowing that the
# hex was made up of equilateral isoceles triangles
# known formulas for calculating all coorids based on 
# legs only.  
 
# line points
my $nwx = $ctr - .5 * $leg3;
my $nwy = $ctr - (sqrt(3)/2)*$leg3;
my $sex = $ctr + .5 * $leg3;
my $sey = $ctr + (sqrt(3)/2)*$leg3;
my $swx = $ctr - .5 * $leg3;
my $swy = $ctr + (sqrt(3)/2)*$leg3;
my $nex = $ctr + .5 * $leg3;
my $ney = $ctr - (sqrt(3)/2)*$leg3;
 
# Lines are xy start and xy stop coordinates, in inches/scaled
my %l = (
	la => [$leg1,$ctr,$nex,$ney],	# W to NE
	lb => [$leg1,$ctr,$leg7,$ctr],	# W to E
	lc => [$leg1,$ctr,$sex,$sey],	# W to SE
	ld => [$nwx,$nwy,$swx,$swy],	# NW to SW
	le => [$nwx,$nwy,$sex,$sey],	# NW to SE
	lf => [$nwx,$nwy,$leg7,$ctr],	# NW to E
	lg => [$nex,$ney,$sex,$sey],	# NE to SE
	lh => [$nex,$ney,$swx,$swy],	# NE to SW
	li => [$leg7,$ctr,$swx,$swy],	# E to SW
);
 
# Circles are x,y,size and fill
my %cs = (
	ca => [$leg1,$ctr,.1,1],
	cb => [$leg7,$ctr,.1,1],
);
 
#----------------------------------------------
# Logic, no reason for sort but to help me see data
#----------------------------------------------
# add some lines by looping over lines hash
foreach my $cor (sort keys %l) {
	lines($l{$cor}[0],$l{$cor}[1],$l{$cor}[2],$l{$cor}[3]);
}
 
# make our circles by looping over circle hash
foreach my $cs (sort keys %cs) {
	circles($cs{$cs}[0],$cs{$cs}[1],$cs{$cs}[2],$cs{$cs}[3]);
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
# lines sub
# really a 2 point polygon, instead of the "lines" function
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
 
 
# now render the SVG object, implicitly use svg namespace
print $svg->xmlify;