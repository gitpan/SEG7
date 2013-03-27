#! /usr/bin/perl 

use warnings;
use strict;

use SEG7;

my $seg7 = SEG7->new( x_init => 10, y_init => 10);

$seg7->fancy_segments(1);
$seg7->disp_str(':0123456789  abKdef  ABCDEF' x 60);
#print "X = ", $seg7->x_curr, "\n";
#print "Y = ", $seg7->y_curr, "\n";

$seg7->fancy_segments(0);
$seg7->disp_str(':0123456789 abcdef ABCDEF');

