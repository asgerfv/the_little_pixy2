DEFINT A-Z
'$DYNAMIC

DECLARE SUB CloseTheMusic ()
DECLARE FUNCTION Collision% (X1%, Y1%, X2%, Y2%, DeltaX1%, DeltaY1%, DeltaX2%, DeltaY2%)
DECLARE SUB ControlKeyboard ()
DECLARE SUB EndProgram ()
DECLARE SUB ErrorHandler (Text$)
DECLARE SUB InstallProgram ()
DECLARE SUB LoadLevelMap ()
DECLARE SUB LoadGraphics ()
DECLARE SUB ShowPlayer ()
DECLARE SUB ShowTiles ()


' BWS
DECLARE SUB PlaySong (ModFile$)
DECLARE SUB HearSample (Sam%)
DECLARE SUB HearSample2 (Sam%)

'$INCLUDE: 'PIXY.BI'



' ---- Activate ErrorHandler ----
ON ERROR GOTO ErrorHandler


' ---- Activate FPS counter ----
TIMER ON
ON TIMER(1) GOSUB FPS




' ---- Setup memory ----
CLEAR , , 4096

'Freemem& = FRE(-1) - (80000 + 257)

'Freemem& = FRE(-1) - (257)
'A& = SETMEM(-Freemem&)









' ---------- Buffers ----------
DIM SHARED Sprite%(2026), VIDEO%(31999), Font AS STRING * 2305
DIM SHARED Pal AS STRING * 768



' ---- Level data ----
DIM SHARED FileName AS STRING
DIM SHARED Level AS INTEGER
DIM SHARED BackGroundX, BackGroundY AS INTEGER


' ---- FPS counters ----
DIM SHARED Count AS INTEGER, RTFPS, FPSCount, AFPS AS INTEGER

' ---- Player ----
DIM SHARED PlayerX, PlayerY AS INTEGER
DIM SHARED PlayerDir AS INTEGER
DIM SHARED PlayerScore AS INTEGER
DIM SHARED PlayerScoreS AS STRING * 5


DIM SHARED SoundCard, SoundBase, SoundIRQ, SoundDMA, SoundQuality AS INTEGER
DIM SHARED KeyUp, KeyDown, KeyLeft, KeyRight, KeyJump AS INTEGER




' Things that can be troggled
DIM SHARED MusicEnabled AS INTEGER
DIM SHARED CheatString AS STRING
DIM SHARED LoadNewLevel AS INTEGER


DIM SHARED Map%(0 TO 65, 0 TO 40)



'InstallProgram

SCREEN 13



NewLevel:
LoadNewLevel = FALSE

FileName = "Levels\Level" + LTRIM$(STR$(Level)) + ".LEV"
FileName = LTRIM$(RTRIM$(FileName))

LoadLevelMap


IF MusicEnabled = TRUE THEN
    StopMusic
    StopOutput
    UnloadModule
    PlaySong "Sound"
MName$ = "Level" + LTRIM$(STR$(INT((Level / 2) + .5)))
MName$ = LTRIM$(RTRIM$(MName$))
    StopMusic
    StopOutput
    PlaySong MName$
    ModMusicPlaying = 1
END IF

'LoadGraphics



DO
Tast$ = INKEY$
Tast = INP(&H60)

' ---- Control palette ----
GoPal = GoPal + 1
IF GoPal = 10 THEN
    GoPal = 0
    PIXYpalRotate 240, 246, 0
END IF


ShowTiles
'ShowPlayer

IF Tast = 77 THEN
  PlayerDir = RIGHT
  IF BackGroundX > 2 THEN BackGroundX = BackGroundX - 1
END IF

IF Tast = 75 THEN
  PlayerDir = LEFT
  IF BackGroundX < (59 * 32) THEN BackGroundX = BackGroundX + 1
END IF


'ControlKeyboard

'PIXYtoScreen VARSEG(VIDEO%(0))


IF LoadNewLevel = TRUE THEN GOTO NewLevel
Count = Count + 1
LOOP UNTIL Tast = 1
SYSTEM






FPS:
  RTFPS = Count
  FPSCount = FPSCount + 1
  AFPS = AFPS + Count
  Count = 0
  RETURN


