#!/usr/bin/perl -w

# simple script to submit a batch of jobs on the cines supercomputer
# this was meant to send multiple variations of a molecule structure, and organize files accordingly
# 
# sleep required, to avoid being throttled by the scheduler

# master pbs file to ensure changeable properties on a single file
# usage: given a series of molecules named molname+variations.com: topbs molname*.com

use Time::HiRes qw(usleep nanosleep);

$pbs = "$ENV{'HOME'}/bin/data/pbs.g09";

@i = @ARGV;
foreach $i (@i) {
  $i =~ s/.com//g;
  $i =~ s/.log//g;
  $z = substr($i, -10);
  if (-e "$i.com"){
    system("sed -e \"s/xxx/$i/ig\" $pbs > pbs.g09.$i");
    system("sed -i \"s/yyy/$z/ig\" pbs.g09.$i");
    system("qsub pbs.g09.$i") unless ($ARGV[0] eq 'no') ;
    usleep(250);
  }
}


