#!/usr/bin/perl -w

use Permutor;

open LOC, "$ARGV[0]" or die "File does not exist. Exiting...\n";
$seed= substr $ARGV[0], 0, -4;
$KAt= 0;
while (<LOC>) {
  ($NAt[$KAt],$lmo,$AtName[$KAt],$NumAt[$KAt])  = split;
  $ind[$NAt[$KAt]]=$KAt;
  @po=();
  while (scalar(@po<$lmo)) {
    $_=<LOC>;
    @i = split;
    push(@po,@i);
  }
  $_=<LOC>;
  ($LogQ,$NFbeta,$Ialpha1) = split;
  @LogQ = split(//, $LogQ);
  @{$AOM[$KAt]}=();
  $LMot = $lmo*($lmo+1)/2;
  while (scalar(@{$AOM[$KAt]}<$LMot)) {
    $_=<LOC>;
    @i = split;
    push(@{$AOM[$KAt]},@i);
  }
  $KAt++;
}

$LogQ =~ tr/TF/10/;
@LogQ = split(//, $LogQ);
$KAt--;
$lmo--;
$Ialpha1--;
$NFbeta--;


for  $jk (0..$KAt) {
  $k=-1;
  for $i (0..$lmo) {
    for $j (0..$i) {
      $k++;
      $S[$i][$j][$jk] = $AOM[$jk]->[$k];
      $S[$j][$i][$jk] = $S[$i][$j][$jk];
    }
  }
}

for  $jk (0..$KAt-1) {
  for $kl ($jk..$KAt) {
    $faaa[$kl]=0.0;
    $faab[$kl]=0.0;
    $faba[$jk][$kl]=0.0;
    $fabb[$jk][$kl]=0.0;
    $k=-1;
    if ($LogQ[0] or $LogQ[2]) {
      for $i (0..$lmo) {
        for $j (0..$i) {
          $k++;
          $hh=2.0;
          $hh=1.0 if ($i==$j);
     	  $anmin = sqrt($po[$i]*$po[$j])/2.0;
          $faaa[$kl]-= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          $faab[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$jk]->[$k];
          $fabb[$jk][$kl]+= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$jk]->[$k];
        }
      }
    }
    if ($LogQ[3]) {
      for $i (0..$Ialpha1-1) {
        for $j (0..$i) {	
          $k++;
          $hh=2.0;
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          $faab[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
          $fabb[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
	    }
      }		
      for $i (0..$Ialpha1-1) {
        for $j ($Ialpha1..$lmo) {
          $k++;
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $AOM[$jk]->[$k]*$AOM[$kl]->[$k];   
	    }
      }		
      for $i ($Ialpha1..$lmo) {
        for $j ($Ialpha1..$i) {	
          $k++;
          $hh=2.0;
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
	    }
      }	
    }
    if ($LogQ[1]) {
      for $i (0..$NFbeta-1) {
        for $j (0..$i) {	  
          $k++;
          $hh=2.0;
          $hh=1.0 if ($i==$j);	
  	      $anmin = sqrt($po[$i]*$po[$j]);
          $faaa[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }	
      for $i ($NFbeta..$lmo) {
        for $j ($NFbeta..$i) {	  
          $hh=2.0;
          $hh=1.0 if ($i==$j);	
  	      $k=($i*($i+1))/2+$j;
          $anmin = sqrt($po[$i]*$po[$j]);
          $faab[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $fabb[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }	
    }

    $faba[$jk][$kl]*= 2.0;
    $fabb[$jk][$kl]*= 2.0;
    $deloc[$jk][$kl] = $faba[$jk][$kl]+$fabb[$jk][$kl] if($jk != $kl);
    $vloc[$kl]= -$faaa[$kl]-$faab[$kl];  	
  }
}

for  $jk (0..$KAt) {
  $j=0;
  $AN[$jk]=0;
  $BN[$jk]=0;
  if ($LogQ[0] or $LogQ[2]) {
    for $i (0..$lmo) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    $AN[$jk]=0.5*$AN[$jk];
    $BN[$jk]=0.5*$BN[$jk];
  }
  if ($LogQ[3]) { 
    for $i (0..$Ialpha1-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    for $i (0..$lmo-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
  }

  if ($LogQ[1]) { 
    for $i (0..$NFbeta-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    for $i ($NFbeta..$lmo) {
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
  } 
}


open OUT, ">$seed.din";

for $jk (0..$KAt) {
  for $kl ($jk+1..$KAt) {
    print OUT "*** DELOCALIZATION and LOCALIZATION INDEXES FOR ATOMS A and B: $AtName[$jk]$NumAt[$jk] and $AtName[$kl]$NumAt[$kl]\n";
        printf OUT "ALPHA ELECTRONS                %22.14f\n", $AN[$jk];
        printf OUT "BETA ELECTRONS                 %22.14f\n", $BN[$jk];
        printf OUT "TOTAL ELECTRONs                %22.14f\n", $BN[$jk]+$AN[$jk];
        printf OUT "SPIN DENSITY                   %22.14f\n", $BN[$jk]-$AN[$jk];
        printf OUT "DELOCALIZATION INDEX           %22.14f\n", $deloc[$jk][$kl];
        printf OUT "DELOCALIZATION INDEX ALPHA     %22.14f\n", $faba[$jk][$kl];
        printf OUT "DELOCALIZATION INDEX BETA      %22.14f\n", $fabb[$jk][$kl];
        printf OUT "LOCALIZATION INDEX OF ATOM A   %22.14f\n", $vloc[$jk];
        printf OUT "LOCALIZATION INDEX OF ATOM B   %22.14f\n", $vloc[$kl];
        printf OUT "ALPHA FERMI CORRELATION OF A   %22.14f\n", $faaa[$jk];
        printf OUT "ALPHA FERMI CORRELATION OF B   %22.14f\n\n", $faaa[$kl];
  }
}

open SPD, ">$seed.spinden";
for $jk (0..$KAt) {
  printf  SPD " % 8s  % 10.6f % 10.6f % 8.4f\n", "$AtName[$jk]$NumAt[$jk]", $AN[$jk], $BN[$jk], abs($BN[$jk]-$AN[$jk]);
}

close SPD;


%sref=
("CC", 1.389,
 "CN", 1.318,
 "NC", 1.318,
 "NN", 1.518,
 "CO", 0.970,
 "OC", 0.970);

print "\n"; foreach $i (0..$#AtName) {print "$AtName[$i]$NumAt[$i] "}; print "\n";

shift(@ARGV);
print "Insert the atom numbers corresponding to the ring (spaced):" if (scalar(@ARGV) <1);
$_ = <STDIN> if (scalar(@ARGV) <1);
@_= @ARGV if (scalar(@ARGV) >1);
@_=split if (scalar(@ARGV) <1);


$NRing = scalar (@_)-1;

#
#$MCI= 0.0;
#

$perm = new List::Permutor @_[0..$NRing-1];

$i = 0;

#while (@set = $perm->next) {
#    print "One order is @set.\n";
#    $i++; 
#}

@set = @_[0..$NRing-1];
print "iring\n";
@it =();
$A = 0.0;
iring(0);

sub max ($$) { $_[$_[0] < $_[1]] }
sub min ($$) { $_[$_[0] > $_[1]] }


sub iring() {
  $coff = 0.01;
  my ($k) = @_;
  for ($it[$k]=0; $it[$k]<$lmo; $it[$k]++) {
    my $f = $k;
    if ($f != 0) {
      next if ( abs($S[$it[$f]][$it[$f-1]][$set[$f]]) < $coff);
    }  
    iring($f+1) if ($f < $NRing-1);
    if (($f == $NRing-1) and (abs($S[$it[0]][$it[-1]][$set[0]]) > $coff)){
      $B = $S[$it[0]][$it[-1]][$set[0]];

      for my $i (1..$NRing-1) {
        $B*= $S[$it[$i]][$it[$i-1]][$set[$i]];
      }
      $A += $B;
      for my $i (0..$NRing-1) { printf "% 3s ",$it[$i]  };
      printf " A = % .5e and   % .5e  \n", $A, $B;
    }
  }
}  


