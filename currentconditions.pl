#!/usr/bin/perl -w
#
# currentconditions
#
# Author: Tamara Temple <tamara@tamaratemple.com>
# Created: 2011/11/19
# Time-stamp: <2011-11-19 19:54:57 tamara>
# Copyright (c) 2011 Tamara Temple Web Development
# License: GPLv3
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

       
       
