#!/usr/bin/python

import openbabel as ob, glob, sys, os, math

lis = sys.argv
lis.pop(0)


for x in sorted(lis):
   mol = ob.OBMol()
   xx = ob.OBConversion()
   xx.SetInFormat("g09")
   xx.ReadFile(mol, x)
   fname = x.strip(".log") + ".bcrt"
   print x
   try:
    with open(fname) as f: content = f.readlines()
    for ring in  mol.GetSSSR():
        atx = []
        atn = []
        code= []
        for atom in list(ring._path):
            atn.append(atom)
            atx.append(ob.etab.GetSymbol(mol.GetAtom(atom).GetAtomicNum()))
        for i in range(0,len(atn)):
            if atn[i] < atn[i-1]: code.append(atx[i] + str(atn[i]) + "-" + atx[i-1] + str(atn[i-1]))
            else: code.append(atx[i-1] + str(atn[i-1]) + "-" + atx[i] + str(atn[i]))
        SA = 0.0
        Tot = 0.0
        rhos = []
        for item in code:
            for line in content:
                if item in line:
                    rho =  float(line.split()[5])
                    SA += rho * math.log(rho)
                    Tot += rho
                    rhos.append(rho)
        print "ring ", atn, "{0:{1}}".format(SA/Tot +  math.log(len(code)) - math.log(Tot),".6f" )
        sha = 0.0
#        for y in rhos:
#            sha += y/Tot *  math.log(y/Tot)
#        print math.log(len(code)) + sha
   except IOError: print "file", fname, "does not exist"

