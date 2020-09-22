#!/usr/bin/python

import openbabel as ob
import numpy as np
import os, sys, subprocess, glob


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
#    "-NF2-" :   "N(F)F",
    "-COOMe-":  "C(=O)O[CH3]",
    "-N3-":     "(NNN)",
    "-ONO2-":   "(ON(=O)=O)",
    "-SO3-":    "(S(=O)(=O)[O])",
    "-TBu-":    "(C(C)(C)C)",
    "-SO2F-":   "(S(=O)(=O)F)",
    "-POF2-":   "(P(=O)(F)F)",
    "-BOH3-":   "([B-](O)(O)O)",
    "-SO2CN-":  "(S(=O)(=O)C#N)",
    "-SO2CF3-": "(S(=O)(=O)C(F)(F)F)",
    "-OCN-":    "(OC#N)",
    "-SCN-":    "(SC#N)",
    "-COO--":    "(C(=O)[O-])",
    "-MeO--":    "(C[O-])",
    "-O--":    "([O-])",
    }

order= {
    "-H-"   :   22,
    "-F-"   :   18,
    "-Cl-"  :   16,
    "-Br-"  :   17,
    "-NO2-" :   5,
    "-NH2-" :   27,
    "-OH-"  :   21,
    "-Ac-"  :   14,
    "-Me-"  :   24,
    "-MeOH-":   20,
    "-CN-"  :   7,
    "-NCH32-":  28,
    "-CF3-" :   12,
    "-COF-" :   8,
    "-COCl-":   6,
    "-CHO-" :   13,
    "-OCH3-":   26,
    "-COOMe-":  15,
    "-N3-":     19,
    "-ONO2-":   11,
    "-SO3-":    23,
    "-TBu-":    25,
    "-SO2F-":   2,
    "-POF2-":   4,
    "-BOH3-":   29,
    "-SO2CN-":  1,
    "-SO2CF3-": 3,
    "-OCN-":    9,
    "-SCN-":    10,
    "-COO--":    100,
    "-MeO--":    101,
    "-O--":      102,
    }

name= {
    "-H-"   :   "H",
    "-F-"   :   "F",
    "-Cl-"  :   "Cl",
    "-Br-"  :   "Br",
    "-NO2-" :   "NO\-(2)",
    "-NH2-" :   "NH\-(2)",
    "-OH-"  :   "OH",
    "-Ac-"  :   "COMe",
    "-Me-"  :   "Me",
    "-MeOH-":   "MeOH",
    "-CN-"  :   "CN",
    "-NCH32-":  "NMe\-(2)",
    "-CF3-" :   "CF\-(3)",
    "-COF-" :   "COF",
    "-COCl-":   "COCl",
    "-CHO-" :   "CHO",
    "-OCH3-":   "OMe",
    "-COOMe-":  "COOMe",
    "-N3-":     "N\-(3)",
    "-ONO2-":   "ONO\-(2)",
    "-SO3-":    "SO\-(3)",
    "-TBu-":    "TBu",
    "-SO2F-":   "SO\-(2)F",
    "-POF2-":   "POF\-(2)",
    "-BOH3-":   "B(OH)-(3)",
    "-SO2CN-":  "SO\-(2)CN",
    "-SO2CF3-": "SO\-(2)CF\-(3)",
    "-OCN-":    "OCN",
    "-SCN-":    "SCN",
    "-COO--":    "COO\+(-)",
    "-MeO--":    "MeO\+(-)",
    "-O--":    "O\+(-)",
    }


allfiles = sys.argv


allfiles.pop(0)

allresults = dict((i,[i, i, order[i], name[i]]) for i in patterns.keys())
legend = ["Name", "Substituent", "Order", "Origin Name"]
legend.extend(["Reduction potential", "HOMO", "LUMO", "Gap", "SOMO", "Electrophilicity", "Molecular weight", "Energy density"])

firstmol = True

for file in sorted(allfiles):
    sub = "xxx"
    seed = file.strip(".log")
    print "dealing with ", seed
    for i in patterns.keys():
        if i in file :
            sub = i
            allresults[sub][0] = seed
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
    except IOError: pass
    file_r = seed + "-.log"
    sa = -1000
    sb = -1000
    somo = 0
    try:
      with open(file_r, "r") as f:
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

    allresults[sub].append('')
    if (found1 and found2):
        pot =  (pot1 - pot2)*27.211396 - 1.46
        allresults[sub][-1] = pot
    homo = max(ao, bo)
    lumo = min(av, bv)
    somo = max(sa, sb)
    if homo != lumo :
        ei = (1/4.0)*(homo + lumo)*(homo+ lumo)/(lumo- homo)
    allresults[sub].append('')
    if homo !=-1000:
        allresults[sub][-1] =homo
    allresults[sub].append('')
    if lumo !=-1000:
        allresults[sub][-1] =lumo
    allresults[sub].append('')
    if homo !=-1000:
        allresults[sub][-1] = lumo - homo
    allresults[sub].append('')
    if somo !=-1000:
        allresults[sub][-1] =somo
    allresults[sub].append('')
    if homo !=-1000  :
        allresults[sub][-1] = ei

    mol = ob.OBMol()
    xx = ob.OBConversion()
    xx.SetInFormat("g09")
    xx.ReadFile(mol, seed + ".log")

    allresults[sub].append(mol.GetMolWt())
    allresults[sub].append('')
    if (found1 and found2):
         allresults[sub][-1] = pot*1000/mol.GetMolWt()*26.8


for key, value in allresults.iteritems() :
    answ = [str(i) for i in value]
    print " , ".join(answ)

