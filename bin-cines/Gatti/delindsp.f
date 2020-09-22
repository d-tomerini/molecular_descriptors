      PROGRAM DELIND
C
C     VERSION June 05 C. Gatti, CNR-ISTM, Milano
C     + November 2008 : small changes to deal with the spin-polarized cases (UHF, ROHF) 
C    
C     Delind evaluates localization indeces and delocalization indeces 
C     among atoms of a molecule, using information from a corrresponding 
C     series of AOM matrices, as evaluated by PROAIMV or PROMEGA 
C     As now it works on RHF or RKS DFT wavefunctions.
C     Extended, november 2008  to ROHF , UHF, natural orbitals  wfs
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      PARAMETER (MAXATO=100,MAXMO=450,MAXMO2=(MAXMO*(MAXMO+1))/2)                  
C     maxato= max number of atoms; maxmo= max number of spin      orbitals; maxmo2= number of elements in the AOM
C     matrix related to maxmo spin orbitals 
C
      CHARACTER*8 ATNAM(MAXATO),AT
      CHARACTER*4 FLOC,FIOUT
      CHARACTER*40 LOCF,IOUF
      LOGICAL ABNAT,RHF,RNAT,ROHF
      DIMENSION NAT(MAXATO),AOM(MAXMO2,MAXATO)
      DIMENSION PO(MAXMO), AN(MAXATO), BN(MAXATO)
      DIMENSION DELOC(MAXATO,MAXATO),FABA(MAXATO,MAXATO),
     *          FABB(MAXATO,MAXATO),
     *          FAAA(MAXATO),FAAB(MAXATO),VLOC(MAXATO)
      DATA ONE /1.D0/,TWO /2.D0/, ZERO/0.D0/
      DATA FLOC /'.loc'/,FIOUT /'.din'/

 999  FORMAT(8F10.6)
1000  FORMAT(4L1,2I4)
1001  FORMAT(5X,'FILE AOMs',10X,A40)
1002  FORMAT(2I4,A8)
1003  FORMAT(8F10.6)
1004  FORMAT(/,'*** DELOCALIZATION and LOCALIZATION INDEXES FOR ATOMS',
     *' A and B:',2X,A8,1X,A8,2X,'***',/)
1005  FORMAT(5X,'DELOCALIZATION INDEX         ',1PE22.14)
1006  FORMAT(5X,'DELOCALIZATION INDEX ALPHA   ',1PE22.14)
1007  FORMAT(5X,'DELOCALIZATION INDEX BETA    ',1PE22.14)
1008  FORMAT(5X,'LOCALIZATION INDEX OF ATOM A ',1PE22.14)
1009  FORMAT(5X,'LOCALIZATION INDEX OF ATOM B ',1PE22.14)
1010  FORMAT(5X,'ALPHA FERMI CORRELATION OF A ',1PE22.14)
1011  FORMAT(5X,'ALPHA FERMI CORRELATION OF B ',1PE22.14)
1012  FORMAT(5X,'BETA  FERMI CORRELATION OF A ',1PE22.14)
1013  FORMAT(5X,'BETA  FERMI CORRELATION OF B ',1PE22.14)
1604  FORMAT('Restricted Closed-Shell Wavefunction')
1602  FORMAT('Restricted Open-Shell Wavefunction')
1603  FORMAT('Unrestricted Wavefunction')

      IOUT=6
      ILOC=5
      CALL MAKNAME(1,LOCF,ILEN,FLOC)
      IF (ILEN .EQ. 0) STOP ' usage: locind inpfile outfile '
      CALL MAKNAME(2,IOUF,ILEN,FIOUT)
      IF (ILEN .EQ. 0) STOP ' usage: locind inpfile outfile '
      OPEN(ILOC, FILE=LOCF, STATUS='UNKNOWN')
      OPEN(IOUT, FILE=IOUF, STATUS='UNKNOWN')
      WRITE(IOUT,1001)LOCF
      KAT=0
1     READ(ILOC,1002,END=2000) NA,LMO,AT
      READ(ILOC,999)(PO(I),I=1,LMO)
      READ(ILOC,1000)RHF,ABNAT,RNAT,ROHF,NFBETA,IALPHA1
      KAT=KAT+1
      NAT(KAT)=NA
      ATNAM(KAT)=AT
      LMOT=(LMO*(LMO+1))/2
      READ(ILOC,1003)(AOM(LT,KAT),LT=1,LMOT)
      GO TO 1
2000  CONTINUE
C     Kat is the total number of AOM matrices (hence of the integrated atoms) in the file
      DO 2 JK=1,KAT-1
      DO 2 KL=JK,KAT
                     IF(RHF.or.RNAT)then
      FO1O2A=ZERO
      FO1O2B=ZERO
      FOOA=ZERO
      FOOB=ZERO
      K=0
      DO 3 I=1,LMO
      DO 3 J=1,I
      K=K+1
      HH=TWO
      IF(I.EQ.J)HH=ONE
      ANMIN=sqrt(po(i)*po(j))/TWO
      FOOA=FOOA-HH*ANMIN*AOM(K,KL)**2
      FOOB=FOOB-HH*ANMIN*AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 3
      FO1O2A=FO1O2A-HH*ANMIN*AOM(K,JK)*AOM(K,KL)
      FO1O2B=FO1O2B-HH*ANMIN*AOM(K,JK)*AOM(K,KL)
