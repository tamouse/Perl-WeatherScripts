#!/usr/bin/perl -w
#
# currentconditions - display the current weather conditions for a
#                     given city from the Google Weather API 
#
# Author: Tamara Temple <tamara@tamaratemple.com>
# Created: 2011/11/19
# Time-stamp: <2012-11-13 07:43:13 tamara>
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

use strict;
use Data::Dumper;
use URI::Escape;
use XML::Simple;

# TODO: Switch to Getopt::Auto!!

use Getopt::Mixed::Help(
    's>station-name=s station' => "METAR station name (required)",
    'd>debug:i number' => 'turn on debug information',
    );

my $station = $opt_station_name;
my $debug = $opt_debug;

sub getweather {
    my $station	= shift @_;
    printf("DEBUG @ Line %s: var %s = %s\n", __LINE__, '$station', Dumper($station));
    my $url	= "http://www.aviationweather.gov/adds/dataserver_current/httpparam?datasource=metars&requesttype=retrieve&format=xml&hoursBeforeNow=1&mostRecent=true&stationString=" . uri_escape($station);
    my $curlcmd = "curl -s $url";
    my $weather = `$curlcmd`;
    printf("DEBUG @ Line %s: var %s = %s\n", __LINE__, '$weather', Dumper($weather)) if $debug;    
    my $w	= XMLin($weather);
    printf("DEBUG @ Line %s: var %s = %s\n", __LINE__,  '$w', Dumper($w)) if $debug;
    return $w;
}

my $w = getweather($station);

exit;


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

currentconditions [-D|Debug] stationID

=head1 DECSRIPTION

Uses the NOAA Aviation Weather service L<http://www.aviationweather.gov> to retrieve the METAR report for the given stationID.

=head1 OPTIONS

=over

=item *
C<stationID> -- The station ID used to retrieve the METAR report. Station IDs can be found at L<http://www.aviationweather.gov/static/adds/metars/stations.txt>.

=item *
C<-D|Debug> -- Turn on extra debugging information.

=back

=head1 EXAMPLES

=over

=item C<currentconditions.pl> KSTP

=back

Shows current conditions for METAR station "KSTP" (St. Paul, Minnesota)

=head1 AUTHOR

Tamara Temple <tamara@tamaratemple.com>
