#!/usr/bin/perl


use warnings;
use strict;
use Text::Template::Queue;

print  "1..2\n";
my $obj = new Text::Template::Queue();
if($obj)	{
	print "ok 1\n";
}
else	{
	print "not ok 1\n";
}


if($obj && defined $obj->queue({TYPE=>"FILE",SOURCE=>"t/helloworld.html"},
	{HASH=>{world=>"333"}}))	{
	print "ok 2\n";
}
else	{
	print "not ok 2\n";
}
