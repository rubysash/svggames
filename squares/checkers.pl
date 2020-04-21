#!/usr/bin/perl
 
# Makes checkered or squares to fit on 1 page A4
use strict;
use warnings;
use SVG;  		# https://metacpan.org/pod/SVG
use Getopt::Std;        # for CLI options
 
# A4 Paper, .5 margins, Scale of 67 seems to fit
use constant SCALE 	=> '67';	# dots per inch scale, adjust to fit on your board
use constant LINEWIDTH	=> '0'; 	# 
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
    print "Usage: $0" . ' -o <somefile.svg> -c <1|0> -s <int> -h <0|1>' . "\n\n";
    print "-o some output file name\n";
    print "-c checkered 1 or 0.  1 = checkered, 0 = no checkers\n";
    print "-s how many squares do you want?\n";
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
#----------------------------------------------
# Input and Verify
#----------------------------------------------
# Make sure at least one argument provided
if ( !@ARGV ) { usage(); }
 
# What are the options they entered
getopt("ocs", \%options);
 
# Do you want checker board or just squares?
if (defined $options{c}) { 
    $checked = $options{c}; 
    if ($checked < 0) { usage("Use a 1 or a 0 for checkered or not") }
} else { usage("UNKNOWN CHECKERED"); }
 
# How many squares?
if (defined $options{s}) { 
    $squares = $options{s}; 
    unless ($squares > 0) { usage("Use a 1 or a 0 for checkered or not") }
} else { usage("UNKNOWN SQUARES"); }
 
# Basic Out Put File Checks?
if (defined $options{o}) { 
    $outfile = $options{o}; 
    if (-e $outfile) { usage("Not allowing you to clobber a file, try again") }
} else { usage("FILE EXISTS"); }
 
#----------------------------------------------
# Logic
#----------------------------------------------
# figure out how to fit their want, into our sizes
my $step = 8/$squares;  # how big should each square be?
my $end = 8/$step;	# should just be the same as squares
 
my @coors;		# holds the steps of cooridinates for each square
my $start = .5;		# we start at .5 as a margin
 
# loop over to get our xy start list from 1 to number of squares
foreach my $click (1..$squares) {
	push (@coors,$start);
	$start = $start + $step;
}
 
# make our checkers
my $counter = 2;		# start the counter that tracks checkers
my $odd = $squares % 2;		# is this an even or odd number of squares
 
if ($odd) {
	foreach my $x (@coors) {
		foreach my $y (@coors) {
			if ($counter % 2) { 
				squares($x,$y,$step,$step,0,3);
			} else { 
				squares($x,$y,$step,$step,$checked,3);
			}
			$counter++;
		}
		#$counter++; not needed for odd # of squares
	}
} else {
	foreach my $x (@coors) {
		foreach my $y (@coors) {
			if ($counter % 2) { 
				squares($x,$y,$step,$step,0,3);
			} else { 
				squares($x,$y,$step,$step,$checked,3);
			}
			$counter++;
		}
		$counter++;
	}
}
# draw box around it all
squares(.5,.5,8,8,0,3);
		
# Try to center the title
my $title = "Square Game Board $squares x $squares";
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