#! /usr/bin/perl 

use warnings;
use strict;

use SEG7;

my $seg7 = SEG7->new( x => 10, y => 10);

$seg7->fancy_segments(1);
$seg7->disp_str(':0123456789abcdefABCDEF');

$seg7->fancy_segments(0);
$seg7->y($seg7->y() + 5);
$seg7->disp_str(':0123456789abcdefABCDEF');

