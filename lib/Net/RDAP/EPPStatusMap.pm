package Net::RDAP::EPPStatusMap;
use base qw(Exporter);
use strict;
use warnings;

our @EXPORT = qw(epp2rdap rdap2epp);

#
# EPP status => RDAP status mapping, see RFC 8056, Section 2, Page 6:
#
my %MAP = (
    'addPeriod'                 => 'add period',
    'autoRenewPeriod'           => 'auto renew period',
    'clientDeleteProhibited'    => 'client delete prohibited',
    'clientHold'                => 'client hold',
    'clientRenewProhibited'     => 'client renew prohibited',
    'clientTransferProhibited'  => 'client transfer prohibited',
    'clientUpdateProhibited'    => 'client update prohibited',
    'inactive'                  => 'inactive',
    'linked'                    => 'associated',
    'ok'                        => 'active',
    'pendingCreate'             => 'pending create',
    'pendingDelete'             => 'pending delete',
    'pendingRenew'              => 'pending renew',
    'pendingRestore'            => 'pending restore',
    'pendingTransfer'           => 'pending transfer',
    'pendingUpdate'             => 'pending update',
    'redemptionPeriod'          => 'redemption period',
    'renewPeriod'               => 'renew period',
    'serverDeleteProhibited'    => 'server delete prohibited',
    'serverRenewProhibited'     => 'server renew prohibited',
    'serverTransferProhibited'  => 'server transfer prohibited',
    'serverUpdateProhibited'    => 'server update prohibited',
    'serverHold'                => 'server hold',
    'transferPeriod'            => 'transfer period',
);

#
# RDAP status => EPP status mapping, which is just a transposed version of the
# above
#
my %RMAP;
foreach my $eppStatus (keys(%MAP)) {
    $RMAP{$MAP{$eppStatus}} = $eppStatus;
}

sub epp2rdap { $MAP  {$_[0]} }
sub rdap2epp { $RMAP {$_[0]} }

=pod

=head1 NAME

L<Net::RDAP::EPPStatusMap> - a module which provides a mapping between EPP and
RDAP status values.

=head1 SYNOPSIS

    use Net::RDAP::EPPStatusMap;

    # prints 'client delete prohibited'
    print epp2rdap('clientDeleteProhibited');

    # prints 'clientDeleteProhibited'
    print rdap2epp('client delete prohibited');

=head1 DESCRIPTION

RFC 8056 describes the mapping of the Extensible Provisioning Protocol
(EPP) statuses with the statuses registered for use in the Registration
Data Access Protocol (RDAP).

This module provides two functions which provide an easy way to convert
status values from one protocol into the other.

=head1 EXPORTED FUNCTIONS

=head2 epp2rdap()

The C<epp2rdap()> function accepts an EPP status code as an argument and
returns the corresponding RDAP status. If no mapping is defined then
it returns C<undef>.

=head2 rdap2epp

The C<rdap2epp()> function accepts an RDAP status code as an argument and
returns the corresponding EPP status. If no mapping is defined then
it returns C<undef>.

=head1 COPYRIGHT

Copyright 2018-2023 CentralNic Ltd, 2024-2025 Gavin Brown. For licensing information,
please see the C<LICENSE> file in the L<Net::RDAP> distribution.

=cut

1;
