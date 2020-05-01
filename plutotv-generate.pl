#!/usr/bin/perl

use strict;
use warnings;

use DateTime;
use DateTime::Format::Strptime qw(strptime);
use JSON;
use JSON::Parse ':all';
use HTTP::Request ();
use LWP::UserAgent;
use URI::Escape;

package main;

my $from = DateTime->now();
my $to = DateTime->now();
$to=$to->add(days => 10);

#printf("From %sZ To %sZ\n", $from, $to);

my $url = "http://api.pluto.tv/v2/channels?start=".$from."Z&stop=".$to."Z";
#printf($url . "\n");
my $request = HTTP::Request->new(GET => $url);
my $useragent = LWP::UserAgent->new;
my $response = $useragent->request($request);
if ($response->is_success) {
    my $epgfile = 'plutotv-epg.xml';
    my $m3ufile = 'plutotv.m3u';
    open(my $fh, '>', $epgfile) or die "Could not open file '$epgfile' $!";
    open(my $fhm, '>', $m3ufile) or die "Could not open file '$m3ufile' $!";
    print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    print $fh "<tv>\n";  

    print $fhm "#EXTM3U\n";  

    my @senderListe = @{parse_json($response->decoded_content)};
    for my $sender( @senderListe ) {
      if($sender->{number} > 0) { 
        my $sendername = $sender->{name};
        print $fh "<channel id=\"".uri_escape($sendername)."\">\n";
        print $fh "<display-name lang=\"de\"><![CDATA[".$sender->{name}."]]></display-name>\n" ;
        my $logo = $sender->{logo};
        $logo->{path} = substr($logo->{path}, 0, index($logo->{path}, "?"));
        print $fh "<icon src=\"".$logo->{path}."\" />\n";
        print $fh "</channel>\n";
      
      
        print $fhm "#EXTINF:-1 tvg-chno=\"".$sender->{number}."\" tvg-id=\"".uri_escape($sendername)."\" tvg-name=\"".$sender->{name}."\" tvg-logo=\"".$logo->{path}."\" group-title=\"PlutoTV\",".$sender->{name}."\n";
        print $fhm "http://service-stitcher.clusters.pluto.tv/stitch/hls/channel/".$sender->{_id}."/master.m3u8?deviceType=web&deviceMake=web&deviceModel=web&sid=".$sender->{number}."&deviceId=".$sender->{_id}."&deviceVersion=DNT&appVersion=DNT&deviceDNT=0&userId=&advertisingId=&deviceLat=&deviceLon=&app_name=&appName=web&buildVersion=&appStoreUrl=&architecture=&includeExtendedEvents=false&marketingRegion=DE&serverSideAds=true\n";
      }
    }

    for my $sender( @senderListe ) {
      if($sender->{number} > 0) {
              my $sendername = $sender->{name};
	      for my $sendung ( @{$sender->{timelines}}) {
		my $start = $sendung->{start};
		$start =~ s/-//ig;
		$start =~ s/://ig;
		$start =~ s/Z//ig;
		$start =~ s/\.//ig;
		$start =~ s/T//ig;
		$start = substr($start, 0, 14);

		my $stop = $sendung->{stop};
		$stop =~ s/-//ig;
		$stop =~ s/://ig;
		$stop =~ s/Z//ig;
		$stop =~ s/\.//ig;
		$stop =~ s/T//ig;
		$stop = substr($stop, 0, 14);
		print $fh "<programme start=\"".$start." +0100\" stop=\"".$stop." +0100\" channel=\"".uri_escape($sendername)."\">\n";
		my $episode = $sendung->{episode};
		print $fh "<title lang=\"de\"><![CDATA[".$sendung->{title}." - ".$episode->{rating}."]]></title>\n";
		
		print $fh "<desc lang=\"de\"><![CDATA[".$episode->{description}."]]></desc>\n";
		print $fh "</programme>\n";
	      }
	    }
    }
  print $fh "\n</tv>\n\n\n";
  close $fh;
  close $fhm;
  print "Ready\n";
}
else {
    print STDERR $response->status_line, "\n";
}


