#!/usr/bin/perl

$dir = "$ENV{'HOME'}/bin/data";

$how = $ARGV[0];
shift @ARGV;
if ($how eq "nosolvent") {$file = "$dir/com.singlepoint.1"}
    else {if ($how eq "solvent") {$file = "$dir/com.singlepoint.2"}
    else {die "specify solvent/nosolvent as option"}}; 

foreach $x (@ARGV) { 
        print "Processing $x...\n";
        open CH, "grep  'Charge =' $x | " ;
        $_ = <CH>;
        @ch = split;
        $chmul = "$ch[-4] $ch[-1]";
        
        $x =~ s/.log//g;


        system("sed -e \"s/xxx/$x/ig\" $file > SinglePoint/$x.com");
        system("sed -i 's/chargedensity/$chmul/g'  SinglePoint/$x.com");
        if ($how eq "nosolvent") {
            open LOG, "$x.log";

            while (<LOG>) {
                if (/GINC/) {
                    $summary="";
                    while (index($summary, '\\\@') == -1) {
                    $_ =~ s/^\s+|\s+$//g;
                    $summary .= $_;
                    $_ = <LOG>;
                }
            }
            @all = split (/\\\\/ ,$summary);
            $myinp = $all[3];
            @geometry = split (/\\/ ,$all[3]);


            system("sed '1,2d' $x.xyz > SinglePoint/$x");
            system("cat SinglePoint/$x.com SinglePoint/$x > $x");
            
            system("mv $x SinglePoint/$x.com");
            open S, ">>SinglePoint/$x.com";
            print S "\n\n";
            close S;
            unlink "SinglePoint/$x";
        }
        chdir "SinglePoint";
  #      system("topbs.pl $x.com");
        chdir "../"; 
}

