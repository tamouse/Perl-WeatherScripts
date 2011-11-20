Utilities for dealing with weather web services
===============================================

Various utilities for consuming and processing weather web services.

See [Google Weather API Wiki Article](http://wiki.tamaratemple.com/Main/GoogleWeatherApi).

`currentconditions.pl` -- gets the current conditions for the given
city. If no city is given, it will attempt to find the city associated
with your external IP address.

        usage: currentconditions.pl [<options>] [--]
        
        options:  -d|--domain-name [<domain>]
                      Domain name to use for weather information (defaults to tamnet.homeip.net)
                  -g|--geoip-data [<file>]
                      GeoIP City database file (defaults to /usr/share/GeoIP/GeoLiteCity.dat)
                  -c|--city [<city>]
                      City to look up weather for (defaults to )
    

