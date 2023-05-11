# NAME

[Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) - an interface to the Registration Data Access Protocol
(RDAP).

# SYNOPSIS

    use Net::RDAP;

    my $rdap = Net::RDAP->new;

    #
    # traditional lookup:
    #

    # get domain info:
    $object = $rdap->domain(Net::DNS::Domain->new('example.com'));

    # get info about IP addresses/ranges:
    $object = $rdap->ip(Net::IP->new('192.168.0.1'));
    $object = $rdap->ip(Net::IP->new('2001:DB8::/32'));

    # get info about AS numbers:
    $object = $rdap->autnum(Net::ASN->new(65536));

    #
    # search functions:
    #

    my $server = Net::RDAP::Service->new("https://www.example.com/rdap");

    # search for domains by name:
    my $result = $server->domains('name' => 'ex*mple.com');

    # search for entities by name:
    my $result = $server->entities('fn' => 'J*n Doe');

    # search for nameservers by IP address:
    my $result = $server->nameservers('ip' => '192.168.56.101');

# DESCRIPTION

[Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) provides an interface to the Registration Data Access
Protocol (RDAP).

RDAP is gradually replacing Whois as the preferred way of obtainining
information about Internet resources (IP addresses, autonymous system
numbers, and domain names). As of writing, RDAP is quite well-supported
by Regional Internet Registries (who are responsible for the allocation
of IP addresses and AS numbers) but is still being rolled out among
domain name registries and registrars.

[Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) does all the hard work of determining the correct
server to query ([Net::RDAP::Registry](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ARegistry) is an interface to the
IANA registry of RDAP services), querying the server ([Net::RDAP::UA](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AUA)
is an RDAP HTTP user agent), and parsing the response
([Net::RDAP::Object](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject) and its submodules provide access to the data
returned by the server). As such, it provides a single unified
interface to information about all unique Internet identifiers.

# METHODS

## Constructor

    $rdap = Net::RDAP->new(%OPTIONS);

Constructor method, returns a new object. %OPTIONS is optional, but
may contain any of the following options:

- `use_cache` - if true, copies of RDAP responses are stored on
disk, and are updated if the copy on the server is more up-to-date.
This behaviour is disabled by default and must be explicitly enabled.
- `debug` - if true, tells [Net::RDAP::UA](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AUA) to print all HTTP
requests and responses to `STDERR`.

## Domain Lookup

    $object = $rdap->domain($domain);

This method returns a [Net::RDAP::Object::Domain](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3ADomain) object containing
information about the domain name referenced by `$domain`.

