#!/usr/bin/perl
 
# Water Melon Chess Board done in SVG
use strict;
use warnings;
use SVG;  # https://metacpan.org/pod/SVG
 
# with margins at .25, SCALE of 142*9.5 (last row of dots) fits on an A4
use constant SCALE 	=> '66';	# dots per inch scale, adjust to fit on your board
use constant DOTSIZE	=> '7';		# should be an odd number
use constant LINEWIDTH	=> '3'; 	# should be an odd number
use constant FILL 	=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE	=> 'black';	# can be 'rgb(0,0,0)'  too
 
my $title = "Watermelon Chess";
 
# create an SVG object, canvas which we use for the rest of the draws
my $svg = SVG->new(
    width  => 11 * SCALE,
    height => 11 * SCALE,
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
my $leg1 = (8/6);	# 1.1428571429
my $leg2 = ($leg1) * 2; # 2.2857142857
my $leg3 = ($leg1) * 3;	# 3.4285714286
my $leg4 = ($leg1) * 4;	# 4.5714285714
my $ctr  = 5.5;	
 
 
# Circles / Dots
my %circles = (
	# x, y, size, fill
	ca => [$ctr,$ctr,$leg3,0], # the big Juan
	#cb => [$ctr,$ctr-$leg3,$leg1,0], # N but can't do full circles, do arcs instead
	#cc => [$ctr+$leg3,$ctr,$leg1,0], # E, do arcs instead
	#cd => [$ctr,$ctr+$leg3,$leg1,0], # S, do arcs instead
	#ce => [$ctr-$leg3,$ctr,$leg1,0], # W, do arcs instead
	cf => [$ctr,$ctr,$leg1,0],  # the little Juan
 
	cg => [$ctr-$leg3,$ctr,.1,1], # y-axis
	ch => [$ctr-$leg2+$leg1*.15,$ctr,.1,1], # y-axis
	ci => [$ctr-$leg1,$ctr,.1,1], # y-axis
 
	cj => [$ctr+$leg1,$ctr,.1,1], # y-axis
	ck => [$ctr+$leg2-$leg1*.15,$ctr,.1,1], # y-axis
	cl => [$ctr+$leg3,$ctr,.1,1], # y-axis
 
	cm => [$ctr,$ctr,.1,1], #  center
 
	cn => [$ctr,$ctr-$leg3,.1,1], # x-axis
	co => [$ctr,$ctr-$leg2+$leg1*.15,.1,1], # x-axis
	cp => [$ctr,$ctr-$leg1,.1,1], # x-axis
 
	cq => [$ctr,$ctr+$leg1,.1,1], # x-axis
	cr => [$ctr,$ctr+$leg2-$leg1*.15,.1,1], # x-axis
	cs => [$ctr,$ctr+$leg3,.1,1], # x-axis
	
	ct => [$ctr-$leg3+$leg1*.167,$ctr+$leg1-$leg1*.017,.1,1], # arc dots, W
	cu => [$ctr-$leg3+$leg1*.167,$ctr-$leg1+$leg1*.017,.1,1], # arc dots, W
	cv => [$ctr+$leg3-$leg1*.167,$ctr+$leg1-$leg1*.017,.1,1], # arc dots, E
	cw => [$ctr+$leg3-$leg1*.167,$ctr-$leg1+$leg1*.017,.1,1], # arc dots, E 
 
	cx => [$ctr-$leg1+$leg1*.017,$ctr-$leg3+$leg1*.167,.1,1], # arc dots, N
	cy => [$ctr+$leg1-$leg1*.017,$ctr-$leg3+$leg1*.167,.1,1], # arc dots, N
	cz => [$ctr-$leg1+$leg1*.017,$ctr+$leg3-$leg1*.167,.1,1], # arc dots, S
	c0 => [$ctr+$leg1-$leg1*.017,$ctr+$leg3-$leg1*.167,.1,1], # arc dots, S
 
);
 
# Lines are xy start and xy stop coordinates, in inches
my %lines = (
	# x  y   x   y
	lb => [$ctr,$ctr-$leg3,$ctr,$ctr+$leg3],	# N to S
	lc => [$ctr-$leg3,$ctr,$ctr+$leg3,$ctr],	# E to W
);
 
# Squares are xy start then l,w in inches
my %squares = (
	sa => [0,0,11,11,0],		# border/edge of board
);
 
# so we need some custom paths, not sure how to do arcs with this module
my %arcs = (
	# x,y (start), x,y (stop)
	aa => [$circles{'ct'}[0],$circles{'ct'}[1],$circles{'cu'}[0],$circles{'cu'}[1],0,0], # West Arc
	ab => [$circles{'cx'}[0],$circles{'cx'}[1],$circles{'cy'}[0],$circles{'cy'}[1],0,0], # North Arc
	ac => [$circles{'cv'}[0],$circles{'cv'}[1],$circles{'cw'}[0],$circles{'cw'}[1],0,1], # East Arc
	ad => [$circles{'cz'}[0],$circles{'cz'}[1],$circles{'c0'}[0],$circles{'c0'}[1],0,1], # South Arc
 
);
 
#----------------------------------------------
# Logic, no reason for sort but to help me see data when debugging
#----------------------------------------------
 
foreach my $arc (sort keys %arcs) {
	arcs($arc, $arcs{$arc}[0],$arcs{$arc}[1],$arcs{$arc}[2],$arcs{$arc}[3],$arcs{$arc}[4],$arcs{$arc}[5]);
}
 
# make our circles/dots
foreach my $circle (sort keys %circles) {
	circles($circles{$circle}[0],$circles{$circle}[1],$circles{$circle}[2],$circles{$circle}[3]);
}
 
# add some lines
foreach my $cor (sort keys %lines) {
	lines($lines{$cor}[0],$lines{$cor}[1],$lines{$cor}[2],$lines{$cor}[3]);
}
 
# make our squares
foreach my $square (sort keys %squares) {
	squares($squares{$square}[0],$squares{$square}[1],$squares{$square}[2],$squares{$square}[3],$squares{$square}[4]);
}
 
# for SVG< keep - but will probably delete for boards
title($title);
 
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
# customs - accepts custom data paths
#----------------------------------------------
sub arcs {
	# M = Absolute move to X,Y
	# A = Absolute Arc Radius X and Y
	# Rotation
	# Large ARC Flag
	# Sweep Flag
	# End X,Y of Arc
	# seems to be ignoring the A rx, ry 
    my ($id,$sx,$sy,$ex,$ey,$a1,$a2) = @_;
    $sx = $sx * SCALE;
    $sy = $sy * SCALE;
    $ex = $ex * SCALE;
    $ey = $ey * SCALE;
    my $sz = ($leg1-$leg1 * .167) * SCALE;
    my $string = "M $sx,$sy A $sz,$sz 90 $a1 $a2 $ex,$ey";
    my $tag = $svg->path(
        d => $string,
        id    => 'arc_'.$id,
	    style => {
        	'fill'           => FILL,
        	'stroke'         => STROKE,
        	'stroke-width'   =>  3,
        	'stroke-opacity' =>  1,
        	'fill-opacity'   =>  0,
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
	        'fill-opacity'   => $fop,	# must be 0, for lines, or 1 for solid squares
	    }
	);
}
 
 
 
# now render the SVG object, implicitly use svg namespace
print $svg->xmlify;