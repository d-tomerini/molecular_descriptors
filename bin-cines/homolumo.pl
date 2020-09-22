#!/usr/bin/perl
use List::Util qw/ max min /;
use Term::ANSIColor;

@all =glob("*BQ.log") if ($ARGV[0] eq "all");
@all = @ARGV if ($ARGV[0] ne "all");


foreach $X (@all){
 $k=0; 
 printf "% 22s  ", $X;
 open X, "$X" or die "no such file, $X!";
 $pass=1;
 $passb = 1;
 for $k (0..3) {$ao[$k] = -1000};
 for $k (0..3) {$av[$k] = -1000};
 for $k (0..3) {$bo[$k] = -1000};
 for $k (0..3) {$bv[$k] = -1000};
 $found1=0;
 $found2=0;
 $pot1 =0;
 $pot2 =0;
 $homo = 0.0;
 $lumo = 0.0;

 while (<X>){
  if (/Alpha  occ/) {
    $x = $_;
    $pass = 1;
  }
  if (/Alpha virt/ and $pass) {
    @x= split(" ", $x);
    $ao[$k] = $x[-1];
    @x= split;
    $av[$k] = $x[-5];
    $pass = 0;
  }

  if (/Beta  occ/) {
    $x = $_;
    $passb = 1;
  }
  if (/Beta virt/ and $passb) {
    @x= split(" ", $x);
    $bo[$k] = $x[-1];
    @x= split;
    $bv[$k] = $x[-5];
    $passb=0;
  }
  if (/Sum of electronic and thermal Free Energies/){
   @i = split;
   $pot1 = $i[-1];
   $found1 = 1;
  }
  if (/termination/){
    $k++;
 }
 }
 close X;

 $X =~ s/.log//g;
 open X, "$X-.log";
 while (<X>){
  if (/Sum of electronic and thermal Free Energies/){
   @i = split;
   $pot2 = $i[-1];
   $found2 = 1;
  }
 }
  printf  colored( sprintf("%.5f", ($pot1 - $pot2)*27.211396132 - 1.46),"red"),  if ($found1 and $found2);
  printf "% 7s", "--------" if ! ($found1 and $found2);
  for $k (3,1) {
  $homo = max($ao[$k], $bo[$k]);
  $lumo =  max( $av[$k], $bv[$k]);
  $ei = (1/4.0)*($homo+$lumo)*($homo+$lumo)/($lumo-$homo) if ($homo != $lumo);
  if ($homo !=-1000) { printf "   % .5f % .5f ei= % .5f ", $homo, $lumo, $ei };
  }
  printf "\n";

}

if ($ARGV[0] eq "all") {
@all =glob("*BQ-.log") if ($ARGV[0] eq "all");
foreach $X (@all){
 open X, "$X" or die "no such file, $X!";
 printf "% 22s", $X;
 $pass=1;
 $passb = 1;
 $ao = 1000;
 $av = 1000;
 $bo = 1000;
 $bv = 1000;
 $found1=0;
 $found2=0;
 $pot1 =0;
 $pot2 =0;
 while (<X>){
  $x = $_ if (/Alpha  occ/);
  if (/Alpha virt/ and $pass) {
    @x= split(" ", $x);
   $ao = $x[-1];
    @x= split;
    $av = $x[-4];
    $pass = 0;
  }
  $x = $_ if (/Beta  occ/);
  if (/Beta virt/ and $passb) {
    @x= split(" ", $x);
    $bo = $x[-1];
   @x= split;
    $bv = $x[-4];
    $passb=0;
  }
 }
 close X;
 $X =~ s/.log//g;

 $homo = max($ao, $bo);
 $lumo =  max( $av, $bv);

 $ei = (1/4.0)*($homo+$lumo)*($homo+$lumo)/($lumo-$homo);
 printf "   % .5f % .5f ei= % .5f ", $homo, $lumo, $ei;
 printf "%.5f", ($pot1 - $pot2)*27.211396132 - 1.46  if ($found1 and $found2);
 printf "\n";
 }
}

