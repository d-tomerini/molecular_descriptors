#!/usr/bin/perl

foreach $x (@ARGV) {
$x =~ s/.log//g;
system("obabel $x.log -O $ENV{'HOME'}/structures/$x.mol");
}
