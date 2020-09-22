#!/usr/bin/python
import pybel, openbabel, glob, sys, os

lis = sys.argv
lis.pop(0)

for x in sorted(lis):
    seed = x.strip(".log")
    dir = "di-" + seed + "/"
    di_list = []
    alldi = len(glob.glob("di-" + seed + "/*.int"))
    print alldi, " atoms"
    virial = []
    EAtom = []
    for i in range(0,alldi):
        virial.append("0")
        EAtom.append("0")
        f = open(dir + seed + "-" + str(i) + ".int", 'r')
        for line in f:
            if '-V/T' in line : virial[-1] = line.split()[-1]
            if '   K  ' in line : EAtom[-1] = line.split()[-1]
    dir = "di-" + seed + "-/"
    atomtype = []
    virialred = []
    EAtomred = []
    for i in range(0,alldi):
        f = open(dir +seed  + "--" + str(i) + ".int", 'r')
        atomtype.append("")
        virialred.append("0")
        EAtomred.append("0")
        for line in f:
            if 'INTEGRATION IS OVER ATOM' in line : atomtype[-1] = line.split()[-2] + line.split()[-1]
            if '-V/T' in line : virialred[-1] = line.split()[-1]
            if '   K  ' in line : EAtomred[-1] = line.split()[-1]
    for i in range(0,alldi):
        print "{0} {1:f} {2:f} {3:f}".format(atomtype[i], float(EAtom[i]), float(EAtomred[i]), float(EAtom[i]) - float(EAtomred[i]))


