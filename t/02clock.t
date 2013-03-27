#! /usr/bin/perl 

use warnings;
use strict;

use SEG7;

my $seg7 = SEG7->new( x => 5, y => 5);

while (1) {
	chomp(my $time = qx/date '+%T'/);

	$seg7->x_curr(5);
	$seg7->y_curr(5);

	$seg7->disp_str($time);

	sleep 1;
}
