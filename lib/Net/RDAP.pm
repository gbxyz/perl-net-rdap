package Net::RDAP;
use Carp qw(croak);
use HTTP::Request::Common;
use JSON;
use Net::RDAP::Registry;
use vars qw($VERSION);
use strict;

$VERSION = 0.3;

=pod

=head1 NAME

L<Net::RDAP> - an interface to the Registration Data Access Protocol
(RDAP).

=head1 SYNOPSIS

	use Net::RDAP;

	my $rdap = Net::RDAP->new;

	# get domain info:
	$data = $rdap->domain(Net::DNS::Domain->new('example.com'));

	# get info about IP addresses/ranges:
	$data = $rdap->ip(Net::IP->new('192.168.0.1'));
	$data = $rdap->ip(Net::IP->new('2001:DB8::/32'));

	# get info about AS numbers:
	$data = $rdap->ip(Net::ASN->new(65536));

=head1 DESCRIPTION

L<Net::RDAP> provides an interface to the Registration Data Access
Protocol (RDAP). RDAP is a replacement for Whois.

L<Net::RDAP> does all the hard work of determining the correct
server to query (L<Net::RDAP::Registry> is an interface to the
IANA registries), querying the server (L<Net::RDAP::UA> is an
RDAP HTTP user agent), and parsing the response
(L<Net::RDAP::Response> provides access to the data returned
by the server).

=head1 METHODS

	$rdap = Net::RDAP->new;

Constructor method, returns a new object.

=cut

sub new { bless({}, shift) }

=pod

	$info = $rdap->domain($domain);

This method returns a L<Net::RDAP::Response> object containing
information about the domain name referenced by C<$domain>.
C<$domain> must be a L<Net::DNS::Domain> object.

If no RDAP service can be found, then C<undef> is returned.

=cut

sub domain {
	my ($self, $object, %args) = @_;
	croak('argument must be a Net::DNS::Domain') unless ('Net::DNS::Domain' eq ref($object));
	return $self->query('object' => $object, %args);
}

=pod

	$info = $rdap->ip($ip);

This method returns a L<Net::RDAP::Response> object containing
information about the resource referenced by C<$ip>.
C<$ip> must be a L<Net::IP> object and can represent any of the
following:

=over

=item * An IPv4 address (e.g. C<192.168.0.1>);

=item * An IPv4 CIDR range (e.g. C<192.168.0.1/16>);

=item * An IPv6 address (e.g. C<2001:DB8::42:1>);

=item * An IPv6 CIDR range (e.g. C<2001:DB8::/32>).

=back

If no RDAP service can be found, then C<undef> is returned.

=cut

sub ip {
	my ($self, $object, %args) = @_;
	croak('argument must be a Net::IP') unless ('Net::IP' eq ref($object));
	return $self->query('object' => $object, %args);
}

=pod

	$info = $rdap->autnum($autnum);

This method returns a L<Net::RDAP::Response> object containing
information about to the autonymous system referenced by C<$autnum>.
C<$autnum> must be a L<Net::ASN> object.

If no RDAP service can be found, then C<undef> is returned.

=cut

sub autnum {
	my ($self, $object, %args) = @_;
	croak('argument must be a Net::ASN') unless ('Net::ASN' eq ref($object));
	return $self->query('object' => $object, %args);
}

#
# main method
#
sub query {
	my ($self, %args) = @_;

	#
	# get the URL from the registry
	#
	my $url = Net::RDAP::Registry->get_url($args{'object'});
	croak('Unable to obtain URL for object') if (!$url);

	#
	# get the response from the server
	#
	my $response = $self->request(GET($url->as_string));

	#
	# check and parse the response
	#
	if ($response->is_error) {
		croak($response->status_line);

	} elsif ($response->header('Content-Type') !~ /^application\/rdap\+json/) {
		croak('500 Invalid Content-Type');

	} else {
		my $data = decode_json($response->content);
		if (!defined($data) || 'HASH' ne ref($data) || !defined($data->{'objectClassName'})) {
			croak('500 JSON parse error');

		} else {
			if ('domain' eq $data->{'objectClassName'}) 		{	return Net::RDAP::Object::Domain->new($data)	}
			elsif ('ip network' eq $data->{'objectClassName'})	{	return Net::RDAP::Object::IPNetwork->new($data)	}
			elsif ('autnum' eq $data->{'objectClassName'})		{	return Net::RDAP::Object::Autnum->new($data)	}

		}
	}
}

#
# wrapper function
#
sub request {
	my ($self, $req) = @_;
	return $self->ua->request($req);
}

#
# wrapper function
#
sub ua {
	my $self = shift;
	$self->{'ua'} = Net::RDAP::UA->new if (!defined($self->{'ua'}));
	return $self->{'ua'};
}

=pod

=head1 HOW TO CONTRIBUTE

L<Net::RDAP> is a work-in-progress; if you would like to help, the
project is hosted here:

=over

=item * L<https://gitlab.centralnic.com/centralnic/perl-net-rdap>

=back

=head1 DISTRIBUTION

The L<Net::RDAP> CPAN distribution contains a large number of RDAP-
related classes that all work together. See:

=over

=item * L<Net::RDAP::Base>, and its submodules:

=over

=item * L<Net::RDAP::Event>

=item * L<Net::RDAP::ID>

=item * L<Net::RDAP::Object>, and its submodules:

=over

=item * L<Net::RDAP::Autnum> (doesn't exist yet)

=item * L<Net::RDAP::Domain> (doesn't exist yet)

=item * L<Net::RDAP::Entity>

=item * L<Net::RDAP::Nameserver> (doesn't exist yet)

=item * L<Net::RDAP::Response> (doesn't exist yet)

=back

=item * L<Net::RDAP::Remark>, and its submodule:

=over

=item * L<Net::RDAP::Notice>

=back

=back

=item * L<Net::RDAP::Registry>

=item * L<Net::RDAP::Link>

=item * L<Net::RDAP::UA>

=back

=head1 COPYRIGHT

Copyright 2018 CentralNic Ltd. All rights reserved.

=head1 LICENSE

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of the author not be used
in advertising or publicity pertaining to distribution of the software
without specific prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut

1;
