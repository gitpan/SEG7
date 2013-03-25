#! /usr/bin/perl 

use warnings;
use strict;
#use Autoloader; ### uncomment for windoze?
use Data::Dumper;
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
		string => '0123456789abcdef',
		x      => 10,
		y      => 10,
		fancy_segments => 0, # 1 - allow chars other than _, |, o
		segments => \%segments,
	);

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
		print "Warning: Code not defined for $chr\n";
		return 0;
	}
}

# every 7 segments character takes the space of 3 letters and 3 lines
sub disp_str {
	my $self = shift;
	my ($str) = @_;
	$str = ($str) ? $str : $self->{string};
	my @str = split(//, $str);

	my($x, $y) = ($self->x, $self->y);
	foreach my $chr (@str) {
		$self->disp_char($chr, $x, $y);
		$x += 3;

		# if not enough space on line to write next char
		# move over to start of next line
		if ($x > $self->cursor->getmaxx - 3) {
			$x = $self->x;
			$y += 3;
		}
	}
}

sub disp_char {
	my $self = shift;
	my ($chr, $x, $y) = @_;
	$x = $self->x if not($x);
	$y = $self->y if not($y);

	my $c = $self->cursor;

	# lookup the 7 seg code for chr
	my @segs = @{$self->lookup($chr)};

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

=head3

Bugs

=back

Need to reset terminal sometimes after the program ends

=cut
