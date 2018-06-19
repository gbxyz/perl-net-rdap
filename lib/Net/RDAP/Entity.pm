package Net::RDAP::Entity;
use base qw(Net::RDAP::Object);
use vCard;
use strict;

=pod

=head1 NAME

L<Net::RDAP::Entity> - a module representing an entity (person or
organization).

=head1 DESCRIPTION

L<Net::RDAP::Entity> represents persons or organizations in RDAP
responses. An entity is a vCard object plus metadata.
L<Net::RDAP::Entity> inherits from L<Net::RDAP::Object> so has
access to all that's modules methods.

Other methods include:

	@roles = $object->roles;

Returns a (potentially empty) array listing this entity's roles.
The possible values is defined by an IANA registry, see:

=over

=item * L<https://www.iana.org/assignments/rdap-json-values/rdap-json-values.xhtml>

=back

=cut

sub roles { $_[0]->{'roles'} ? @{$_[0]->{'roles'}} : () }

=pod

	$vcard = $entity->vcard;

Returns a L<vCard> object for the entity.

=cut

sub vcard {
	my $self = shift;

	my $card = vCard->new;

	my @nodes = @{$self->{'vcardArray'}->[1]};
	
	foreach my $nref (@nodes) {
		my ($type, $params, $vtype, $value) = @{$nref};

		if ('fn' eq $type)		{	$card->full_name($value)	}
		elsif ('org' eq $type)		{	$card->organization($value)	}
		# elsif ('adr' eq $type)		{	$card->addresses()		}
		# elsif ('tel' eq $type)		{	$card->addresses()		}
		# elsif ('email' eq $type)	{	$card->addresses()		}

	}

	return $card;
}

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