ErrorHandler:
  PIXYcloseDataFile
  PIXYclose

  SCREEN 0
  WIDTH 80, 25
  CLS
  COLOR 14, 4
  TextHead$ = "Error"
  LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(TextHead$) / 2): PRINT TextHead$
  COLOR 7, 0
  PRINT
  PRINT "An error upcurred."
  PRINT "Number: "; ERR
  IF ERR = 5 THEN PRINT "Illigal function"
  IF ERR = 6 OR ERR = 9 THEN PRINT "Out of range"
  IF ERR = 7 THEN PRINT "Not enough memory"
  PRINT
  PRINT "This is a bug by TMB"
  PRINT "Please report it: tmb@crosswinds.net"
  PRINT
  PRINT
  SYSTEM

REM $STATIC
SUB CloseTheMusic


IF MusicEnabled THEN
    StopMusic
    StopOutput
    UnloadModule
    FreeMSE
    ModMusicPlaying = 0
END IF



END SUB

FUNCTION Collision% (X1%, Y1%, X2%, Y2%, DeltaX1%, DeltaY1%, DeltaX2%, DeltaY2%)


Collision% = 0

IF (X1% + DeltaX1%) > X2% THEN
        IF (X2% + DeltaX2%) > X1% THEN

                IF (Y1% + DeltaY1%) > Y2% THEN
                        IF (Y2% + DeltaY2%) > Y1% THEN Collision% = 1
                END IF

        END IF
END IF






END FUNCTION

SUB ControlKeyboard


' Right
IF PIXYkey(KeyRight) THEN
  PlayerDir = RIGHT
  IF BackGroundX > 2 THEN BackGroundX = BackGroundX - 1
END IF




' Left
IF PIXYkey(KeyLeft) THEN
  PlayerDir = LEFT
  BackGroundX = BackGroundX + 1
END IF





IF PIXYkey(60) THEN ShowFPS = TRUE
IF PIXYkey(61) THEN ShowFPS = FALSE

IF PIXYkey(1) THEN EndProgram



END SUB

REM $DYNAMIC
SUB EndProgram


CloseTheMusic


SCREEN 0
WIDTH 80, 25
CLS
COLOR 14, 4
Text$ = "The little Pixy 2   ver. v1.0 - Shut down"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0

PIXYclose

'PRINT "Averange FPS     :  "; AFPS / FPSCount

COLOR 15, 0

Text$ = "Credits": LOCATE 8, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Programming :  AM": LOCATE 10, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Graphics :  TM": LOCATE 11, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Music :  See PIXY.txt": LOCATE 12, 40 - (LEN(Text$) / 2): PRINT Text$

R% = (((ASC(MID$(TIME$, 8)) - 48) / 2) / 2) + 1
Text$ = "TMB Productions - "
IF R% = 1 THEN Text$ = Text$ + "When quality counts"
IF R% = 2 THEN Text$ = Text$ + "Now you're playing with POWER"
IF R% = 3 THEN Text$ = Text$ + "BIG time hits"
LOCATE 14, 40 - (LEN(Text$) / 2): PRINT Text$

Text$ = "www.tmbproductions.com": LOCATE 16, 40 - (LEN(Text$) / 2): PRINT Text$


COLOR 7, 0

LOCATE 19, 1
PRINT

SYSTEM


END SUB

REM $STATIC
SUB ErrorHandler (Text$)

SCREEN 0
WIDTH 80, 25
CLS
COLOR 14, 4
TextHead$ = "Error"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(TextHead$) / 2): PRINT TextHead$
COLOR 7, 0
PRINT
PRINT Text$
PRINT
PRINT
CloseTheMusic
PIXYcloseDataFile
PIXYclose



SYSTEM






END SUB

SUB HearSample (Sam%)

IF MusicEnabled = TRUE THEN PlaySample 5, Sam%, 22000, 40, 8


END SUB

REM $DYNAMIC
SUB InstallProgram

' --------- Install ---------
SCREEN 0
WIDTH 80, 25
CLS
COLOR 15, 4
Text$ = "The little Pixy 2   v1.0 - Startup"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0
PRINT "Wait a moment.."

