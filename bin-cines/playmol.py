#!/usr/bin/python

import openbabel as ob
import numpy as np, sys, os

lis = sys.argv
lis.pop(0)

for molname in sorted(lis):
    mol = ob.OBMol()
    xx = ob.OBConversion()
    xx.SetInFormat("g09")
    xx.SetOutFormat("com")
    xx.ReadFile(mol, molname)
    seed = molname.strip(".log")
    print molname,

    patterns= {
    "-H-"   :   "[H]",
    "-F-"   :   "F",
    "-Cl-"  :   "Cl",
    "-Br-"  :   "Br",
    "-NO2-" :   "N(=O)=O",
    "-NH2-" :   "[NH2]",
    "-OH-"  :   "O",
    "-Ac-"  :   "C(=O)[CH3]",
    "-Me-"  :   "[CH3]",
    "-MeOH-":   "CO",
    "-CN-"  :   "C#N",
    "-NCH32-":  "N([CH3])[CH3]",
    "-CF3-" :   "C(F)(F)F",
    "-COF-" :   "C(=O)F",
    "-COCl-":   "C(=O)Cl",
    "-CHO-" :   "[CH]=O",
    "-OCH3-":   "O[CH3]",
    "-NF2-" :   "N(F)F",
    "-COOMe-":  "C(=O)O[CH3]",
    "-COOH-":   "C(=O)[OH]"
    }

    for key in patterns.keys():
        if key in molname:
            pattern = "C"+patterns[key]
            spat = patterns[key]
    obpat = ob.OBSmartsPattern()
    obpat.Init(pattern)
    obpat.Match(mol)

    # avoid getting lots of <openbabel.vectorvInt; proxy ... > etc.
    matches = [m for m in obpat.GetUMapList()]
    for i in matches:
        z = mol.DeleteBond(mol.GetBond(mol.GetAtom(i[0]),mol.GetAtom(i[1])))

    frags = mol.Separate()
    tocom = [""]

    print "There are ",len(frags), "fragments", mol.GetTotalCharge(), mol.GetTotalSpinMultiplicity()
    for frag in frags:
        tocom.append("")
        print frag.NumAtoms(), len(frags)
        for atom in ob.OBMolAtomIter(frag):
            AtS = ob.etab.GetSymbol(atom.GetAtomicNum())
            tocom[0]  += AtS + " {0:.6f}  {1:.6f}  {2:.6f}\n".format(atom.GetX(), atom.GetY(), atom.GetZ())
            tocom[-1] += AtS + " {0:.6f}  {1:.6f}  {2:.6f}\n".format(atom.GetX(), atom.GetY(), atom.GetZ())

    obpat = ob.OBSmartsPattern()
    obpat.Init(spat)
    for i in range(0, len(tocom)):
        f = open("Fragments/frag" + str(i) + "_" + seed + ".com", "w+")
        f.write(
"""%mem=9600Mb
NProcShared=8
#P B3LYP/6-31+G(d,p) pop=full int=(grid=ultrafine)
SCRF(SMD,Solvent=generic,Read)
nosymm IOP(3/33=1,3/32=2)

fragment """ + str(i) + "\n\n")
        if (i == 0): f.write("0 1")
            # f.write(str(mol.GetTotalCharge()) + " " + str(mol.GetTotalSpinMultiplicity()) )
        else:
            print "caocao", obpat.Match(frags[i-1])
            if obpat.Match(frags[i-1]):
                f.write("0 2")
                "found sub"
            else:
                print "cao", len(frags) % 2
                if (len(frags) % 2) == 0 :
                    f.write("0 2")
                    print "not sub", len(frags),
                else:
                    f.write("0 1")
                    print "not sub", len(frags), frag.NumAtoms()
        f.write("\n" + tocom[i])
        f.write("""
EpsInf=2.014
HBondAcidity=0.0
HBondBasicity=0.379
SurfaceTensionAtInterface=59.59
Eps=89.78
CarbonAromaticity=0.0
ElectronegativeHalogenicity=0.0

""")
        f.close()

os.chdir("Fragments")
os.system("topbs.pl *com")
