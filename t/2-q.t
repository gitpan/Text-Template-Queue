#!/usr/bin/perl


use warnings;
use strict;
use Text::Template::Queue;

print  "1..1\n";
my $obj = new Text::Template::Queue();
if(defined $obj->q("t/helloworld.html",{world => "Cambodia"}))	{
	print "ok 1\n";
}
else	{
	print "not ok 1\n";
}
