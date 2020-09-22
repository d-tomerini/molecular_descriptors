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
    "-SCN-":    "(SC#N)"
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
    "-SCN-":    10
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
    "-SO3-":    "SO\-(3)\+(-)",
    "-TBu-":    "TBu",
    "-SO2F-":   "SO\-(2)F",
    "-POF2-":   "POF\-(2)",
    "-BOH3-":   "B(OH)-(3)",
    "-SO2CN-":  "SO\-(2)CN",
    "-SO2CF3-": "SO\-(2)CF\-(3)",
    "-OCN-":    "OCN",
    "-SCN-":    "SCN"
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

    homaring = "homar.pl"
    fluring = "FLUring.pl"
    shannon = "Shannon.py"
    rings = []
    rnum = 1
    sh= subprocess.Popen([shannon, seed + ".log"], stdout=subprocess.PIPE).stdout.read().split()
    sh1 = subprocess.Popen([shannon, seed + "-.log"], stdout=subprocess.PIPE).stdout.read().split()
    for ring in  mol.GetSSSR():
        if firstmol :
            legend.extend(["HOMA R" + str(rnum) + " neutral", "HOMA R" + str(rnum) + " red",
            "FLU R" + str(rnum) + " neutral", "FLU R" + str(rnum) + " red",
            "PDI R" + str(rnum)  + " neutral", "PDI R" + str(rnum)  + " red",
            "Shannon R" + str(rnum)  + " neutral", "Shannon R" + str(rnum)  + " red"])
        RCentre = np.array([0.0, 0.0, 0.0])
        for  id  in ring._path:
            at = mol.GetAtom(id)
            RCentre +=  np.array([at.GetX(), at.GetY(), at.GetZ()])
        RCentre/= ring.Size()


        ex = [homaring, seed + ".log"]
        hr = []
        for atom in list(sorted(ring._path)):
            hr.append(str(atom))
            rings.append(atom)
        ex.extend(hr)
        obpat = ob.OBSmartsPattern()
        obpat.Init("C=O")
        obpat.Match(mol)
        # avoid getting lots of <openbabel.vectorvInt; proxy ... > etc.
        matches = [m for m in obpat.GetUMapList()]
        quins = []
        for match in matches:
            if match[0] in rings: quins.append(match[1])
        homas = []
        flus = []
        pdis = []
        shans = []
        out = subprocess.Popen(ex, stdout=subprocess.PIPE).stdout.read().split()
        homas.append(out[1])
        ex[0] = fluring
        out = subprocess.Popen(ex, stdout=subprocess.PIPE).stdout.read().split()
        flus.append("")
        pdis.append("")
        if os.path.isfile(seed + ".loc") :
            flus[-1]= out[0]
            pdis[-1]= out[1]
        ex[0] = homaring
        ex[1] = seed + "-.log"
        out = subprocess.Popen(ex, stdout=subprocess.PIPE).stdout.read().split()
        homas.append("")
        if os.path.isfile(seed + "-.log") :
            homas[-1]= out[1]
        ex[0] = fluring
        out = subprocess.Popen(ex, stdout=subprocess.PIPE).stdout.read().split()
        flus.append("")
        pdis.append("")
        if os.path.isfile(seed + "-.loc") :
            flus[-1]= out[0]
            pdis[-1]= out[1]

        allresults[sub].extend(homas)
        allresults[sub].extend(flus)
        allresults[sub].extend(pdis)
        allresults[sub].append(sh.pop(1))
        allresults[sub].append(sh1.pop(1))
        au2ang = 0.529177249
#    if firstmol :legend.append("ring-path n")
#    traj1 = [str(quins[0]), hr[0], hr[1], str(quins[1])]
#    traj2 = [str(quins[0]), hr[0], hr[5], hr[4], hr[3], hr[2], hr[1],  str(quins[1])]
    # traj1 = [quins[0]), hr[0], hr[1], hr[2], hr[3], str(quins[1])]
    # traj2 = [str(quins[0]), hr[0],  hr[5], hr[4], hr[3],  str(quins[1])]
##    sh= subprocess.Popen(["HOMA.pl", seed + ".log"] + traj1, stdout=subprocess.PIPE)
#    allresults[sub].append(sh.stdout.readlines()[-2].split()[-1])
#    if firstmol :legend.append("ring-path red")
#    sh= subprocess.Popen(["HOMA.pl", seed + "-.log"] +traj1, stdout=subprocess.PIPE)

#    allresults[sub].append(sh.stdout.readlines()[-2].split()[-1])
    ff = "x\n1\n0\n0\n" + str(RCentre[0]) + " " +str(RCentre[1]) + " " + str(RCentre[2]) + "\n9\n"
#    if firstmol :legend.append("ring-path2 n")
#    sh= subprocess.Popen(["HOMA.pl", seed + ".log"] +traj2, stdout=subprocess.PIPE)
#    allresults[sub].append(sh.stdout.readlines()[-2].split()[-1])
#    if firstmol :legend.append("ring-path2 red")
#    sh= subprocess.Popen(["HOMA.pl", seed + "-.log"] + traj2, stdout=subprocess.PIPE)

