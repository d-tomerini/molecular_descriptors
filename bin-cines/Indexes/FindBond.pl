#!/usr/bin/perl

open WFN, $ARGV[0] or die "Cannot find the file '$ARGV[0]'";
$seed= substr $ARGV[0], 0, -4;
system("sed 's/TOTAL ENERGY/THE  HF ENERGY/' $seed.wfn > picc");
rename picc, "$seed.wfn";

open LOG, "$seed.log" or die "Cannot find the file '$seed.log'. wfn and gaussian files should have the same name!";
while (<LOG>) {
  if (/Input orientation:/) {
    $_= <LOG>;  $_= <LOG>; $_= <LOG>;  $_= <LOG>;
    do {
      @i= split;
      $_= <LOG>;
    } while (!(/---------------/));
  }
}

close LOG;
$atomnum = $i[0];

open DIN, "$seed.din";
open OUTMAT, ">$seed.delmat";
open ALPHTMAT, ">$seed.alpha.delmat";
open BETMAT, ">$seed.beta.delmat";
while (<DIN>) {
  if (/DELOCALIZATION and LOCALIZATION INDEXES FOR ATOMS A and B/) {
    @i= split;
    $A = @i[-4];
    $B = @i[-2];
    $A1= @i[-5];
    $B1= @i[-3];

    $_ = <DIN>;
    $_ = <DIN>;
    @_ = split;
    $del[$A][$B] = sprintf("%8.6f",$_[-1]);
    $del[$B][$A] = sprintf("%8.6f",$_[-1]);
    $del[$A][0] =  $A1;
    $del[0][$A] =  $A1;
    $del[$B][0] =  $B1;
    $del[0][$B] =  $B1;
    $_ = <DIN>;
    @_ = split;
    $delalpha[$A][$B] = $_[-1];
    $delalpha[$B][$A] = $_[-1];
    $delalpha[$A][0] = $A1;
    $delalpha[0][$A] = $A1;

    $_ = <DIN>;
    @_ = split;
    $delbeta[$A][$B] = $_[-1];
    $delbeta[$B][$A] = $_[-1];
    $delbeta[$A][0] = $A1;
    $delbeta[0][$A] = $A1;

    $_ = <DIN>;
    @_ = split;
    $del[$A][$A] = sprintf("%8.6f",$_[-1]);
    $_ = <DIN>;
    @_ = split;
    $del[$B][$B] = sprintf("%8.6f",$_[-1]);

  }
}

for $i(0..$atomnum) {
  for $j(0..$atomnum) {
    printf OUTMAT "$del[$i][$j], ";
  }
  print OUTMAT"\n"
}
print "$atomnum atoms \n";


