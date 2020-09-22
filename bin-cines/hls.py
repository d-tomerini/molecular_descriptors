#!/usr/bin/python

import openbabel as ob
import sys, glob

# First one is the string contained in the starting molecule
# Second one in the reduced state

ne =sys.argv[1]
red=sys.argv[2]
all = glob.glob("*" + ne + ".log")

mlen = str(len(max(all, key=len)) - len(ne))+"s"
fn="8"
dig=".3"
nfor = "< "+fn+dig+"f"
sfor = "<"+fn+"s"

print "system: ", ne
print "{0:{6}} {1:{7}} {2:{7}} {3:{7}} {4:{7}} {5:{7}} {8:{7}} {9:{7}}".format(
"system", " pot", " homo", " lumo", " somo", " phi",  mlen, sfor, " MolWT", " E.den")
for file in sorted(all):
    ao =-1000
    av = 1000
    bo =-1000
    bv = 1000
    pss =1
    pssb=1
    found1=0
    found2=0
    pot1 =0
    pot2 =0
    homo =0
    lumo=0
    mol = ob.OBMol()
    xx = ob.OBConversion()
    xx.SetInFormat("g09")
    xx.ReadFile(mol, file)

    try :
      with open(file, "r") as f:
        for line in f:
            if "Alpha  occ" in line:
                x =line
                pss=1
            if "Alpha virt" in line and pss:
                ao = float(x.split()[-1])
                av = float(line.split()[-5])
                pss=0
            if "Beta  occ" in line:
                x =line
                pssb=1
            if "Beta virt" in line and pssb:
                bo = float(x.split()[-1])
                bv = float(line.split()[-5])
                pssb=0
            if "Sum of electronic and thermal Free Energies" in line:
                pot1 = float(line.split()[-1])
                found1 = 1
      f.close()
    except IOError:
      pass
    file = file.replace(ne + ".log", red + ".log")
    sa = -1000
    sb = -1000
    somo = 0
    try:
      with open(file, "r") as f:
        for line in f:
            if "Alpha  occ" in line:
                x =line
            if "Alpha virt" in line:
                sa = float(x.split()[-1])
            if "Beta  occ" in line:
                x =line
            if "Beta virt" in line:
                sb = float(x.split()[-1])
            if "Sum of electronic and thermal Free Energies" in line:
                pot2 = float(line.split()[-1])
                found2 = 1
      f.close()
    except IOError:
      pass

    print "{0:{1}}".format(file.replace(red + ".log",""), mlen),
    if (found1 and found2):
        pot = (pot1 - pot2)*27.211396 - 1.46
        print "{0:{1}}".format(pot, nfor) ,
    else:
        print "{0:{1}}".format(" x"+ str(found1) + "-" + str(found2) + "x", sfor) ,
    homo = max(ao, bo)
    lumo = min(av, bv)
    somo = max(sa, sb)
    if homo != lumo :
        ei = (1/4.0)*(homo + lumo)*(homo+ lumo)/(lumo- homo)
    if homo !=-1000:
        print "{0:{2}} {1:{2}}".format(homo, lumo, nfor) ,
    if somo !=-1000 :
        print "{0:{2}} {1:{2}}".format(somo, ei, nfor) ,
    if somo ==-1000 :
        print "{0:{3}} {1:{2}}".format(" xxx ", ei, nfor, sfor) ,
    print "{0:{1}}".format(mol.GetMolWt(), nfor),
    if (found1 and found2):
        print "{0:{1}}".format(pot*1000/mol.GetMolWt()*26.8, nfor),
    print
