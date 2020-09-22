#!/usr/bin/perl

foreach $x (@ARGV) {
    $nt = 0;
    open F, "grep -n 'Normal termination' $x |" ;
    @nt = <F>;
    close F;
    if (@nt == 4) {
        print "processing $x... ";
        @s = split(':', $nt[1]);
        open ALL, "$x";
        @all = <ALL>;
        close ALL;
        system("cp $x bk.$x");
        $x =~ s/.log//g;
        system("mv $x.* solvent/. ");  
        open ONS, ">nosolvent/$x.log";
        open OS, ">solvent/$x.log";
        print ONS @all[0..$s[0]-1];
        @t = split(':', $nt[3]);
        print OS @all[$s[0]..$t[0]-1];
        close ONS;
        close NS;
        system("mv bk.$x.log $x.log");

    } else {
        print "$x has only solvent file\n";
        $x =~ s/.log//g;
        system("mv $x.* solvent/.");
        system("cp solvent/$x.com .");
    } 
     
}