`$domain` must be a [Net::DNS::Domain](https://metacpan.org/pod/Net%3A%3ADNS%3A%3ADomain) object or a string containing a
fully-qualified domain name. The domain may be either a "forward" domain
(such as `example.com`) or a "reverse" domain (such as `168.192.in-addr.arpa`).

If there was an error, this method will return a [Net::RDAP::Error](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AError).

### Note on Internationalised Domain Names (IDNs)

Domain names which contain characters other than those from the ASCII-compatible
range must be encoded into "A-label" (or "Punycode") format before being passed
to [Net::DNS::Domain](https://metacpan.org/pod/Net%3A%3ADNS%3A%3ADomain). You can use [Net::LibIDN](https://metacpan.org/pod/Net%3A%3ALibIDN) or [Net::LibIDN2](https://metacpan.org/pod/Net%3A%3ALibIDN2) to
perform this encoding:

    use Net::LibIDN;

    my $name = "espécime.com";

    my $domain = $rdap->domain->(Net::DNS::Domain->new(idn_to_ascii($name, 'UTF-8')));

## IP Lookup

    $object = $rdap->ip($ip);

This method returns a [Net::RDAP::Object::IPNetwork](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AIPNetwork) object containing
information about the resource referenced by `$ip`.

`$ip` must be either a [Net::IP](https://metacpan.org/pod/Net%3A%3AIP) object or a string, and can represent any of the
following:

- An IPv4 address (e.g. `192.168.0.1`);
- An IPv4 CIDR range (e.g. `192.168.0.1/16`);
- An IPv6 address (e.g. `2001:DB8::42:1`);
- An IPv6 CIDR range (e.g. `2001:DB8::/32`).

If there was an error, this method will return a [Net::RDAP::Error](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AError).

## AS Number Lookup

    $object = $rdap->autnum($autnum);

This method returns a [Net::RDAP::Object::Autnum](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AAutnum) object containing
information about the autonymous system referenced by `$autnum`.

`$autnum` must be a [Net::ASN](https://metacpan.org/pod/Net%3A%3AASN) object or a literal integer AS number.

If there was an error, this method will return a [Net::RDAP::Error](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AError).

## Entity Lookup

    $entity = $rdap->entity($handle);

This method returns a [Net::RDAP::Object::Entity](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AEntity) object containing
information about the entity referenced by `$handle`, which must be
a string containing a "tagged" handle, such as `ABC123-EXAMPLE`, as
per RFC 8521.

    $exists = $rdap->exists($object);

This method returns a boolean indicating whether `$object` (which
must be a [Net::DNS::Domain](https://metacpan.org/pod/Net%3A%3ADNS%3A%3ADomain), [Net::IP](https://metacpan.org/pod/Net%3A%3AIP) or [Net::ASN](https://metacpan.org/pod/Net%3A%3AASN)) exists.

**Note**: the non-existence of an object does not indicate whether that
object is available for registration.

If there was an error, or no RDAP server is available for the specified
object, this method will return a [Net::RDAP::Error](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AError).

## Directly Fetching Known Resources

    $object = $rdap->fetch($thing, %OPTIONS);

This method retrieves the resource identified by `$thing`, which must
be either a [URI](https://metacpan.org/pod/URI) or [Net::RDAP::Link](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ALink) object, and returns a
[Net::RDAP::Object](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject) object (assuming that the server returns a valid
RDAP response). This method is used internally by [Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) but is
also available for when you want to directly fetch a resource without
using the IANA registry.

`%OPTIONS` is an optional hash containing additional options for
the query. The following options are supported:

- `user` and `pass`: if provided, they will be sent to the
server in an HTTP Basic Authorization header field.
- `class_override`: allows you to set or override the
`objectClassName` property in RDAP responses.

## Performing Searches

RDAP supports a limited search capability, but you need to know in
advance which RDAP server you want to send the search query to. The
[Net::RDAP::Service](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AService) class allows you to prepare and submit search
queries to specific RDAP servers.

## RDAP User Agent

    # access the user agent
    $ua = $rdap->ua;

    # specify a cookie jar
    $rdap->ua->cookie_jar('/tmp/cookies.txt');

    # specify a proxy
    $rdap->ua->proxy([qw(http https)], 'https://proxy.example.com');

You can access the [Net::RDAP::UA](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AUA) object used to communicate with RDAP
servers using the `ua()` method. This allows you to configure additional
HTTP features such as a file to store cookies, proxies, custom user-agent
strings, etc.

# HOW TO CONTRIBUTE

[Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) is a work-in-progress; if you would like to help, the
project is hosted here:

- [https://github.com/gbxyz/perl-net-rdap](https://github.com/gbxyz/perl-net-rdap)

# DISTRIBUTION

The [Net::RDAP](https://metacpan.org/pod/Net%3A%3ARDAP) CPAN distribution contains a large number of
RDAP-related modules that all work together. They are:

- [Net::RDAP::Base](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ABase), and its submodules:
    - [Net::RDAP::Event](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AEvent)
    - [Net::RDAP::ID](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AID)
    - [Net::RDAP::Object](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject), and its submodules:
        - [Net::RDAP::Error](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AError)
        - [Net::RDAP::Help](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AHelp)
        - [Net::RDAP::Object::Autnum](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AAutnum)
        - [Net::RDAP::Object::Domain](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3ADomain)
        - [Net::RDAP::Object::Entity](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AEntity)
        - [Net::RDAP::Object::IPNetwork](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3AIPNetwork)
        - [Net::RDAP::Object::Nameserver](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AObject%3A%3ANameserver)
        - [Net::RDAP::SearchResult](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ASearchResult)
    - [Net::RDAP::Remark](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ARemark), and its submodule:
        - [Net::RDAP::Notice](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ANotice)
- [Net::RDAP::EPPStatusMap](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AEPPStatusMap)
- [Net::RDAP::Registry](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ARegistry)
- [Net::RDAP::Registry::IANARegistry](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ARegistry%3A%3AIANARegistry)
- [Net::RDAP::Registry::IANARegistry::Service](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ARegistry%3A%3AIANARegistry%3A%3AService)
- [Net::RDAP::Service](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AService)
- [Net::RDAP::Link](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3ALink)
- [Net::RDAP::UA](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AUA)
- [Net::RDAP::Values](https://metacpan.org/pod/Net%3A%3ARDAP%3A%3AValues)

# DEPENDENCIES

- [DateTime::Format::ISO8601](https://metacpan.org/pod/DateTime%3A%3AFormat%3A%3AISO8601)
- [Digest::SHA1](https://metacpan.org/pod/Digest%3A%3ASHA1)
- [File::Basename](https://metacpan.org/pod/File%3A%3ABasename)
- [File::Slurp](https://metacpan.org/pod/File%3A%3ASlurp)
- [File::Spec](https://metacpan.org/pod/File%3A%3ASpec)
- [File::stat](https://metacpan.org/pod/File%3A%3Astat)
- [HTTP::Request::Common](https://metacpan.org/pod/HTTP%3A%3ARequest%3A%3ACommon)
- [JSON](https://metacpan.org/pod/JSON)
- [LWP::Protocol::https](https://metacpan.org/pod/LWP%3A%3AProtocol%3A%3Ahttps)
- [LWP::UserAgent](https://metacpan.org/pod/LWP%3A%3AUserAgent)
- [Mozilla::CA](https://metacpan.org/pod/Mozilla%3A%3ACA)
- [Net::ASN](https://metacpan.org/pod/Net%3A%3AASN)
- [Net::DNS](https://metacpan.org/pod/Net%3A%3ADNS)
- [Net::IP](https://metacpan.org/pod/Net%3A%3AIP)
- [URI](https://metacpan.org/pod/URI)
- [vCard](https://metacpan.org/pod/vCard)
- [XML::LibXML](https://metacpan.org/pod/XML%3A%3ALibXML)

# REFERENCES

- [https://tools.ietf.org/html/rfc7480](https://tools.ietf.org/html/rfc7480) - HTTP Usage in the Registration
Data Access Protocol (RDAP)
- [https://tools.ietf.org/html/rfc7481](https://tools.ietf.org/html/rfc7481) - Security Services for the
Registration Data Access Protocol (RDAP)
- [https://tools.ietf.org/html/rfc7482](https://tools.ietf.org/html/rfc7482) - Registration Data Access
Protocol (RDAP) Query Format
- [https://tools.ietf.org/html/rfc7483](https://tools.ietf.org/html/rfc7483) - JSON Responses for the
Registration Data Access Protocol (RDAP)
- [https://tools.ietf.org/html/rfc7484](https://tools.ietf.org/html/rfc7484) - Finding the Authoritative
Registration Data (RDAP) Service
- [https://tools.ietf.org/html/rfc8056](https://tools.ietf.org/html/rfc8056) - Extensible Provisioning
Protocol (EPP) and Registration Data Access Protocol (RDAP) Status Mapping
- [https://tools.ietf.org/html/rfc8288](https://tools.ietf.org/html/rfc8288) -  Web Linking
- [https://tools.ietf.org/html/rfc8521](https://tools.ietf.org/html/rfc8521) -  Registration Data Access
Protocol (RDAP) Object Tagging

# COPYRIGHT

Copyright 2022 CentralNic Ltd. All rights reserved.

# LICENSE

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