3     CONTINUE
                    endif
      IF(ROHF)then
      FO1O2A=ZERO
      FO1O2B=ZERO
      FOOA=ZERO
      FOOB=ZERO
      FOOA1=ZERO
      FOOB1=ZERO
      FOOA2=ZERO
      FOOA3=ZERO
      FO1O2A1=ZERO
      FO1O2B1=ZERO
      FO1O2A2=ZERO
      FO1O2A3=ZERO
      K=0
      DO 13 I=1,IALPHA1-1
      DO 13 J=1,I
      K=K+1
      HH=TWO
      IF(I.EQ.J)HH=ONE
      FOOA1=FOOA1-HH*AOM(K,KL)**2
      FOOB1=FOOB1-HH*AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 13
      FO1O2A1=FO1O2A1-HH*AOM(K,JK)*AOM(K,KL)
      FO1O2B1=FO1O2B1-HH*AOM(K,JK)*AOM(K,KL)
13    CONTINUE
      DO 14 I=1,IALPHA1-1
      DO 14 J=IALPHA1,LMO
      K=K+1
      FOOA2=FOOA2-AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 14
      FO1O2A2=FO1O2A2-AOM(K,JK)*AOM(K,KL)
14    CONTINUE
      DO 15 I=IALPHA1,LMO
      DO 15 J=IALPHA1,I   
      K=K+1
      HH=TWO
      IF(I.EQ.J)HH=ONE
      FOOA3=FOOA3-HH*AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 15
      FO1O2A3=FO1O2A3-HH*AOM(K,JK)*AOM(K,KL)
15    CONTINUE
      FOOA=FOOA1+FOOA2+FOOA3
      FOOB=FOOB1
      FO1O2A=FO1O2A1+FO1O2A2+FO1O2A3
      FO1O2B=FO1O2B1
                    endif
      IF(ABNAT)then
      FO1O2A=ZERO
      FO1O2B=ZERO
      FOOA=ZERO
      FOOB=ZERO
      K=0
      DO 16 I=1,NFBETA-1
      DO 16 J=1,I
      K=K+1
      HH=TWO
      IF(I.EQ.J)HH=ONE
      ANMIN=dsqrt(po(i)*po(j))
      FOOA=FOOA-HH*ANMIN*AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 16
      FO1O2A=FO1O2A-HH*AOM(K,JK)*ANMIN*AOM(K,KL)
16    CONTINUE
      DO 17 I=NFBETA,LMO
      DO 17 J=NFBETA,I
      HH=TWO
      IF(I.EQ.J)HH=ONE
      K=(I*(I-1))/2+J
      BNMIN=dsqrt(po(i)*po(j))
      FOOB=FOOB-HH*BNMIN*AOM(K,KL)**2
      IF(JK.EQ.KL)GO TO 17
      FO1O2B=FO1O2B-HH*AOM(K,JK)*BNMIN*AOM(K,KL)
17    CONTINUE


        endif
C
      IF(JK.NE.KL)THEN
      DELOC(JK,KL)=-TWO*(FO1O2A+FO1O2B)
      FABA(JK,KL)=-TWO*FO1O2A
      FABB(JK,KL)=-TWO*FO1O2B
      ENDIF
      FAAA(KL)=FOOA
      FAAB(KL)=FOOB
      VLOC(KL)=-(FOOA+FOOB)
2     CONTINUE
      If(RHF.or.RNAT)Write(iout,1604)
      If(ROHF)Write(iout,1602)
      If(ABNAT)Write(iout,1603)



      DO 4 JK=1,KAT-1
      DO 4 KL=JK+1,KAT
       WRITE(IOUT,*) "NA", AN(jk)
       WRITE(IOUT,*) "NB", BN(jk)
      WRITE(IOUT,1004)ATNAM(JK),ATNAM(KL)
      WRITE(IOUT,1005)DELOC(JK,KL)
      WRITE(IOUT,1006)FABA(JK,KL)
      WRITE(IOUT,1007)FABB(JK,KL)
      WRITE(IOUT,1008)VLOC(JK)
      WRITE(IOUT,1009)VLOC(KL)
      WRITE(IOUT,1010)FAAA(JK)
      WRITE(IOUT,1011)FAAA(KL)
      WRITE(IOUT,1012)FAAB(JK)
      WRITE(IOUT,1013)FAAB(KL)
4     CONTINUE      
      STOP
      END
      SUBROUTINE MAKNAME(I,STRING,L,EXT)
      CHARACTER*(*) STRING,EXT
      INTEGER I,J,L
      CALL GETARG(I,STRING)
      J = LEN(STRING)
      DO 10 N = 1,J
        IF(STRING(N:N) .EQ. ' ') THEN
          L = N - 1
          STRING = STRING(1:L)//EXT
          RETURN
        ENDIF
10    CONTINUE
      STOP ' FAILED TO MAKE A FILE NAME '
      END

