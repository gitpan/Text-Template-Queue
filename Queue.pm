#!/usr/bin/perl
package Text::Template::Queue;

use strict;
use warnings;
use Text::Template;
use Carp;

$Text::Template::Queue::VERSION = '0.3';

sub new	{
	my $class = shift;
		$class = ref($class) || $class;

	my $self = bless {}, $class;

	$self->clear();
	
	return $self;
}


sub queue	{
	my $self = shift;
	
	#allow user to pass a string for ease of use
	if(@_ == 1)	{
		$self->queueStr($_[0]);
		return 1;
	}

	my ($resource, $fill, $prepend) = @_;
	carp "Invalid arguments to queue()" unless ($resource && $fill);

	my $q = $$self{q};

	my $struct = {
		resource => $resource,
		fill => $fill
	};

	if($prepend)	{
		unshift @$q, $struct;
	}
	else	{
		push @$q, $struct;
	}

	return $#$q;
}

sub queueStr	{
	my ($self, $str, $prepend) = @_;
	my $q = $$self{q};

	if($prepend)	{
		unshift @$q, $str
	}
	else	{
		push @$q, $str;
	}

	return $#$q
}

sub q	{
	my ($self, $file, $vars, $prepend) = @_;
	confess "Invalid arguments to q()" if(!$file);
	$vars ||= {};

	return $self->queue(
		{TYPE=>'FILE', SOURCE => $file},
		{HASH => $vars},
		$prepend
	);
}

sub delete	{
	my ($self, $index) = @_;
	my $q = $$self{q};

	$$q[$index] = undef;

	return $#$q
}

sub clear	{
	my $self = shift;
	$$self{q} = [];
}

sub process	{
	my ($self, $print) = @_;
	my $q = $$self{q};
	my $result = '';

	foreach my $item (@$q)	{
		next unless defined $item;
		if(ref $item)	{
			my $obj = Text::Template->new(%{$$item{resource}});
			return undef unless $obj;
			my $output;
			return undef unless $output = $obj->fill_in(%{$$item{fill}});
			$result .= $output
		}
		else	{
			$result .= $item;
		}
	}

	if($print)	{
		print $result;
	}

	return \$result;
}


1;
__END__
=head1 NAME

Text::Template::Queue - Easy management for multiple Text::Template objects

=head1 VERSION

Version 0.3

=head1 SYNOPSIS

  use Text::Template::Queue;

  #create a new object
  my $ttq = Text::Template::Queue->new();

  #quickly append a file/hash to the queue
  $ttq->q("hello_world.html", {world => 'Cambodia'});
  $ttq->q("hello_world.html", {world => 'America'});
  my $antarctica = $ttq->q("hello_world.html", {world => 'Antarctica'});

  #Antartica is cold, let's remove it
  $ttq->delete($antarctica);

  #do more advanced things with Text::Template objects
  open my $fh, "testing.txt" or die $!;
  $ttq->queue({TYPE => 'FILEHANDLE', SOURCE => $fh },
  		{HASH => {a=>1, b=>2}});

  #Print everything out
  $ttq->process(1);

  #or store it in a variable for some other reason:
  my $result = $ttq->process();

=head1 DESCRIPTION

This module basically stores Text::Template method arguments in an array,
then passes them to the constructor and fill_in methods when requested.
Using Text::Template::Queue will allow a person to more easily control their
output, and even make mistakes.

=head1 METHODS

=head2 new()

No arguments required

=head2 queue($tt_construct, $tt_fill, $prepend)

$tt_construct is a hash reference which contains arguments to be passed
to the Text::Template::new() (see it for more documentation). $tt_fill
is a hash reference containing the arguments to be passed to
Text::Template::fill_in(). $prepend is an optional boolean which can be
used to set the item as the first item in the queue. NOTE: this will
mess with any previous numbers returned by this function. See the SYNOPSIS
for an example. This method also accepts a call like this:

	queue($string)

where $string is a scalar that you want added to the queue. This function
returns the index of the item in the queue and undef on failure. See 
Text::Template for error checking

=head2 queueStr($string, $prepend)

This will add $string to the end of the queue if $prepend is not provided.
Otherwise it will stick it in the front. See queue() for what $prepend does.
This returns the index of the item in the queue. Returns undef on failure,
see Text::Template for error checking. If you need to do more advanced
things with Text::Template objects, then create your own object and pass the
fill_in() result to this method.

=head2 q($file, $vars, $prepend)

This is a wrapper function to queue(). I use this most frequently -- here
is the call it makes:

	queue({TYPE=>'FILE',SOURCE=>$file},{HASH => $vars}, $prepend)

This returns the the result of queue()

=head2 delete($index)

The index number returned by q(), queue(), and queueStr() can be passed
to this function and it will be removed from the queue. NOTE: This will not
hurt queue item numeration, but prepending will. If this creates a problem, 
let me know and I'll fix it. If the queue is empty, this returns -1

=head2 clear()

Clears the queue unconditionally, resets numeration to 0

=head2 process($print)

This processes all items in the queue, and will print the result if $print is
passed. A scalar reference to the result is returned. If an error occurs,
this function returns undef. See Text::Template for error checking

=head1 AUTHOR

sili@cpan.org -- Feel free to email me with questions, suggestions, etc

=head1 SEE ALSO

perl(1), Text::Template(3)

=cut
