#!/usr/bin/perl
use List::Util qw(any);
use LWP::Online qw(:skip_all);
use Test::More;
use strict;

my $base = q{Net::RDAP};

require_ok $base;

my $class = $base.'::Service';

require_ok $class;

my $server = $class->new('https://rdap.example.com/');

isa_ok($server, $class);

#
# TODO: add more tests
#

done_testing;
