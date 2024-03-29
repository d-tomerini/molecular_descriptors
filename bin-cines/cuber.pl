#!/usr/bin/perl -w

$home= $ENV{'HOME'};
$pbs = "$home/bin/data/pbs.cube";

open F, ">pbs.allcubes";
print F "module load gaussian/09_C01\n";

foreach $i (@ARGV) {
    $i =~ s/.log//g;
    system("sed -e \"s/xxx/$i/ig\" $pbs > pbs.cube.$i");
    print F "bash pbs.cube.$i \n"
}

system('bash pbs.allcubes > pbs.output &');

