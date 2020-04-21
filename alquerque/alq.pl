#!/usr/bin/perl
 
# Makes alquerque boards to fit on 1 page A4
use strict;
use warnings;
use SVG;  		# https://metacpan.org/pod/SVG
use Getopt::Std;        # for CLI options
 
# A4 Paper, .5 margins, Scale of 67 seems to fit
use constant SCALE 	=> '66';	# dots per inch scale, sorta
use constant DOTSIZE	=> '7';		# should be an odd number so line can center
use constant LINEWIDTH	=> '3'; 	# 
use constant FILL 	=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE	=> 'black';	# can be 'rgb(0,0,0)'  too
 
# create an SVG object, canvas which we use for the rest of the draws
# using 9 width and .5 starting dot, means use 8.5 ending dots
# that way it's centered, printable.   However, it's not exactly 8.5in
# the SCALE adjusts the exact sizes.
my $svg = SVG->new(
    width  => 11 * SCALE,
    height => 11 * SCALE,
);
 
# globals
my ($outfile, $squares, %options);
my @coors;		# holds the steps of cooridinates for each square
my $offset = 1.5;	# start at 1.5 away from sides
my $start = $offset;	# we start at 1.5 as a margin
my @start0;		# we need to start at 0 for 1 array
my @start2;		# and we need to start at 0 + 2 steps for the other array
 
#----------------------------------------------
# Input and Verify
#----------------------------------------------
# Make sure at least one argument provided
if ( !@ARGV ) { usage("$0 requires arguments,\n"); }
 
# What are the options they entered
# allowing only "o" or "s"
getopt("os", \%options);
 
# How many squares?
if (defined $options{s}) { 
    $squares = $options{s}; 
    unless ($squares > 0) { usage("That board is too small.  Size matters.") }
    if ($squares % 2) { usage("Alquerque boards should be an even number of squares.")}
} else { usage("UNKNOWN SQUARES"); }
 
# Basic Out Put File Checks?
if (defined $options{o}) { 
    $outfile = $options{o}; 
} else { usage("MUST PROVIDE FILENAME"); }
 
if (keys %options > 2) {
	usage("You have too many options as input")
}
#----------------------------------------------
# Initial calcs
#----------------------------------------------
# figure out how to fit their want, into our sizes
# we want to fit entire board in 8 inch square
my $step = 8/$squares;  # how big should each square be?
my $end = 8/$step;		# should just be the same as squares
 
# Lines are xy start and xy stop coordinates, in inches
my $steps = $squares / 2; 
my $stepsq = $offset;
 
# loop over to get our xy start list from 1 to number of squares
# as step changes based on squares, advance by "step" units
# @coors stores the basic unit, 2,4,6,8 or 1,2,3,4 etc based
# on size of step.  Notice the offset for margins ($start)
# we need this array for later loops, $click isn't even used
foreach my $click (1..$squares) {
	push (@coors,$start);
	$start = $start + $step;
}
 
 
#-------------------------------------------
# define data
#-------------------------------------------
my %dots;
my $dotcounter = 100;
 
# Squares are xy start then l,w in inches
my %squares = (
	sa => [0,0,11,11,0,3],		# border/edge of board
);
 
# make our squares based on how many loops we know we needed.
# would it be easier to use a x..y format here based on squares?
# save 3 lines of code... or did I need to bump the offset 
# so I have a loop that matches the printable board?
# squares + dots in same loop
foreach my $x (@coors) {
	foreach my $y (@coors) {
		squares($x,$y,$step,$step,0,3);
		$dots{$dotcounter}=[$x,$y]; $dotcounter++; # gets everything except outer edge.
	}
}
 
# Now the Dots
# dots on final y column
foreach my $y (@coors) {$dots{$dotcounter}=[$start,$y]; $dotcounter++;}
# dots on final x row
foreach my $x (@coors) {$dots{$dotcounter}=[$x,$start]; $dotcounter++;}
# final dot in SE corner
$dots{$dotcounter}=[$start,$start]; $dotcounter++;
 
# Finally the Lines
for (1..$steps) {
	push @start0, $stepsq;
	$stepsq = $stepsq + 2 * $step;
}
# What is a better way to write this?
$stepsq = 2 * $step + $offset;
for (1..$steps) {
	push @start2, $stepsq;
	$stepsq = $stepsq + 2 * $step;
}
# My x and y arrays are built for / lines
# loop over each and draw the lines
# double duty and populate %dots too please
foreach my $y1 (@start0) {
	foreach my $x1 (@start0) {
		my $x2 = $x1 + 2 * $step;
		my $y2 = $y1 + 2 * $step;
		lines($x1,$y1,$x2,$y2);
	} 
}
# now loop over the \ lines 
foreach my $y1 (@start0) {
	foreach my $x1 (@start2) {
		my $x2 = $x1 - 2 * $step;
		my $y2 = $y1 + 2 * $step;
		lines($x1,$y1,$x2,$y2);
	} 
}
 
#----------------------------------------------
# Logic
#----------------------------------------------
foreach my $square (sort keys %squares) {
	squares($squares{$square}[0],$squares{$square}[1],$squares{$square}[2],$squares{$square}[3],$squares{$square}[4],$squares{$square}[5]);
}
 
# add the dots... we could of done this loop in the first place..
foreach my $cor (sort keys %dots) {
	dots($dots{$cor}[0],$dots{$cor}[1]);
}
 
# lines were done as built
#-----------------------------------------------------------
# usage: Educates user on how to run program
#-----------------------------------------------------------
sub usage {
    my $msg = shift;
    print "\n\n$msg\n\n";
    print "Usage: $0" . ' -o <somefile.svg> -s <int>' . "\n\n";
    print "-o some output file name\n";
    print "-s how many squares do you want (an even number)?\n";
    exit;
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
 
#-----------------------------------------------------------
# lines: really a 2 point polygon that looks like a line
#-----------------------------------------------------------
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
 
#-----------------------------------------------------------
# squares: draws a square starting at xy and expanding w,h
# really a rectangle function
#-----------------------------------------------------------
sub squares {
	# accepts 6 values:
	#  x y coord, w h specs, fill opacity and line weight
	my $x = shift;
	my $y = shift;
	my $w = shift;
	my $h = shift;
	my $fop = shift;
	my $lw = shift;
 
	$svg->rectangle(
	    x => $x * SCALE,
	    y => $y * SCALE,
	    width  => $w * SCALE,
	    height => $h * SCALE,
	    style => {
	        'fill'           => FILL,
	        'stroke'         => STROKE,
	        'stroke-width'   => $lw,
	        'stroke-opacity' => 1,
	        'fill-opacity'   => $fop,	
	        # $fop must be 0 or 1
	        # 1 makes a solid square, 0 makes an outline square
	    }
	);
}
		
# Try to center the title, it's approximate related to SCALE
my $title = "Alquerque $squares x $squares";
 
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
 
# all done, do et
# now render the SVG object, implicitly use svg namespace
# this clobbers any existing file and allows user to overwrite
open my $fh, ">:encoding(utf8)", $outfile or die "$!\n";
    print $fh $svg->xmlify;
close $fh;