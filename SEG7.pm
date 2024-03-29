#! /usr/bin/perl 

use warnings;
use strict;
#use Autoloader; ### uncomment for windoze?
use Carp qw/carp/;
use Curses;

package SEG7;

our @ISA = qw( Curses );

{
	#   
	#  0_     
	# 1|_|3 element #2 in $segments{x} aref is the middle horiz. segment
	# 4|_|6  
	#   5
	# the . is used in place of space for simplicity
	# it is replaced by space just before displaying
	my %segments = (
		0 => [qw(    _    
			   | . | 
			   | _ |
		      )],
		1 => [qw(    . 
			   . . | 
			   . . | 
		      )],
		2 => [qw(    _ 
			   . _ | 
			   | _ . 
		      )],
		3 => [qw(    _ 
			   . _ | 
			   . _ | 
		      )],
		4 => [qw(    . 
			   | _ | 
			   . . | 
		      )],
		5 => [qw(    _ 
			   | _ . 
			   . _ | 
		      )],
		6 => [qw(    _ 
			   | _ . 
			   | _ | 
		      )],
		7 => [qw(    _ 
			   . . | 
			   . . | 
		      )],
		8 => [qw(    _ 
			   | _ | 
			   | _ | 
		      )],
		9 => [qw(    _ 
			   | _ | 
			   . . | 
		      )],
	      ':' => [qw(    . 
			   . o . 
			   . o . 
		      )],
	      ' ' => [qw(    . 
			   . . . 
			   . . . 
		      )],
		A => [qw(    _ 
			   | _ | 
			   | . | 
		      )],
		a => [qw(    _ 
			   . _ | 
			   | _ | 
		      )],
		B => [qw(    _ 
			   | _ \) 
			   | _ \) 
		      )],
		b => [qw(    . 
			   | _ . 
			   | _ | 
		      )],
		C => [qw(    _ 
			   | . . 
			   | _ . 
		      )],
		c => [qw(    . 
			   . _ . 
			   | _ . 
		      )],
		D => [qw(    _ 
			   | . \ 
			   | _ / 
		      )],
		d => [qw(    . 
			   . _ | 
			   | _ | 
		      )],
		E => [qw(    _ 
			   | _ . 
			   | _ . 
		      )],
		e => [qw(    _ 
			   | _ | 
			   | _ . 
		      )],
		F => [qw(    _ 
			   | _ . 
			   | . . 
		      )],
		f => [qw(    o 
			   | _ . 
			   | . . 
		      )],
	);
	my %defaults = (
		segments => \%segments,
		string => '0123456789abcdef',
		x_init => 0,
		y_init => 0,
		x_curr => 0,
		y_curr => 0,
		fancy_segments => 0, # 1 - allow chars other than _, |, o
	);

	# to make really private;
	#my %private = ( x_curr => 1, y_curr => 1,);
	#my $self;

	sub new {
		my $class = shift;
		my (%params) = @_;
		my $self = {};
		#$self->segments = \%segments;
		foreach my $param (keys %defaults) {
			$self->{$param} = $params{$param} ? $params{$param} : $defaults{$param};
		}
		$self->{cursor} = Curses->new;
		#$self->{cursor}->curr_set(0);   # hide cursor
		$self->{cursor}->refresh;

		($self->{x_curr}, $self->{y_curr}) = ($self->{x_init}, $self->{y_init});

		return bless($self, $class);
	}
}

sub lookup {
	my $self = shift;
	my ($chr) = shift;

	if (! $self->fancy_segments) {
		$chr = lc $chr if ($chr =~ /[BD]/);
		$chr = uc $chr if ($chr =~ /[acef]/);
	}

	if ($self->segments->{$chr}) {
		return $self->segments->{$chr};
	} else {
		warn "Warning: Code not defined for $chr\n";
		return [];
	}
}

