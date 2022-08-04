#!/usr/bin/env perl

$/="";
open(FILE, "<", $ARGV[0]);
$pattern = qr/($ARGV[1])/;
$radius = $ARGV[2];
$width = 2*$radius;

while (<FILE>) {
	chomp;
	s/\n/ /g;
	s/--/ -- /g;
	while ( $_ =~ /$pattern/gi ) {
		$match = $1;
		$pos = pos($_);
		$start = $pos - $radius - length($match);
		if ($start < 0) {
			$extract = substr($_, 0, $width+$start+length($match));
			$extract = (" "x-$start) . $extract;
			$len = length($extract);
		} else {
			$extract = substr($_, $start, $width+length($match));
		}
		print "$extract\n";
	}
}
