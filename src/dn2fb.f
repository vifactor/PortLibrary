      SUBROUTINE  DN2FB(N, P, X, B, CALCR, IV, LIV, LV, V, UI, UR, UF)
C
C  ***  MINIMIZE A NONLINEAR SUM OF SQUARES USING RESIDUAL VALUES ONLY..
C  ***  THIS AMOUNTS TO   DN2G WITHOUT THE SUBROUTINE PARAMETER CALCJ.
C
C  ***  PARAMETERS  ***
C
      INTEGER N, P, LIV, LV
C/6
C     INTEGER IV(LIV), UI(1)
C     DOUBLE PRECISION X(P), B(2,P), V(LV), UR(1)
C/7
      INTEGER IV(LIV), UI(*)
      DOUBLE PRECISION X(P), B(2,P), V(LV), UR(*)
C/
      EXTERNAL CALCR, UF
C
C-----------------------------  DISCUSSION  ----------------------------
C
C        THIS AMOUNTS TO SUBROUTINE NL2SNO (REF. 1) MODIFIED TO HANDLE
C     SIMPLE BOUNDS ON THE VARIABLES...
C           B(1,I) .LE. X(I) .LE. B(2,I), I = 1(1)P.
C        THE PARAMETERS FOR  DN2FB ARE THE SAME AS THOSE FOR  DN2GB
C     (WHICH SEE), EXCEPT THAT CALCJ IS OMITTED.  INSTEAD OF CALLING
C     CALCJ TO OBTAIN THE JACOBIAN MATRIX OF R AT X,  DN2FB COMPUTES
C     AN APPROXIMATION TO IT BY FINITE (FORWARD) DIFFERENCES -- SEE
C     V(DLTFDJ) BELOW.   DN2FB DOES NOT COMPUTE A COVARIANCE MATRIX.
C        THE NUMBER OF EXTRA CALLS ON CALCR USED IN COMPUTING THE JACO-
C     BIAN APPROXIMATION ARE NOT INCLUDED IN THE FUNCTION EVALUATION
C     COUNT IV(NFCALL), BUT ARE RECORDED IN IV(NGCALL) INSTEAD.
C
C V(DLTFDJ)... V(43) HELPS CHOOSE THE STEP SIZE USED WHEN COMPUTING THE
C             FINITE-DIFFERENCE JACOBIAN MATRIX.  FOR DIFFERENCES IN-
C             VOLVING X(I), THE STEP SIZE FIRST TRIED IS
C                       V(DLTFDJ) * MAX(ABS(X(I)), 1/D(I)),
C             WHERE D IS THE CURRENT SCALE VECTOR (SEE REF. 1).  (IF
C             THIS STEP IS TOO BIG, I.E., IF CALCR SETS NF TO 0, THEN
C             SMALLER STEPS ARE TRIED UNTIL THE STEP SIZE IS SHRUNK BE-
C             LOW 1000 * MACHEP, WHERE MACHEP IS THE UNIT ROUNDOFF.
C             DEFAULT = MACHEP**0.5.
C
C  ***  REFERENCE  ***
C
C 1.  DENNIS, J.E., GAY, D.M., AND WELSCH, R.E. (1981), AN ADAPTIVE
C             NONLINEAR LEAST-SQUARES ALGORITHM, ACM TRANS. MATH.
C             SOFTWARE, VOL. 7, NO. 3.
C
C  ***  GENERAL  ***
C
C     CODED BY DAVID M. GAY.
C
C+++++++++++++++++++++++++++  DECLARATIONS  +++++++++++++++++++++++++++
C
C  ***  EXTERNAL SUBROUTINES  ***
C
      EXTERNAL DIVSET, DRN2GB, DV7SCP
C
C DIVSET.... PROVIDES DEFAULT IV AND V INPUT COMPONENTS.
C DRN2GB... CARRIES OUT OPTIMIZATION ITERATIONS.
C DN2RDP... PRINTS REGRESSION DIAGNOSTICS.
C DV7SCP... SETS ALL ELEMENTS OF A VECTOR TO A SCALAR.
C
C  ***  LOCAL VARIABLES  ***
C
      INTEGER D1, DK, DR1, I, IV1, J1K, K, N1, N2, NF, NG, RD1, R1, RN
      DOUBLE PRECISION H, H0, HLIM, NEGPT5, ONE, T, XK, XK1, ZERO
C
C  ***  IV AND V COMPONENTS  ***
C
      INTEGER COVREQ, D, DINIT, DLTFDJ, J, MODE, NEXTV, NFCALL, NFGCAL,
     1        NGCALL, NGCOV, R, REGD0, TOOBIG, VNEED
C/6
C     DATA COVREQ/15/, D/27/, DINIT/38/, DLTFDJ/43/, J/70/, MODE/35/,
C    1     NEXTV/47/, NFCALL/6/, NFGCAL/7/, NGCALL/30/, NGCOV/53/,
C    2     R/61/, REGD0/82/, TOOBIG/2/, VNEED/4/
C/7
      PARAMETER (COVREQ=15, D=27, DINIT=38, DLTFDJ=43, J=70, MODE=35,
     1           NEXTV=47, NFCALL=6, NFGCAL=7, NGCALL=30, NGCOV=53,
     2           R=61, REGD0=82, TOOBIG=2, VNEED=4)
C/
      DATA HLIM/0.1D+0/, NEGPT5/-0.5D+0/, ONE/1.D+0/, ZERO/0.D+0/
	  
C------------------------------- KOPP TEST -----------------------------
C      write(*,530) 'x(1), x(2)', X(1), X(2)
C      write(*,530) 'xb(1), xb(2)', B(1, 1), B(1, 2)
C      write(*,530) 'xu(1), xu(2)', B(2, 1), B(2, 2)
C 530  FORMAT (A, X ,2(F5.3X))
C----------------------------- KOPP TEST END ---------------------------
	  
C
C---------------------------------  BODY  ------------------------------
C
      IF (IV(1) .EQ. 0) CALL DIVSET(1, IV, LIV, LV, V)
      IV(COVREQ) = 0
      IV1 = IV(1)
      IF (IV1 .EQ. 14) GO TO 10
      IF (IV1 .GT. 2 .AND. IV1 .LT. 12) GO TO 10
      IF (IV1 .EQ. 12) IV(1) = 13
      IF (IV(1) .EQ. 13) IV(VNEED) = IV(VNEED) + P + N*(P+2)
      CALL DRN2GB(B, X, V, IV, LIV, LV, N, N, N1, N2, P, V, V, V, X)
      IF (IV(1) .NE. 14) GO TO 999
C
C  ***  STORAGE ALLOCATION  ***
C
      IV(D) = IV(NEXTV)
      IV(R) = IV(D) + P
      IV(REGD0) = IV(R) + N
      IV(J) = IV(REGD0) + N
      IV(NEXTV) = IV(J) + N*P
      IF (IV1 .EQ. 13) GO TO 999
C
 10   D1 = IV(D)
      DR1 = IV(J)
      R1 = IV(R)
      RN = R1 + N - 1
      RD1 = IV(REGD0)
C
 20   CALL DRN2GB(B, V(D1), V(DR1), IV, LIV, LV, N, N, N1, N2, P, V(R1),
     1           V(RD1), V, X)
      IF (IV(1)-2) 30, 50, 999
C
C  ***  NEW FUNCTION VALUE (R VALUE) NEEDED  ***
C
 30   NF = IV(NFCALL)
      CALL CALCR(N, P, X, NF, V(R1), UI, UR, UF)
      IF (NF .GT. 0) GO TO 40
         IV(TOOBIG) = 1
         GO TO 20
 40   IF (IV(1) .GT. 0) GO TO 20
C
C  ***  COMPUTE FINITE-DIFFERENCE APPROXIMATION TO DR = GRAD. OF R  ***
C
C     *** INITIALIZE D IF NECESSARY ***
C
 50   IF (IV(MODE) .LT. 0 .AND. V(DINIT) .EQ. ZERO)
     1        CALL DV7SCP(P, V(D1), ONE)
C
      J1K = DR1
      DK = D1
      NG = IV(NGCALL) - 1
      IF (IV(1) .EQ. (-1)) IV(NGCOV) = IV(NGCOV) - 1
      DO 120 K = 1, P
         IF (B(1,K) .GE. B(2,K)) GO TO 110
         XK = X(K)
         H = V(DLTFDJ) * DMAX1(DABS(XK), ONE/V(DK))
         H0 = H
         DK = DK + 1
         T = NEGPT5
         XK1 = XK + H
         IF (XK - H .GE. B(1,K)) GO TO 60
            T = -T
            IF (XK1 .GT. B(2,K)) GO TO 80
 60      IF (XK1 .LE. B(2,K)) GO TO 70
            T = -T
            H = -H
            XK1 = XK + H
            IF (XK1 .LT. B(1,K)) GO TO 80
 70      X(K) = XK1
         NF = IV(NFGCAL)
         CALL CALCR (N, P, X, NF, V(J1K), UI, UR, UF)
         NG = NG + 1
         IF (NF .GT. 0) GO TO 90
              H = T * H
              XK1 = XK + H
              IF (DABS(H/H0) .GE. HLIM) GO TO 70
 80                IV(TOOBIG) = 1
                   IV(NGCALL) = NG
                   GO TO 20
 90      X(K) = XK
         IV(NGCALL) = NG
         DO 100 I = R1, RN
              V(J1K) = (V(J1K) - V(I)) / H
              J1K = J1K + 1
 100          CONTINUE
         GO TO 120
C        *** SUPPLY A ZERO DERIVATIVE FOR CONSTANT COMPONENTS...
 110     CALL DV7SCP(N, V(J1K), ZERO)
         J1K = J1K + N
 120     CONTINUE
      GO TO 20
C
 999  RETURN
C
C  ***  LAST CARD OF  DN2FB FOLLOWS  ***
      END
