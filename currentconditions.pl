#!/usr/bin/perl -w
#
# currentconditions - display the current weather conditions for a
#                     given city from the Google Weather API 
#
# Author: Tamara Temple <tamara@tamaratemple.com>
# Created: 2011/11/19
# Time-stamp: <2011-11-20 14:04:02 tamara>
# Copyright (c) 2011 Tamara Temple Web Development
# License: GPLv3
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# See [Google Weather API Wiki Article](http://wiki.tamaratemple.com/Main/GoogleWeatherApi)
#



use strict;
use XML::Simple;
use Data::Dumper;
use Geo::IP 1.006;
use URI::Escape;

use constant DEFAULT_GEOIP_DATA => "/usr/share/GeoIP/GeoLiteCity.dat";
use constant DEFAULT_DOMAIN_NAME => "tamnet.homeip.net";
use constant DEFAULT_CITY => '';

use Getopt::Mixed::Help(
    'd>domain-name:s domain' => "Domain name to use for weather information",
    'g>geoip-data:s file' => "GeoIP City database file",
    'c>city:s city' => "City to look up weather for"
    );

my $geoip_database = $opt_geoip_data;
my $domain_name = $opt_domain_name;
my $city = $opt_city;

sub whatsmyip {
    my $domain = shift @_;
    my $cmd = 'dig +short @208.67.222.222 ' . $domain;
    my $ip = `$cmd`; chomp($ip);
    return $ip;
}


sub getweather {
    my $city = shift @_;
    my $url = "http://www.google.com/ig/api?weather=" . uri_escape($city);
    my $curlcmd = "curl -s $url";
    my $weather = `$curlcmd`;
    my $w = XMLin($weather);
    return $w;
}

if ($city =~ /^\s*$/) {
    my $geoip = Geo::IP->open($geoip_database);
    my $geoip_rec = $geoip->record_by_addr(whatsmyip($domain_name));
    die("error from geoip record retrieval: geoip_database=$geoip_database domain_name=$domain_name") if !defined($geoip_rec);
    $city = $geoip_rec->city;
}

my $w = getweather($city);


printf("Current conditions for %s on %s:
Temp: %s F (%s C)
Wind: %s
Humidity: %s
Sky: %s
",
       $w->{weather}->{forecast_information}->{city}->{data},
       $w->{weather}->{forecast_information}->{forecast_date}->{data},
       $w->{weather}->{current_conditions}->{temp_f}->{data},
       $w->{weather}->{current_conditions}->{temp_c}->{data},
       $w->{weather}->{current_conditions}->{wind_condition}->{data},
       $w->{weather}->{current_conditions}->{humidity}->{data},
       $w->{weather}->{current_conditions}->{condition}->{data}
    );

=pod

=head1 NAME

currentconditions.pl

=head1 SYNOPSIS

currentconditions [-c <city>] [-d <domain>] [-g <geoip-database>]

=head1 DECSRIPTION

Retrieves the current weather conditions from the (undocumentted)
Google Weather API service for the given city, or if omitted, will try
to determine the current location based upon the network's external IP
address.

=head1 OPTIONS

=over

=item *
-d|--domain-name [<domain>]
Domain name to use for weather information (defaults to tamnet.homeip.net)

=item *
-g|--geoip-data [<file>]
GeoIP City database file (defaults to /usr/share/GeoIP/GeoLiteCity.dat)

=item *
-c|--city [<city>]
City to look up weather for (defaults to )

=back

=head1 FILES

If no city is given, the external IP is used to look up the city based
upon the GeoLiteCity data base avaialable from
L<http://www.maxmind.com/app/ip-location>. The default location is
C</usr/share/GeoIP/GeoLiteCity.dat>.

=head1 EXAMPLES

=over

=item C<currentconditions.pl>

=back

Shows current weather conditions for the city based up on the external
IP address.

=over

=item C<currentconditions -c"St. Paul, MN">

=item C<currentconditions --city="St. Paul, MN">

=back

Shows current weather conditoins for St. Paul, Minnesota.

=over

=item C<currentconditions -d"tamnet.homeip.net">

=item C<currentconditions --domain-name=tamnet.homeip.net>

=back

Shows current weather conditions for the location of the domain
tamnet.homeip.net.

=head1 SEE ALSO

L<http://wiki.tamaratemple.com/Main/GoogleWeatherApi>

=head1 AUTHOR

Tamara Temple <tamara@tamaratemple.com>
