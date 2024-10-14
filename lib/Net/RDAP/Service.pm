package Net::RDAP::Service;
use Storable qw(dclone);
use Net::RDAP;
use strict;
use warnings;

sub new {
    my ($package, $base, $client) = @_;
    return bless({
        'base'      => $base->isa('URI') ? $base : URI->new($base),
        'client'    => $client || Net::RDAP->new,
    }, $package);
}

sub fetch {
    my ($self, $type, $segments, %params) = @_;

    my $uri = dclone($self->base);

    $uri->path_segments(grep { defined && length > 0 } (
        $uri->path_segments,
        $type,
        'ARRAY' eq ref($segments) ? @{$segments} : $segments
    ));

    $uri->query_form(%params);

    my %opt;
    $opt{'class_override'} = 'help' if ('help' eq $type);

    return $self->client->fetch($uri, %opt);
}

sub search {
    my ($self, $type, %params) = @_;

    if (exists($params{entity}) && 'HASH' eq ref($params{entity})) {
        return $self->reverse_search($type, %{$params{entity}});

    } elsif ('ips' eq $type && ($params{up} || $params{down} || $params{top} || $params{bottom})) {
        return $self->rir_reverse_search($type, %params);

    } else {
        return $self->fetch($type, undef, %params);

    }
}

sub rir_reverse_search {
    my ($self, $type, %params) = @_;

    my @rels = qw(up down top bottom);

    foreach my $rel (@rels) {
        if (exists($params{$rel})) {
            # remove this and any other relation
            map { delete($params{$_}) if (exists($params{$_})) } @rels;

            return $self->fetch('ips', ['rirSearch1', $rel], %params);
        }
    }

    return undef;
}

sub reverse_search {
    my ($self, $type, %params) = @_;

    return $self->fetch($type, [qw(reverse_search entity)], %params);
}

sub base        { $_[0]->{'base'}   }
sub client      { $_[0]->{'client'} }

sub help        { $_[0]->fetch('help'                               ) }
sub domain      { $_[0]->fetch('domain',        $_[1]->name         ) }
sub ip          { $_[0]->fetch('ip',            $_[1]->prefix       ) }
sub autnum      { $_[0]->fetch('autnum',        $_[1]->toasplain    ) }
sub entity      { $_[0]->fetch('entity',        $_[1]->handle       ) }
sub nameserver  { $_[0]->fetch('nameserver',    $_[1]->name         ) }

sub domains     { shift->search('domains',      @_ ) }
sub nameservers { shift->search('nameservers',  @_ ) }
sub entities    { shift->search('entities',     @_ ) }
sub ips         { shift->search('ips',          @_ ) }
sub autnums     { shift->search('autnums',      @_ ) }

1;

__END__

=pod

=head1 NAME

L<Net::RDAP::Service> - a module which provides an interface to an RDAP server.

=head1 SYNOPSIS

    use Net::RDAP::Service;

    #
    # create a new service object:
    #

    my $svc = Net::RDAP::Service->new('https://www.example.com/rdap');

    #
    # get a domain:
    #

    my $domain = $svc->domain(Net::DNS::Domain->new('example.com'));

    #
    # do a search:
    #

    my $result = $svc->domains('name' => 'ex*mple.com');

    #
    # get help:
    #

    my $help = $svc->help;

=head1 DESCRIPTION

While L<Net::RDAP> provides a unified interface to the universe of
RIR, domain registry, and domain registrar RDAP services,
L<Net::RDAP::Service> provides an interface to a specific RDAP service.

You can do direct lookup of objects using methods of the same name that
L<Net::RDAP> provides. In addition, this module allows you to perform
searches.

=head1 METHODS

=head2 Constructor

    my $svc = Net::RDAP::Service->new($url);

Creates a new L<Net::RDAP::Service> object. C<$url> is a string or a
L<URI> object representing the base URL of the service.

You can also provide a second argument which should be an existing
L<Net::RDAP> instance. This is used when fetching resources from the
server.

=head2 Lookup Methods

You can do direct lookups of objects using the following methods:

=over

=item * C<domain()>

=item * C<ip()>

=item * C<autnum()>

=item * C<entity()>

=item * C<nameserver()>

=back

They all work the same way as the methods of the same name on
L<Net::RDAP>.

=head2 Search Methods

You can perform searches using the following methods. Note that
different services will support different search functions.

    $result = $svc->domains(%QUERY);

    $result = $svc->entities(%QUERY);

    $result = $svc->nameservers(%QUERY);

    $result = $svc->ips(%QUERY);

    $result = $svc->autnums(%QUERY);

In all cases, C<%QUERY> is a set of search parameters. Here are some
examples:

    $result = $svc->domains(name => 'ex*mple.com');

    $result = $svc->entities(fn => 'Ex*ample, Inc');

    $result = $svc->nameservers(ip => '192.0.2.1');

    $result = $svc->ips(handle => 'FOOBAR-RIR');

    $result = $svc->autnums(handle => 'FOOBAR-RIR');

References:

=over

=item * Domain search: L<Section 3.2.1 of RFC 9083|https://www.rfc-editor.org/rfc/rfc9082.html#section-3.2.1>

=item * Nameserver search: L<Section 3.2.2 of RFC 9083|https://www.rfc-editor.org/rfc/rfc9082.html#section-3.2.2>

=item * Entity search: L<Section 3.2.3 of RFC 9083|https://www.rfc-editor.org/rfc/rfc9082.html#section-3.2.3>

=item * IP search: L<Section 2.2 of draft-ietf-regext-rdap-rir-search-09|https://www.ietf.org/archive/id/draft-ietf-regext-rdap-rir-search-09.html#section-2.2>

=item * AS number search: L<Section 2.3 of draft-ietf-regext-rdap-rir-search-09|https://www.ietf.org/archive/id/draft-ietf-regext-rdap-rir-search-09.html#section-2.3>

=back

Note that not all RDAP servers support all search types or parameters.

The following parameters can be specified:

=over

=item * domains: C<name> (domain name), C<nsLdhName> (nameserver
name), C<nsIp> (nameserver IP address)

=item * nameservers: C<name> (host name), C<ip> (IP address)

=item * entities: C<handle>, C<fn> (Formatted Name)

=item * ips: C<handle>, C<name>

=item * autnums: C<handle>, C<name>

=back

Search parameters can contain the wildcard character "*" anywhere
in the string.

These methods all return L<Net::RDAP::SearchResult> objects.

=head2 Reverse Search

Some RDAP servers implement "reverse search" which is specified in L<RFC
9536|https://www.rfc-editor.org/rfc/rfc9536.html>. This allows you to search for
objects based on their relationship to some other object: for example, to search
for domains that have a relationship to a specific entity.

To perform a reverse search (on a server that supports this), pass a set of
query parameters using the C<entity> parameter:

    $result = $svc->domains(entity => { handle => 9999 });

=head2 Advanced IP Address Search

=head2 Help

Each RDAP server has a "help" endpoint which provides "helpful
information" (command syntax, terms of service, privacy policy,
rate-limiting policy, supported authentication methods, supported
extensions, technical support contact, etc.). This information may be
obtained by performing a C<help> query:

    my $help = $svc->help;

The return value is a L<Net::RDAP::Help> object.

=head1 COPYRIGHT

Copyright 2018-2023 CentralNic Ltd, 2024 Gavin Brown. For licensing information,
please see the C<LICENSE> file in the L<Net::RDAP> distribution.

=cut

1;
