#!/usr/bin/perl
#
@x = @ARGV;
print "@x\n";
foreach $x (@x) {
  $x =~ s/.log//g;
  print "processing $x... \n";
  mkdir("di-$x");
  unlink("$x.loc");
  $i = 0;
  while (-e "$x-$i.loc") {
    $y = "$x-$i";
    system("cat $y.loc >> $x.apploc");
    system("mv  $y.loc di-$x/.");
    system("mv  $y.din di-$x/.");
    system("mv  $y.int di-$x/.");
    system("mv  $y.inp di-$x/.");
    $i++;
  }
  system("mv $x.apploc $x.loc");
}