#    allresults[sub].append(sh.stdout.readlines()[-2].split()[-1])
    sh= subprocess.Popen(["a-ext.ext", seed], stdout=subprocess.PIPE,stdin=subprocess.PIPE)
    sh.communicate(input="ff")[0]
    sh= subprocess.Popen(["rcp.pl", seed + ".log"], stdout=subprocess.PIPE).stdout.readlines()
    if firstmol :
        sh1 = sh[0].split()
        for i in range(9) : legend.append("R" + str(rnum) + " " + sh1.pop(0))
    sh1 = sh[-1].split()
    for i in range(9) :
        allresults[sub].append("")
        allresults[sub][-1] = sh1.pop(0)
    sh= subprocess.Popen(["a-ext.ext", seed + "-"], stdout=subprocess.PIPE,stdin=subprocess.PIPE)
    sh.communicate(input=ff)
    sh= subprocess.Popen(["rcp.pl", seed + "-.log"], stdout=subprocess.PIPE).stdout.readlines()
    if firstmol :
        sh1 = sh[0].split()
        for i in range(9) : legend.append("R" + str(rnum) + " red " + sh1.pop(0))
        rnum += 1
    sh1 = sh[-1].split()
    for i in range(9) :
        allresults[sub].append("")
        allresults[sub][-1] = sh1.pop(0)
    rnum += 1

    NicsAn = "NICS-an.py"
    if os.path.isfile("NICS/" + seed + ".NICS.log") :
        sh= subprocess.Popen([NicsAn, "NICS/" + seed + ".NICS.log"], stdout=subprocess.PIPE).stdout.readlines()[1].split()
    if os.path.isfile("NICS/" + seed + "-.NICS.log") :
        sh1= subprocess.Popen([NicsAn, "NICS/" + seed + "-.NICS.log"], stdout=subprocess.PIPE).stdout.readlines()[1].split()
    rnum = 1
    for ring in  mol.GetSSSR():
        if firstmol :
            legend.extend(["NICS(0) R" + str(rnum) + " neutral", "NICS(0) R" + str(rnum) + " red",
            "NICS(0)zz R" + str(rnum) + " neutral", "NICS(0)zz R" + str(rnum) + " red",
            "NICS(1) R" + str(rnum)  + " neutral", "NICS(1) R" + str(rnum)  + " red",
            "NICS(1)zz R" + str(rnum)  + " neutral", "NICS(1)zz R"  + str(rnum)  + " red"])
        for i in range(4):
            allresults[sub].extend(["",""])
            if os.path.isfile("NICS/" + seed + ".NICS.log") : allresults[sub][-2] = sh.pop(1)
            if os.path.isfile("NICS/" + seed + "-.NICS.log") : allresults[sub][-1] = sh1.pop(1)
        rnum += 1

    sh= subprocess.Popen(["AnFuk.pl", seed + ".log"], stdout=subprocess.PIPE).stdout.readlines()
    sh1= subprocess.Popen(["AnFuk.pl", seed + "-.log"], stdout=subprocess.PIPE).stdout.readlines()
    myatomlab = sh[0].split()
    mycharges = sh[1].split()
    myfkdua = sh[3].split()
    if os.path.isfile(seed + "-.log") :
        mychargesred = sh1[1].split()
        myspinden = sh1[2].split()


    rnum = 1
    for ring in  mol.GetSSSR():
        if firstmol :
            for atom in sorted(ring._path): legend.extend(["charge R" + str(rnum) + " " + myatomlab[atom-1]] )
            for atom in sorted(ring._path): legend.extend(["charge red R" + str(rnum) + " "+ myatomlab[atom-1]] )
            for atom in sorted(ring._path): legend.extend(["spinden red R" + str(rnum) + " "+ myatomlab[atom-1]] )
            for atom in sorted(ring._path): legend.extend(["fukui R" + str(rnum) + " "+ myatomlab[atom-1]] )

        for atom in sorted(ring._path):
            allresults[sub].append(mycharges[atom-1] )

        if os.path.isfile(seed + "-.log") :
            for atom in sorted(ring._path): allresults[sub].append(mychargesred[atom-1])
        else:
            for atom in sorted(ring._path): allresults[sub].append("")

        if os.path.isfile(seed + "-.log") :
            for atom in sorted(ring._path): allresults[sub].append(myspinden[atom-1])
        else:
            for atom in sorted(ring._path): allresults[sub].append("")
        for atom in sorted(ring._path): allresults[sub].append(myfkdua[atom-1])

        print "caocao", quins, "co"
        rnum += 1
    for atom in quins:
        if firstmol :
            legend.extend(["charge Quin "  + myatomlab[atom-1]] )
            legend.extend(["charge red Quin " +  myatomlab[atom-1]] )
            legend.extend(["spinden red Quin " + myatomlab[atom-1]] )
            legend.extend(["fukui Quin " + myatomlab[atom-1]] )
        allresults[sub].append(mycharges[atom-1] )
        allresults[sub].append("")
        if os.path.isfile(seed + "-.log") : allresults[sub][-1] = mychargesred[atom-1]
        allresults[sub].append("")
        if os.path.isfile(seed + "-.log") : allresults[sub][-1] = myspinden[atom-1]
        allresults[sub].append(myfkdua[atom-1])






    firstmol = False



print " , ".join(legend)

F = open(seed + "allres.txt", "w")
F.write(" , ".join(legend) + '\n')
for key, value in allresults.iteritems() :
    answ = [str(i) for i in value]
    print " , ".join(answ)
    F.write(" , ".join(answ) + '\n')


