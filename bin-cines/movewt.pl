#!/usr/bin/perl

@x = glob("*log");
print "***\n  warning: no 'wellterminated' folder\n\***\n" unless (-e "wellterminated");

foreach $x (@x) {
  $x =~ s/.log//g;
  {
    local $/=undef;
    open A, "tail -n 4 $x.log |";
    $_ = <A>;
    close A;
  }  
  if (/termination/){ 
  if (/Normal termination/){
    next unless  (-e "wellterminated");
    print "Moving $x ...\n";  
    system ("mv $x.com wellterminated/.") ;
    system ("mv $x.chk wellterminated/.") ;
    system ("mv $x.log wellterminated/.") ;
    system ("mv $x.wfn wellterminated/.") ;
  } 
  else {
    if ($ARGV[0] eq "restart") {
      {
        local $/=undef;
        open F, "grep termination $x.log |" ;
        $test = <F>;
        close F;
      }
      open G, "$x.com" ; 
      $newcom="";
      if (index($test, "Normal") != -1) {
        print "  restarting partially converged $x\n";
        system ("mv $x.log $x.lognosolv");
        while (<G>) {
          if (/link1/){
            while (<G>) {
              $newcom="$newcom$_";
            }
          }
        }
      } else {
        print "restarting  $x\n";
        $a="";
        do {
          $newcom="$newcom$a";
          $a=<G>;
        } while ($a ne "\n");
        $newcom=$newcom."    geom=check guess=read\n"  unless (index($newcom, "geom=check") != -1);
        $newcom=$newcom."\n";
        $a=<G>; $newcom="$newcom$a";
        $a=<G>; $newcom="$newcom$a";
        $a=<G>; $newcom="$newcom$a";
        
        do {
          $a=<G>;
        } while (($a ne "\n") and (<G>));

        $newcom="$newcom\n";
        while (<G>) {
          $newcom="$newcom$_";
        }; 
      }
      close G;
      open G, ">$x.com";
      print G "$newcom" ;
      close G;
      system("topbs.pl $x.com");
    }
  }  
  }  
}

 

