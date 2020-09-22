#!/usr/bin/perl


$dir = "$ENV{'HOME'}/bin/data";
$xxx1 = "$dir/com.opt.1";
$xxx2 = "$dir/com.opt.2";

if (defined($ARGV[0])) {
  $i2 = $ARGV[0];
  $i2 =~ s/.smi//g;
  $i1=$ARGV[1];
  open S, $ARGV[0] or die "no such file";
  $_ = <S>;
  @x = split;
  $str = $x[0];
  print "\ndealing with file $i2\nsmile $str\nposition $i1\n ";
} else {
  $i2 = "";
  $i1 = "";
  $str = "";
}


%subs=
(
"N3", "(N=[N+]=[N-])",
"ONO2", "(ON(=O)=O)",
"SO3", "(S(=O)(=O)[O])",
"TBu", "(C(C)(C)C)",
"SO2F", "(S(=O)(=O)F)" 
);

# The more, the merrier


# SMILES string for the molecule. X where to attach the substituents
# Instead of O-Li-O, use O-S-O. For some reason babel process them better

foreach my $k ( keys %subs) {
  $i = $subs{$k};
  $x = $str;
  $x =~ s/(X)/$i/g;

  print  "obabel -:\"$x\" -O $i1-$k-$i2.com --gen3D\n";
  system("obabel -:\"$x\" -O $i1-$k-$i2.xyz --gen3D");

  system("cp $i1-$k-$i2.xyz $i1-$k-$i2");
  system("sed '1,2d' $i1-$k-$i2.xyz > $i1-$k-$i2");
#  system("perl -p -i -e \"s/S /Li/g\"  $i1-$k-$i2");

  system("cat $xxx1 $i1-$k-$i2 $xxx2 > $i1-$k-$i2.com");
  system("perl -p -i -e \"s/xxx/$i1-$k-$i2/g\"  $i1-$k-$i2.com");
  system("rm $i1-$k-$i2");
}