# every 7 segments character takes the space of 3 letters and 3 lines
sub disp_str {
	my $self = shift;
	my ($str) = @_;
	$str = ($str) ? $str : $self->{string};
	my @str = split(//, $str);

	my($x, $y) = ($self->x_curr, $self->y_curr);
	foreach my $chr (@str) {

		# if not enough space on line to write next char
		# move over to start of next line
		if ($self->x_curr > ($self->cursor->getmaxx - 3)) {
			$self->x_curr($self->x_init);
			$self->y_curr($self->y_curr + 3);
		}
		$self->x_curr($self->x_curr + 3) if( $self->disp_char($chr));
	}
}

sub disp_char {
	my $self = shift;
	my ($chr, $x, $y) = @_;
	$x = $self->x_curr if not($x);
	$y = $self->y_curr if not($y);

	my $c = $self->cursor;

	# lookup the 7 seg code for chr
	my @segs = @{$self->lookup($chr)};
	return 0 if ($#segs == -1);   # nothing retured by lookup

	# replace dots by space
	@segs = map {$_ =~ s/\./ /; $_} @segs;

	$c->addch($y,   $x+1, $segs[0]); 
	$c->addch($y+1, $x,   $segs[1]);
	$c->addch($y+1, $x+1, $segs[2]);
	$c->addch($y+1, $x+2, $segs[3]);
	$c->addch($y+2, $x,   $segs[4]);
	$c->addch($y+2, $x+1, $segs[5]);
	$c->addch($y+2, $x+2, $segs[6]);
	$c->refresh;
	return 1;
}

sub AUTOLOAD {
	my ($self) = shift;

	my $sub = $SEG7::AUTOLOAD;
	(my $prop = $sub) =~ s/.*:://;

	my $val = shift;
	if(defined $val and $val ne '') {
		$self->{$prop} = $val;
	}
	return $self->{$prop};
}

1;

=head1 NAME

                             _
SEG7 - Display characters in  | segment led style.
                              |

=head1 VERSION

This documentation refers to SEG7 version 1.0.1. This is beta version, interface is likely to change slightly.

=head1 SYNOPSIS

	use SEG7;

	my $seg7 = SEG7->new();
	$seg7->disp_str(':0123456789 abcdef ABCDEJ');

	# all hex digits available in both upper and lower case
	$seg7->fancy_segments(1); 
	$seg7->disp_str(':0123456789 abcdef ABCDEF');

	# start display at 5th row from top and 
	# 10th character from left 
	my $seg7 = SEG7->new( x_init => 10, y_init => 5);

	# 7-segment led clock
	my $seg7 = SEG7->new( );
	while (1) {
		chomp(my $time = qx/date '+%T'/);

		$seg7->x_curr(0);
		$seg7->y_curr(0);

		$seg7->disp_str($time);

		sleep 1;
	}

=head1 DESCRIPTION

This module will display strings in 7 segment style. This is the common display style used in lcd calculators, digital watches etc. 

The module takes only the hex digits([0-9A-Fa-f]), colon (:) and space characters (at present).

The intended application of this module is to emulate a seven segment clock or calculator display just for fun.

If you are still in the dark or need more info please refer to http://en.wikipedia.org/wiki/Seven-segment_display for lots of details on this display technology. 

=head1 METHODS

A SEG7 object is an instance of a 7-segment display. The following methods can be called on the object:

=over 

=item new() # Any getter or setter method names (see next item) can be passed as hash keys with value to new
	my $s = SEG7->new(string => 'ffff', x_init => 5);


=item getter/setter methods 

The getter/setter methods if called with an argument will set the value in the object, without an argument they will return the current value. The following methods can be used to change the state of the SEG7 object:

=back

=over

=item *

string - string to be displayed

=item *

x_init - column number to start displaying from. This many left most characters in a line of display will be blank.

=item *

y_init - row number to start displaying from. This many top most lines of display will be blank.

=item *

fancy_segments - Normally the 7 segment display can show the letters b and d in lowercase only because they can not be distinguished from the digits 8 and 0 respectively. This is a limitation of the hardware/design. However, since we are just emulating the 7-segment display, we are able to cheat by using extra characters. By default the 7 segment display in this module uses only the following characters: underscore(_), pipe(|) to diplay hex digits*. When set to a true value, the slash(/) and parens(\))are also used so the display can support displaying the letters [a-f] in both upper and lower case.. 

When fancy_segments is not set, uppercase b and d in string will be silently displayed in lowercase.

=back

=head1 DIAGNOSTICS

If the string contains a character outside of [a..fA..F0..9: ], it will not be displayed and a warning will be given. It will be a good idea to redirect the error output to somewhere other than the terminal if this is likely.

Warning: Code not defined for $chr

=head1 CONFIGURATION AND ENVIRONMENT

Any output to the terminal can wreak havoc with the curses display. If the string to be displayed can have an unsupported character, it would be better to redirect STDOUT to a file or another place away from STDOUT.

e.g  perl seg7-disp.pl 2>/dev/null
     perl seg7-disp.pl 2>error.out

=head1 DEPENDENCIES

This module depends on Curses module for displaying the output. It could be done without curses in a text terminal but then the input will have to be line bufferred. i.e the module should get the whole line of string at a time because it couldn't go back to top row after moving to the 2nd or 3rd. 

=head1 BUGS AND LIMITATIONS

It seems to get stuck at end of screen. Need to handle y_curr when it reaches max value.

Sometimes the terminal needs to be reset after a script using the module terminates. The terminal is still usable but the prompt gets shifted to the right.

Just typing reset at the prompt and hitting enter seems to fix the issue for me. 

Please report problems to manigrew (Manish.Grewal@gmail.com).
Patches are welcome.

=head1 AUTHOR

manigrew (Manish.Grewal@gmail.com)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013 manigre (Manish.Grewal@gmail.com). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
