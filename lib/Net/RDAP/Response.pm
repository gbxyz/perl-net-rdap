package Net::RDAP::Response;
use base qw(Net::RDAP::Object);
use strict;

#
# unlike Net::RDAP::Base, this module
# requires a reference:
#
sub new {
	my ($package, $ref) = @_;
	bless($ref, $package);
}

=pod

=head1 NAME

L<Net::RDAP::Response> - an RDAP response.

=head1 DESCRIPTION

The L<Net::RDAP> module will return objects of this class which have
been populated using JSON responses from RDAP servers.

This class inherits from L<Net::RDAP::Object> and therefore has all the
methods available in that class.

Additional methods:

	@conformance = $response->conformance;

Returns an array of strings, each providing a hint as to the
specifications used in the construction of the response.

=cut

sub conformance {
	my $self = shift;
	return @{$self->{'rdapConformance'}};
}

=pod

	@notices = $response->notices;

Returns a (potentially empty) array of L<Net::RDAP::Notice> objects.

=cut

sub notices { $_[0]->objects('Net::RDAP::Notice', $_[0]->{'notices'}) }

=pod

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