PRINT "Free memory: "; FRE(-1)



' ---- Open SETUP file and get settings ----
PRINT
PRINT "Sound........";
OPEN "DATA\PIXY.Set" FOR INPUT AS #1

INPUT #1, SoundCard
INPUT #1, SoundBase
  SELECT CASE SoundBase
    CASE 0: SoundBase = &HFFFF
    CASE 1: SoundBase = &H210
    CASE 2: SoundBase = &H220
    CASE 3: SoundBase = &H230
    CASE 4: SoundBase = &H240
    CASE 5: SoundBase = &H250
    CASE 6: SoundBase = &H260
    CASE 7: SoundBase = &H270
    CASE 8: SoundBase = &H280
  END SELECT

INPUT #1, SoundIRQ
  SELECT CASE SoundIRQ
    CASE 0: SoundIRQ = &HFF
    CASE 1: SoundIRQ = &H2
    CASE 2: SoundIRQ = &H5
    CASE 3: SoundIRQ = &H7
    CASE 4: SoundIRQ = &H10
    CASE 5: SoundIRQ = &H11
    CASE 6: SoundIRQ = &H12
    CASE 7: SoundIRQ = &H15
  END SELECT

INPUT #1, SoundDMA
  SELECT CASE SoundDMA
    CASE 0: SoundDMA = &HFF
    CASE 1: SoundDMA = &H0
    CASE 2: SoundDMA = &H1
    CASE 3: SoundDMA = &H3
    CASE 4: SoundDMA = &H5
    CASE 5: SoundDMA = &H6
    CASE 6: SoundDMA = &H7
  END SELECT

INPUT #1, SoundQuality
  SELECT CASE SoundQuality
    CASE 0: SoundQuality = 1
    CASE 1: SoundQuality = 2
    CASE 2: SoundQuality = 3
    CASE 3: SoundQuality = 0
  END SELECT

INPUT #1, KeyUp
INPUT #1, KeyDown
INPUT #1, KeyLeft
INPUT #1, KeyRight
INPUT #1, KeyJump
CLOSE #1



MusicEnabled = TRUE
PRINT "Reading settings...";
'SndDevMSE(1) = "GUS"
'SndDevMSE(2) = "SB1X"
'SndDevMSE(3) = "SB2X"
'SndDevMSE(4) = "SBPRO"
'SndDevMSE(5) = "SB16"
'SndDevMSE(6) = "PAS"
IF SoundCard = 0 THEN
  PRINT "no sound or music"
  MusicEnabled = FALSE
END IF


MusicEnabled = FALSE

