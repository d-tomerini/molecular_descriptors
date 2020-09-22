#!/usr/bin/python

import pybel, openbabel, glob, sys, os

lis = sys.argv
lis.pop(0)

for x in sorted(lis):
    for mol in pybel.readfile("g09", x):
     for ring in  mol.sssr:
        homaring = "HOMA.pl "
        fluring = "FLU.pl "
        homaring+=  x
        fluring +=  x

#        for ring in mol.sssr:
        for atom in list(ring._path):
                homaring += " " + str(atom)
                fluring  += " " + str(atom)
        print homaring +  " " + str(ring._path[0])
        os.system(homaring +  " " + str(ring._path[0]) )
        os.system(fluring +  " " + str(ring._path[0]) )

