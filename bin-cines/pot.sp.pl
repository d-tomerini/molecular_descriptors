#!/usr/bin/perl

for $x (@ARGV) {
    $x =~ s/.log//g;
    $Eel1 = GetInfo("SCF Done", "$x.log", -5);
    $ThCorr1 =  GetInfo( 'Thermal correction to Gibbs Free Energy', "$x.log", -1);
    $ZPE1 =  GetInfo( 'Zero-point correction',  "$x.log", -2);
    $Eelmore1 = GetInfo("SCF Done", "SinglePoint/$x.log", -5);
    $Eel2 = GetInfo("SCF Done", "$x-.log", -5);
    $ThCorr2 =  GetInfo( 'Thermal correction to Gibbs Free Energy', "$x-.log", -1);
    $ZPE2 =  GetInfo( 'Zero-point correction',  "$x-.log", -2);
    $Eelmore2 = GetInfo("SCF Done", "SinglePoint/$x-.log", -5);
    $pot = ($Eelmore1 + $ThCorr1 + $ZPE1 - $Eelmore2-  $ThCorr2 - $ZPE2)*27.211396132 - 1.46-0.0339107;
    print "$x $pot\n";
    
 
}




sub GetInfo{
    ($what, $file, $where) = @_;
    open S , "grep '$what' $file |";
    @all = <S>;
    $_ = @all[-1];
    @app = split;
    return $app[$where];
    close S;
}
