#!/usr/bin/perl

# This script creates a script readable by jmol, to overlay the partial charges of the atoms

# Input: One or more gaussian log files, and it expects a similarly named spinden file
# Output: a jmol script to load and overlay the charges, named file.sd.script
# Required files: a preprocessed .spinden file with the same name as the log file

foreach $x (@ARGV){
    $x =~ s/.log//g;
    $ats = "";
    print "processing $x...\n";
    open X, "$x.spinden" or next;
    $i = 0;
    while (<X>) {
        @app = split;
        $ats[$i] = $app[0];
        $ch[$i] = $app[-1];
        print "$ats[$i] $ch[i] \n";
        $i++;
    }
    close X;
    open Y, ">$x.sd.script";
    print Y "load 'file:///C:/Users/DANY/Desktop/structures/$x.cubes/$x.log'; select all; color label black; font label 20 bold; ";
    for $i (0..$#ch) {
        printf Y "select $ats[$i]; label %.2f  ;  ", $ch[$i]*100;
    }
    close Y
} 

