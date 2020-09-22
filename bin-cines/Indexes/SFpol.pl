#!/usr/bin/perl -w
open WFN, $ARGV[0] or die "Cannot find the file '$ARGV[0]'";
$seed= substr $ARGV[0], 0, -4;
system("sed 's/TOTAL ENERGY/THE  HF ENERGY/' $seed.wfn > picc");
rename picc, "$seed.wfn";
while (<WFN>) {
  if (/GAUSSIAN/) {
    $i=0;
    $_=<WFN>;
    do {
      $atoms[$i] = substr $_, 0, 8;
      @i= split;
      @{$coord[$i]}= @i[4..6];
      $i++;
      $_=<WFN>;
    } while !(/CENTRE ASSIGNMENTS/);
  }
}


open LOG, "$seed.log" or die "Cannot find the file '$seed.log'. wfn and gaussian files should have the same name!";
while (<LOG>) {
  if (/alpha electrons/) {
    @i= split;
    $alpha= $i[0];
    $beta= $i[-3];
    last;
  }
}

print "atom list: \n";
foreach (@atoms) { print "$_ \n" };
print "$alpha alpha electrons\n$beta  beta electrons\n";
print "creating file $seed.inp\n";
open INP, ">$seed.inp";

if (!($alpha == $beta)) {
  $alpha++;
  print "Unpaired electrons. Use 'correttalocsp'\n";

  print INP "$ARGV[0]";
  $intg = "2";
  $integrate = "";
  for $i (0..$#atoms) {
    print INP "
$atoms[$i]
PROMEGA
64 48 200
OPTIONS
INTEGER $intg
 6 1     calculate AOM $integrate
 9 $alpha
REAL 0 ";
  $integrate = "\n 11 0";
  $intg = "3";
  }
}
if ($alpha == $beta) {
  print "Paired electrons. Use 'correttaloc'\n";
  print INP "$ARGV[0]";
  $intg = "1";
  $integrate = "";
  for $i (0..$#atoms) {
    print INP "
$atoms[$i]
PROMEGA
64 48 200
OPTIONS
INTEGER $intg
 6 1     calculate AOM $integrate
REAL 0 ";
$integrate = "\n 11 0";
$intg = "2";
}
}
close INP;

sub distance() {
  @i[0..2] = @_[0..2];
  @j[0..2] = @_[3..5];
  my $b= 0.0;
  
  for my $i (0..2) {
    $b += ($i[$i]-$j[$i])*($i[$i]-$j[$i]);
  }
  $b = sqrt($b);
}


