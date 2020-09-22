#!/usr/bin/perl -w

system("ls -d */ > xxx");
open X, "xxx";
@dirs = <X>;
chomp(@dirs);
chop(@dirs);
close X;
unlink "xxx";
print "directories: @dirs \n";

foreach $file (@dirs) {
  print "processing  $file\n";
  chdir("$file");
  $mynum = $file;
  $mynum =~ s/\D//g;
  print "atom $mynum\n";
  system ("mv *.inaim $file.inaim");
  system ("mv *.struct $file.struct");
  system ("mv *.clmsum $file.clmsum");

 open FF, "$file.inaim";
 @newF = <FF>;
 $newF[1]= "$mynum\n";
 close FF;
 open FF, ">$file.inaim";
 print FF @newF;
 chdir('../');
}


