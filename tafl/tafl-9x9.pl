#!/usr/bin/perl
 
# Makes 9x9 tafl board
#http://tafl.cyningstan.com/taflmatch/1669/a-demonstration-of-ard-ri

use strict;
use warnings;
use SVG;  		# https://metacpan.org/pod/SVG
use Getopt::Std;        # for CLI options
 
# A4 Paper, .5 margins, Scale of 67 seems to fit
use constant SCALE 	=> '67';	# dots per inch scale, adjust to fit on your board
use constant LINEWIDTH => '3'; # globally set LW
use constant FILL 	=> 'black';	# can be 'rgb(0,0,0)'  too
use constant STROKE	=> 'black';	# can be 'rgb(0,0,0)'  too
 
# create an SVG object, canvas which we use for the rest of the draws
# using 9 width and .5 starting dot, means use 8.5 ending dots
# that way it's centered, printable
my $svg = SVG->new(
    width  => 9 * SCALE,
    height => 10 * SCALE,
);
 
my ($outfile, $squares, $checked, %options);
 
#-----------------------------------------------------------
# USAGE: Educates user on how to run program, then lists files
#-----------------------------------------------------------
sub usage {
    my $msg = shift;
    print "$msg" . "\n\n";
    print "Usage: $0" . ' -o <somefile.svg>  -h <0|1>' . "\n\n";
    print "-o some output file name\n";
    print "-h help yes or no\n";
    exit;
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
	        'fill-opacity'   => $fop,	# must be 0, for lines, or 1 for solid squares
	    }
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
	my $lw = shift;
 
	my $path = $svg->get_path(
    	x => [$xstart,$xstop],
    	y => [$ystart,$ystop],
    	-type => 'polygon');
 
	$svg->polygon(
	    %$path,
	    style => {
	        'fill'           => FILL,
	        'stroke'         => STROKE,
	        'stroke-width'   => $lw,
	        'stroke-opacity' => 1,
	        'fill-opacity'   => 1,
	    },
	);
}
#----------------------------------------------
# Input and Verify
#----------------------------------------------
# Make sure at least one argument provided
if ( !@ARGV ) { usage(); }
 
# What are the options they entered
getopt("oh", \%options);

$squares = 9; 
 
# Basic Out Put File Checks?
if (defined $options{o}) { 
    $outfile = $options{o}; 
    if (-e $outfile) { usage("Not allowing you to clobber a file, try again") }
} else { usage("FILE EXISTS"); }
 
#----------------------------------------------
# Logic
#----------------------------------------------
# figure out how to fit their want, into our sizes
# we want to fit entire board in 8 inch square
my $step = 8/$squares;  # how big should each square be?
my $end = 8/$step;		# should just be the same as squares
 
my @coors;		# holds the steps of cooridinates for each square
my $start = .5;		# we start at .5 as a margin
 
# loop over to get our xy start list from 1 to number of squares
# as step changes based on squares, advance by "step" units
# @coors stores the basic unit, 2,4,6,8 or 1,2,3,4 etc based
# on size of step.  Notice the offset for margins ($start)
# we need this array for later loops, $click isn't even used
foreach my $click (1..$squares) {
	push (@coors,$start);
	$start = $start + $step;
}
 
# make our squares
#my $counter = 2;		# start the counter that tracks checkers
my $odd = $squares % 2;		# is this an even or odd number of squares

# track which square we are on, so we know where to put our X
# 7 is 1,7,25,43,49
# 9 is 1,9,41,73,81
my $counter = 0;
 
	foreach my $x (@coors) {
		foreach my $y (@coors) {

			# which square are we on?
			$counter++;

			# this is the x lines for that square
			my $x2 = $x + 1 * $step;
			my $y2 = $y + 1 * $step;
			squares($x,$y,$step,$step,0,3);
			if ($counter == 1) { 
				lines($x,$y,$x2,$y2,LINEWIDTH); 
				lines($x2,$y,$x,$y2,LINEWIDTH);
			}
			if ($counter == 9) { 
				lines($x,$y,$x2,$y2,LINEWIDTH); 
				lines($x2,$y,$x,$y2,LINEWIDTH);
			}
			if ($counter == 41) { 
				lines($x,$y,$x2,$y2,LINEWIDTH); 
				lines($x2,$y,$x,$y2,LINEWIDTH);
			}
			if ($counter == 73) { 
				lines($x,$y,$x2,$y2,LINEWIDTH); 
				lines($x2,$y,$x,$y2,LINEWIDTH);
			}
			if ($counter == 81) { 
				lines($x,$y,$x2,$y2,LINEWIDTH); 
				lines($x2,$y,$x,$y2,LINEWIDTH);
			}

		}
	}

# draw box around it all
#squares(.5,.5,8,8,0,LINEWIDTH);
		
# Try to center the title
my $title = "Ard-Ri/Hnefatafl (Viking Chess)";
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
 
# all done, do et
# now render the SVG object, implicitly use svg namespace
open my $fh, ">:encoding(utf8)", $outfile or die "$!\n";
    print $fh $svg->xmlify;
close $fh;