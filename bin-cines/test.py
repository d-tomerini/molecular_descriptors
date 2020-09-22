#!/usr/bin/python

import openbabel as ob
import sys, glob, os
import numpy as np


lis = sys.argv
lis.pop(0)

mol = ob.OBMol()
xx = ob.OBConversion()

print lis,

xx.SetInFormat("g09")

for x in sorted(lis):
    seed = x.strip(".log")
    x = xx.ReadFile(mol, x)
    print x
    f = open("NICS/" + seed  + ".NICS.com", "w")
    f.write("""%Mem=9600Mb
%NProcShared=8
#P  B3LYP/6-31+G(d,p)
    NMR Int=(Grid=UltraFine)
    pop=hirshfeld
    gfinput iop(6/7=3) pop=full NoSym

""")
    f.close()
    ring = mol.GetSSSR()
    ratom = np.array
    yy = np.array([0.0, 0.0, 0.0])
    for at in sorted(ring[0]._path):
        print   at-1, mol.Atom()[at-1].coords,"x", mol.Atoms()[at-1].AtomicNum(), "x"
        for i in (0,2):
            yy[i] +=  np.array(mol.atoms[at-1].coords[i])
    print "\n", mol.spin, mol.title, mol.charge, "coccobao"
    yy /= len(ring._path)
    print x, list(sorted(ring._path))
    xx = []
    print xx
    bq1 = mol.OBMol.NewAtom()
    bq1.SetAtomicNum(0 )
    bq1.SetVector(yy[0], yy[1],yy[2])
    pvec1 = np.array(mol.atoms[ring._path[0]].coords) - np.array(mol.atoms[ring._path[1]].coords)
    pvec2 = np.array(mol.atoms[ring._path[1]].coords) - np.array(mol.atoms[ring._path[2]].coords)
    orth = np.cross(pvec1, pvec2)
    orth /=  np.linalg.norm(orth)
    zz = yy+orth
    bq2 = mol.OBMol.NewAtom()
    bq2.SetVector(zz[0], zz[1], zz[2])
    bq2.SetAtomicNum(0)
    mol.write("gjf", "NICS/" +seed +".xyz", overwrite = True)
    os.system("sed '1,2d' NICS/" + seed + ".xyz >> NICS/" + seed  + ".NICS.com" )
    os.system("perl -p -i -e 's/Xx/Bq/g'  NICS/" + seed  + ".NICS.com")
    os.chdir("NICS")
    os.system("topbs.pl " + seed  + ".NICS.com")
    os.chdir("../")



