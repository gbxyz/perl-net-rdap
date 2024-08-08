#!/usr/bin/perl
use List::Util qw(any);
use Test::More;
use URI;
use JSON;
use strict;

my $base = q{Net::RDAP};

require_ok $base;

my $class = $base.'::Service';

my $server = $class->new('https://rdap.verisign.com/net/v1');

isa_ok($server, $class);

my $result = $server->nameservers(
    ip => '198.41.0.4' # a.gtld-servers.net
);

isa_ok($result, $base.'::SearchResult');

my @objects = $result->nameservers;
cmp_ok(scalar(@objects), '>=', 0);

foreach my $object (@objects) {
    isa_ok($object, $base.'::Object::Nameserver');
}

done_testing;
