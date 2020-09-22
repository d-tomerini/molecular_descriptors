#!/usr/bin/perl
  
  open S, ">Charges";
  open Y, ">SpinDen";
  open Z, ">Fuk+";
  open W, ">Fuk-";
  open R, ">FukDual";
  foreach $x (@ARGV) {
   @at = "";
   @ch="";
   open X,"$x" or die;
   $x =~ s/.log//g;
   while (<X>) {
    if (/Hirshfeld populations/) {
     $_= <X>; $_= <X>;
     $i=0;
     do {
        @k = split;
        $at[$i]= $k[1] ;
        $fa0[$i]= $k[3] ;
        $fb0[$i]= $k[4] ;
        $sd0[$i]= $fa0[$i]- $fb0[$i];
        $i++;
        $_= <X>;
     } while (not /Tot/);
    }
    if (/Hirshfeld spin densities, charge/) {
      $_= <X>;$_= <X>;
      $i=0;
      do {
        @k = split;
        $ch[$i] = $k[3];
        $i++;
        $_= <X>;
      } while (not /Tot/);
    }
   }  
   close X;
   open X,"$x"."-fk+.log"  ;
   while (<X>) {
    if (/Hirshfeld populations /) {
      $_= <X>;$_= <X>;
      $i=0;
      do {
        @k = split;
        $fa1[$i]= $k[3] ;
        $fb1[$i]= $k[4] ;
        $sd1[$i]= $fa1[$i]- $fb1[$i];
        $i++;
        $_= <X>;
      } while (not /Tot/)
     }
    }
    
    close X;
    open X,"$x"."-fk-.log" ;
    while (<X>) {
     if (/Hirshfeld populations /) {
      $_= <X>;$_= <X>;
      $i=0;
      do{
        @k = split;
        $fa2[$i]= $k[3] ;
        $fb2[$i]= $k[4] ;
        $sd2[$i]= $fa2[$i]- $fb2[$i];
        $i++;
        $_= <X>;
      } while (not /Tot/);
     }
    }
    close X;

    print S "$x  ";
    foreach $i (@ch){ printf S "% 7.3f ",$i ;} print S"\n";
    print Y "$x  ";
    foreach $i (@sd0){ printf Y "% 7.3f ",$i ;} print Y"\n";
    print Z "$x  ";
    for $i (0..$#ch) { printf Z "% 7.3f ",($fa0[$i]+$fb0[$i] - $fa1[$i]- $fb1[$i]);} print Z"\n";
    print W "$x  ";
    for $i (0..$#ch){ printf W "% 7.3f ",($fa2[$i]+$fb2[$i] - $fa0[$i]- $fb0[$i]);} print W"\n";    
    print R "$x  ";
    for $i (0..$#ch){ printf R "% 7.3f ",-(2*$fa0[$i]+2*$fb0[$i] - $fa2[$i]- $fb2[$i] -  $fa1[$i]- $fb1[$i])/2;} print R"\n";


    foreach $i (0..$#at){
        open F, "grep 'ALPHA ELECTRONS' di-$x/$x-$i.int |";
        $_ = <F>;
        @a = split;
        $alphbad[$i] = @a[-1];
        close F;
        open F, "grep 'BETA ELECTRONS' di-$x/$x-$i.int |";
        $_ = <F>;
        @a = split;
        $betabad[$i] = @a[-1];
        close F;
        open F, "grep 'NET CHARGE' di-$x/$x-$i.int |";
        $_ = <F>;
        @a = split;
        $chargebad[$i] = @a[-1];
        $spbad[$i] = $alphbad[$i] - $betabad[$i];
        print "cao $spbad[$i] $alphbad[$i] $betabad[$i]\n";
        close F;
    }
      
    foreach $i (0..$#at){  print  "$at[$i]", $i+1, " "} print "\n";
    foreach $i (@ch){  printf  "% 7.3f ",$i } print "\n";
    foreach $i (@sd0){ printf  "% 7.3f ",$i ;} print "\n";
    for $i (0..$#at){ 
        $fkdual[$i] = -(2*$fa0[$i]+2*$fb0[$i] - $fa2[$i]- $fb2[$i] -  $fa1[$i]- $fb1[$i])/2;
        printf  "% 7.3f ", $fkdual[$i]
    } print "\n";
    $dir = "file:///C:/Users/Tomerini/Documents/Quinones-article/figures/procs/$x.cubes";
    $toplot = ""; 
    $surface = "isosurface sign aquamarine coral color translucent cutoff 0.05 ";

    open XXX, ">$x.fkdual.jmol";
    print XXX " load \"$dir/$x.log\"; model last; $surface \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.2f ; ",  $fkdual[$i]*100 } print XXX "\n";
    close XXX;
    open XXX, ">$x.charge.jmol";
    print XXX " load \"$dir/$x.log\"; model last; $surface \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.2f ; ", $ch[$i] } print XXX "\n";
    close XXX;


#    open XXX, ">$x.sd.jmol";
#    print XXX " load  \"$dir/$x.log\" ; model last; isosurface sign aquamarine coral color translucent cutoff 0.05   \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
#    foreach $i (0..$#at) { 
#      printf XXX "select $at[$i]%i; label \"% 5.2f |<color red>% 5.3f\"; ", $i+1, $sd0[$i]*100, $ch[$i] } ; 
#      print XXX " select all; set labelfront on ;\n";


   open XXX, ">$x.sd.jmol";
    print XXX " load  \"$dir/$x.log\" ; model last; $surface  \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) {
      printf XXX "select $at[$i]%i; label % 5.2f ; ", $i+1, $sd0[$i]*100, } ;
      print XXX " select all; set labelfront on ;\n";

    open XXX, ">$x.baderch.jmol";
    print XXX " load \"$dir/$x.log\"; model last;  color background white; select all; color label black; font label 22 monospaced ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.2f ; ", $chargebad[$i] } print XXX "\n";
    close XXX;

    open XXX, ">$x.baderspinden.jmol";
    print XXX " load \"$dir/$x.log\"; model last;  color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.2f ; ", $spbad[$i]*100 } print XXX "\n";
    close XXX;



   }

    
