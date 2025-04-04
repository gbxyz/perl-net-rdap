package Net::RDAP::Object;
use base qw(Net::RDAP::Base);
use strict;
use warnings;

=pod

=head1 NAME

L<Net::RDAP::Object> - a module representing an RDAP object.

=head1 DESCRIPTION

RDAP responses contain one or more RDAP objects: typically the response
itself corresponds to an RDAP object, but RDAP objects can contain
other RDAP objects (such as the entities and nameservers associated
with a domain name).

L<Net::RDAP::Object> represents such objects, whether top-level or
embedded. It inherits from L<Net::RDAP::Base> so has all the methods
available to that module.

=cut

#
# Constructor method. $args is a hashref, $url is the URL this
# object was loaded from
#
sub new {
    my ($package, $args, $document_url, $parent) = @_;

    return $package->SUPER::new($args, $document_url, $parent);
}

=pod

=head1 METHODS

=head2 RDAP Conformance

    @conformance = $response->conformance;

Returns an array of strings, each providing a hint as to the
specifications used (by the server) in the construction of the response.

This method will return C<undef> unless called on the top-most object
in a response.

=cut

sub conformance {
    my $self = shift;
    return @{$self->{'rdapConformance'} || []};
}

=pod

=head2 Notices

    @notices = $response->notices;

Returns a (potentially empty) array of L<Net::RDAP::Notice> objects.

The array will always be empty unless called on the top-most object
in a response.

=cut

sub notices { $_[0]->objects('Net::RDAP::Notice', $_[0]->{'notices'}) }

=pod

=head2 Object Class

    $class = $object->class;

Returns a string containing the "class name" of this object (i.e., one
of: C<ip network>, C<entity>, C<nameserver>, C<autnum> or C<domain>).

=cut

sub class { $_[0]->{'objectClassName'} }

=pod

=head2 Handle

    $handle = $object->handle;

Returns a string containing the "handle" of the object.

=cut

sub handle { $_[0]->{'handle'} }

=pod

=head2 Status

    @status = $object->status;

Returns a (potentially empty) array of state identifiers. The possible
values are defined by bn IANA registry; see:

=over

=item * L<https://www.iana.org/assignments/rdap-json-values/rdap-json-values.xhtml>

=back

=cut

sub status { $_[0]->{'status'} ? @{$_[0]->{'status'}} : () }

=pod

=head2 Remarks

    @remarks = $object->remarks;

Returns a (potentially empty) array of L<Net::RDAP::Remark> objects.

=cut

sub remarks { $_[0]->objects('Net::RDAP::Remark', $_[0]->{'remarks'}) }

=pod

=head2 Events

    @events = $object->events;

Returns a (potentially empty) array of L<Net::RDAP::Event> objects.

=cut

sub events { $_[0]->objects('Net::RDAP::Event', $_[0]->{'events'}) }

=pod

    $event = $object->event($action);

Returns the first L<Net::RDAP::Event> object whose C<action> property
matches C<$action> (or C<undef> if no such event is found).

=cut

sub event {
    my ($self, $action) = @_;

    return [ grep { $_->action eq $action } $self->events ]->[0];
}

=pod

=head2 Port-43 Whois Server

    $port43 = $object->port43;

Returns a L<Net::DNS::Domain> object containing the name of the
legacy port-43 whois server for this object.

=cut

sub port43 { $_[0]->{'port43'} }

=pod

=head2 Public IDs

    @ids = $object->ids;

Returns a (potentially empty) array of L<Net::RDAP::ID> objects.

=cut

sub ids { $_[0]->objects('Net::RDAP::ID', $_[0]->{'publicIds'}) }

=pod

=head2 Entities

    @entities = $object->entities;

Returns a (potentially empty) array of L<Net::RDAP::Object::Entity> objects.

=cut

sub entities { $_[0]->objects('Net::RDAP::Object::Entity', $_[0]->{'entities'}) }

=pod

    $entity = $object->entity($role);

Returns the first L<Net::RDAP::Object::Entity> object whose C<roles> property
contains C<$role> (or C<undef> if no such entity is found).

    $registrant = $object->registrant;

Alias for C<$object-E<gt>entity('registrant')>.

    $registrar = $object->registrar;

Alias for C<$object-E<gt>entity('registrar')>.

=cut

sub entity {
    my ($self, $role) = @_;

    return [ grep { $_->has_role($role) } $self->entities ]->[0];
}

sub registrant { shift->entity(q{registrant}) }
sub registrar  { shift->entity(q{registrar}) }

=pod

=head2 Redactions

    @redactions = $object->redactions;

If the server supports L<RFC 9537|https://www.rfc-editor.org/rfc/rfc9537.html>,
then this method will return an array of L<Net::RDAP::Redaction> objects
corresponding to the fields listed in the C<redacted> property of the object.

=cut

sub redactions { $_[0]->objects('Net::RDAP::Redaction', $_[0]->{'redacted'}) }

=pod

=head1 COPYRIGHT

Copyright 2018-2023 CentralNic Ltd, 2024-2025 Gavin Brown. For licensing information,
please see the C<LICENSE> file in the L<Net::RDAP> distribution.

=cut

1;