IF MusicEnabled = TRUE THEN
  MSE$ = LTRIM$("Drivers\" + SndDevMSE(SoundCard) + ".MSE")
  SELECT CASE SoundQuality
    CASE 0: Ov = 16
    CASE 1: Ov = 22
    CASE 2: Ov = 45
    CASE 3: Ov = 8
  END SELECT

  ErrorFlag = LoadMSE(MSE$, 0, Ov, 4096, SoundBase, SoundIRQ, SoundDMA)
  IF NOT ErrorFlag = 0 THEN
    PRINT "Error while setting up music..."
    SELECT CASE ErrorFlag
      CASE 1: PRINT "Base I/O address autodetection failure": END
      CASE 2: PRINT "IRQ level autodetection failure": END
      CASE 3: PRINT "DMA channel autodetection failure": END
      CASE 4: PRINT "DMA channel not supported": END
      CASE 6: PRINT "Sound device does not respond - Wrong settings": END
      CASE 7: PRINT "Memory control blocks destroyed": END
      CASE 8: PRINT "Insufficient memory for mixing buffers": END
      CASE 9: PRINT "Insufficient memory for MSE file": END
      CASE 12: PRINT "MVSOUND.SYS not loaded - Required for PAS": END
      CASE 42: PRINT "Couldn't find sound driver": END
      CASE ELSE: PRINT "Unknown error on MSE startup" + STR$(ErrorFlag): END
    END SELECT
  END IF
  PRINT SndDevMSE(SoundCard)
END IF



PRINT "XMS memory...";
Result% = PIXYinit(20)
IF NOT Result% = 0 THEN
  PRINT "failed"
  PIXYclose
  PRINT
  IF Result% = 1 THEN PRINT "Library already installed"
  IF Result% = 2 THEN
    PRINT "No XMS driver found"
    PRINT "Place the following line in your CONFIG.SYS"
    PRINT "DEVICE=C:\WINDOWS\HIMEM.SYS"
    PRINT "DEVICE=C:\WINDOWS\EMM386.EXE NOEMS"
  END IF
  IF Result% = 3 THEN PRINT "You need XMS driver version 3.0"
  IF Result% = 4 THEN PRINT "You need 2mb RAM"
  IF Result% = 5 THEN PRINT "Couldn't reach the XMS memory"
  PRINT
  SYSTEM
END IF
PRINT "ok"


PRINT "Base memory..";
  'IF PIXYcreateBMap(1, 8, 8) THEN
  '  PRINT "failed"
  '  PIXYclose
  '  PRINT "Not enough conventional memory"
  '  PRINT
  '  SYSTEM
  'END IF
PRINT "ok"


PRINT
PRINT "Initalizing ok"
PRINT

PIXYfadeToBlack


END SUB

REM $STATIC
SUB LoadGraphics


'PIXYpalOff
A = PIXYopenDataFile("PIXY2.DAT", "PIXY2")
IF NOT A = 0 THEN ErrorHandler "Couldn't open PIXY2.BIN"

A = PIXYunpackFont("FONT", Font)
IF NOT A = 0 THEN ErrorHandler "Where's the FONT?"
PIXYsetFont VARSEG(Font), VARPTR(Font)


A = PIXYunpackImage("T1", VARSEG(VIDEO%(0)), 0, 0)
FOR X = 0 TO 9
PIXYgetFullXMSSprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), (X * 32), (Y * 32), 32, 32
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), X
NEXT

A = PIXYunpackPal("PAL")


PIXYcloseDataFile



END SUB

SUB LoadLevelMap

FOR I = 1 TO 59
  FOR I2 = 1 TO 39

'PIXYsetTileMap I, I2, INT((9 - 0 + 1) * RND + 0)
Map(I, I2) = INT((9 - 0 + 1) * RND + 0)

  NEXT
NEXT



END SUB

SUB PlaySong (ModFile$)

ModFile$ = "Music\" + ModFile$ + ".GDM"
ModFile$ = LTRIM$(RTRIM$(ModFile$))

IF EmsExist THEN ErrorFlag = 1 ELSE ErrorFlag = 0   'Setup EMS use flag
Filen = FREEFILE
OPEN ModFile$ FOR BINARY AS Filen
LoadGDM FILEATTR(Filen, 2), 0, ErrorFlag, VARSEG(ModHead), VARPTR(ModHead)


SELECT CASE ErrorFlag
CASE 0
CASE 1: ErrorHandler "Module is corrupt"
CASE 4: ErrorHandler "Music: Out of memory"
CASE ELSE: ErrorHandler "Unknown music load Error:" + STR$(ErrorFlag)
END SELECT


OverRate& = StartOutput(6, 0)
StartMusic



END SUB

SUB ShowPlayer


'IF PlayerDir = LEFT THEN PIXYputFullXMS VARSEG(VIDEO%(0)), 1, PlayerX, PlayerY, 24, 21

PIXYsolidXMS VARSEG(VIDEO%(0)), 1, PlayerX, PlayerY



END SUB

SUB ShowTiles



FOR X% = INT(BackGroundX / 32) TO INT((BackGroundX + 300) / 32)
  FOR Y% = 0 TO 5 'INT((ABS(BackGroundY) + 10) / 32) TO INT((ABS(BackGroundY) + 99) / 32)

'PIXYsolidXMS VARSEG(VIDEO%(0)), PIXYgetTileMap(X%, Y%), X% * 32 - BackGroundX, Y% * 32
'PIXYsolidXMS VARSEG(VIDEO%(0)), Map%(X%, Y%), X% * 32 - BackGroundX, Y% * 32
PSET (X% * 32 - BackGroundX, Y% * 32), Map%(X%, Y%)
   

  NEXT
NEXT




END SUB

