#!/usr/bin/perl -w

open LOG, $ARGV[0] or die "Cannot find the file '$ARGV[0]'";
shift(@ARGV);

while (<LOG>) {
  if (/Alpha  occ. eigenvalues/i) {
    while (/Alpha  occ. eigenvalues/i) {
      $x=$_;
      $_=<LOG>
    };
    @i=split(' ', $x);
    $HOMO=$i[-1];    
    @i=split;
    $LUMO= $i[4];
  }
  if (/Beta  occ. eigenvalues/i) {
    while (/Beta  occ. eigenvalues/i) {
      $x=$_;
      $_=<LOG>
    };
    @i=split;
    $LUMO= $i[4];
  }
}

print "HOMO-LUMO-gap: $HOMO $LUMO    ";
print $LUMO-$HOMO,"\n";

$EI= ( $HOMO+$LUMO)*( $HOMO+$LUMO)/(4*($LUMO- $HOMO));

print "\nei = $EI\n";
