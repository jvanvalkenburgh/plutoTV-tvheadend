#!/bin/bash
cd /home/jvanvalkenburgh/git/plutoTV-tvheadend
# when programn guide is regenb'ed, the url params change.  this makes tvheadend
# think its a newux, and purges all of the "old" muxes
# perl plutotv-generate.pl --createm3u --usestreamlink   #  --useffmpeg
perl plutotv-generate.pl --usestreamlink   #  --useffmpeg
cat plutotv-epg.xml | socat - UNIX-CONNECT:/home/jvanvalkenburgh/.hts/tvheadend/epggrab/xmltv.sock
cat plutotv-epg.xml | socat - UNIX-CONNECT:/home/jvanvalkenburgh/.hts/tvheadend/epggrab/xmltv.sock
