#!/usr/bin/python
import openbabel as ob
import sys, glob

# First one is the string contained in the starting molecule
# Second one in the reduced state


all = sys.argv
all.pop(0)

for file in sorted(all):
    mol = ob.OBMol()
    xx = ob.OBConversion()
    xx.SetInFormat("g09")
    xx.SetOutFormat("xyz")
    xx.ReadFile(mol, file)
    xx.WriteFile(mol, "file"+".xyz")
    #ff = ob.OBForceField.FindForceField("UFF")
    #ff.Setup(mol)
    #kk = ff.SystematicRotorSearch(0)
    print "cao", mol.NumConformers()
    #print kk
    #print ff.Energy()
    Final= ob.OBMol()
    ph = mol.GetConformer(1)
    print mol.data.keys()
    print ph
    xx.WriteFile(ph[0], "file2"+".xyz")


