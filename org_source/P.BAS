DEFINT A-Z
'$DYNAMIC

DECLARE SUB TheEnd ()
DECLARE SUB ShowSnow (Colour%, Y2%)
DECLARE SUB GetReady ()
DECLARE SUB CloseTheMusic ()
DECLARE FUNCTION Collision% (X1%, Y1%, X2%, Y2%, DeltaX1%, DeltaY1%, DeltaX2%, DeltaY2%)
DECLARE SUB ConfirmExit ()
DECLARE SUB ControlKeyboard ()
DECLARE SUB ControlPlayer ()
DECLARE SUB Delay ()
DECLARE SUB EndProgram ()
DECLARE SUB ErrorHandler (Text$)
DECLARE SUB InstallProgram ()
DECLARE SUB Intro ()
DECLARE SUB LoadLevelMap ()
DECLARE SUB LoadGraphics ()
DECLARE SUB Menu ()
DECLARE SUB PauseGame ()
DECLARE SUB ShowInformation ()
DECLARE SUB ShowActions ()
DECLARE SUB ShowPlayer ()
DECLARE SUB ShowTiles ()
DECLARE SUB WaitKey (i%)
DECLARE SUB TimeUP ()


' BWS
DECLARE SUB PlaySong (ModFile$)
DECLARE SUB HearSample (Sam%)
DECLARE SUB HearSample2 (Sam%)

'$INCLUDE: 'PIXY.BI'





' ---- Setup memory ----
CLEAR , , 4096

Freemem& = FRE(-1) - 80000
a& = SETMEM(-Freemem&)









' ---------- Buffers ----------
DIM SHARED Sprite%(2146), VIDEO%(31999), Font AS STRING * 2305
DIM SHARED Pal AS STRING * 768, Pal2 AS STRING * 768


' ---- Stuff for Intro sequence ----
DIM SHARED SnowX(250) AS INTEGER
DIM SHARED SnowY(250) AS INTEGER
DIM SHARED SnowDir(250) AS INTEGER
DIM SHARED SnowSpeed(250) AS INTEGER


' ---- Level data ----
DIM SHARED FileName AS STRING
DIM SHARED Level AS INTEGER
DIM SHARED BackGroundX, BackGroundY AS INTEGER
DIM SHARED FirePlaceCount, FC2 AS INTEGER
DIM SHARED LiftX, LiftY, SLiftY, ELiftY, LiftDir, LiftArea, LiftActive AS INTEGER
DIM SHARED BallX(4), BallY(4), BallSX(4), BallSY(4), BallA(4), BallB(4), BallDir(4) AS INTEGER
DIM SHARED DropX(4), DropY(4), DropA(4), DropSpeed AS INTEGER
DIM SHARED KeyActive AS INTEGER
DIM SHARED CurrentItem, ItemsCollected AS INTEGER
DIM SHARED TimerCount, TCount, SlowDown AS INTEGER
DIM SHARED FontColour AS INTEGER
DIM SHARED Ladder AS INTEGER
DIM SHARED FrameSkip AS INTEGER


' ---- FPS counters ----
DIM SHARED Count, FPSCount AS INTEGER


' ---- Player ----
DIM SHARED PlayerX, PlayerY AS INTEGER
DIM SHARED PlayerDIR AS INTEGER
DIM SHARED PlayerAnimation AS INTEGER
DIM SHARED PlayerAniCount, PlayerAniCount2 AS INTEGER
DIM SHARED PlayerCrawlCount, PlayerCrawlCount2 AS INTEGER
DIM SHARED PlayerLives AS INTEGER
DIM SHARED PX1, PX2 AS INTEGER
DIM SHARED PY1, PY2 AS INTEGER
DIM SHARED LadderY1, LadderY2 AS INTEGER
DIM SHARED PlayerCount AS INTEGER
DIM SHARED MaxJump AS INTEGER
DIM SHARED PlayerFlash AS INTEGER
DIM SHARED OldPlayerY AS INTEGER

CONST STAND = 0, WALK = 1, JUMP = 2, FALL = 3, CRAWL = 4


DIM SHARED SoundCard, SoundBase, SoundIRQ, SoundDMA, SoundQuality AS INTEGER
DIM SHARED KeyUp, KeyDown, KeyLeft, KeyRight, KeyJump AS INTEGER




' Things that can be troggled
DIM SHARED MusicEnabled AS INTEGER
DIM SHARED CheatString AS STRING
DIM SHARED LoadNewLevel AS INTEGER
DIM SHARED ShowFPS AS INTEGER
DIM SHARED ToMenu AS INTEGER
DIM SHARED RecordDemo AS INTEGER

DIM SHARED RecordRight, RecordLeft, RecordJump, RecordNothing AS INTEGER
DIM SHARED RecordBuffer AS STRING


' ---- Activate ErrorHandler ----
'ON ERROR GOTO ErrorHandler


' ---- Activate FPS counter ----
ON TIMER(1) GOSUB FPS



InstallProgram

SCREEN 13


RecordDemo = TRUE

Intro

LoadGraphics


FrameSkip = 2

ShowMenu:
ToMenu = FALSE

Level = 0
PlayerLives = 3

'Menu



NewLevel:
LoadNewLevel = FALSE

Level = Level + 1
IF Level = 10 THEN
  TheEnd
  GOTO ShowMenu
END IF

FileName = "DATA\Level" + LTRIM$(STR$(Level)) + ".LEV"
FileName = LTRIM$(RTRIM$(FileName))
LoadGraphics


LoadLevelMap


IF MusicEnabled = TRUE THEN
  StopMusic
  StopOutput
  UnloadModule
  PlaySong "Sound"
  MName$ = "Level" + LTRIM$(STR$(Level))
  MName$ = LTRIM$(RTRIM$(MName$))
  StopMusic
  StopOutput
  PlaySong MName$
END IF





PlayerDIR = RIGHT
PlayerAnimation = STAND
PlayerCrawlCount = 0
PY1 = 0
PY2 = 0
Ladder = FALSE
KeyActive = FALSE
CurrentItem = 0
ItemsCollected = 0
FontColour = 199
ShowFPS = FALSE
MaxJump = 13
PlayerFlash = 0
DropSpeed = 1
TCount = 0
SlowDown = 0

TIMER OFF

GetReady

TIMER ON

DO

IF PlayerCount = 0 THEN
  PlayerCount = FrameSkip

  ControlKeyboard

  ' ---- SHOW the stuff ----
  ShowTiles
  ControlPlayer
  ShowPlayer
  ShowActions
  ShowInformation
END IF


PIXYtoScreen VARSEG(VIDEO%(0))

PlayerCount = PlayerCount - 1


IF LoadNewLevel = TRUE THEN GOTO NewLevel
IF ToMenu = TRUE THEN GOTO ShowMenu

Count = Count + 1

LOOP




FPS:
  FPSCount = Count
  Count = 0
  TimerCount = TimerCount - 1
  RETURN


ErrorHandler:
  CloseTheMusic
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
  IF ERR = 53 THEN PRINT "Couldn't open file"
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

SUB ConfirmExit

TIMER OFF

WaitKey 1

PIXYputBIG VARSEG(VIDEO%(0)), 152, 80, 40, 165, 25
PIXYputBIG VARSEG(VIDEO%(0)), 153, 80, 64, 165, 25
PIXYputBIG VARSEG(VIDEO%(0)), 154, 80, 88, 165, 25
PIXYputBIG VARSEG(VIDEO%(0)), 155, 80, 112, 165, 23


PIXYgetLayer VARSEG(VIDEO%(0))



Y% = 68
Y2% = 68

DO

' ---- CONTROL Menu
IF PIXYkey(72) AND Y% = Y2% AND Y2% > 68 THEN Y2% = Y2% - 17
IF PIXYkey(80) AND Y% = Y2% AND Y2% < 102 THEN Y2% = Y2% + 17
IF PIXYkey(28) THEN
  IF Y% = 68 THEN EXIT DO
  IF Y% = 85 THEN
    WaitKey 28
    FrameSkip = FrameSkip + 1
    IF FrameSkip > 2 THEN FrameSkip = 1
  END IF
  IF Y% = 102 THEN
    PIXYfadeToBlack
    ToMenu = TRUE
    EXIT SUB
  END IF
END IF
IF PIXYkey(1) THEN WaitKey 1: EXIT DO

IF Y2% > Y% THEN Y% = Y% + 1
IF Y2% < Y% THEN Y% = Y% - 1

PIXYputLayer VARSEG(VIDEO%(0))
PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + 13, 87, Y%
PIXYprint STR$(FrameSkip), VARSEG(VIDEO%(0)), 207, 89, 199
PIXYtoScreen VARSEG(VIDEO%(0))

LOOP

TIMER ON


END SUB

SUB ControlKeyboard

PlayerAnimation = STAND

' ---- RIGHT ----
IF PIXYkey(KeyRight) THEN
  PlayerDIR = RIGHT
  IF PX1 < 3 THEN PX1 = PX1 + 1
END IF

IF NOT PIXYkey(KeyRight) THEN
  IF PX1 > 0 THEN PX1 = PX1 - 1
END IF

IF PX1 > 0 THEN
  PlayerAnimation = WALK
  IF PlayerX < 170 THEN
    PlayerX = PlayerX + PX1
  ELSE
    IF BackGroundX < ((51 * 32) - 6) THEN
      BackGroundX = BackGroundX + PX1
    ELSE
      IF PlayerX < 262 THEN
        PlayerX = PlayerX + PX1
      ELSE
        PlayerX = 262
      END IF
    END IF
  END IF
END IF





' ---- LEFT ----
IF PIXYkey(KeyLeft) THEN
  PlayerDIR = LEFT
  IF PX2 < 3 THEN PX2 = PX2 + 1
END IF

IF NOT PIXYkey(KeyLeft) THEN
  IF PX2 > 0 THEN PX2 = PX2 - 1
END IF

IF PX2 > 0 THEN
  PlayerAnimation = WALK
  IF PlayerX > 130 THEN
    PlayerX = PlayerX - PX2
  ELSE
    IF BackGroundX > 0 THEN
      BackGroundX = BackGroundX - PX2
      IF BackGroundX < 0 THEN BackGroundX = 0
    ELSE
      IF PlayerX > 32 THEN
        PlayerX = PlayerX - PX2
      ELSE
        PlayerX = 32
      END IF
    END IF
  END IF
END IF




' ---- JUMPING ----
IF PIXYkey(KeyJump) AND PY1 = 0 AND PY2 = 0 THEN
  IF NOT PlayerY = 0 THEN PY1 = MaxJump
  HearSample 32
END IF

IF PY1 > 0 THEN
  PlayerAnimation = JUMP
  PY1 = PY1 - 1
  PlayerY = PlayerY - PY1
END IF




' ---- EXTRA keys ----
IF PIXYkey(25) THEN PauseGame

IF PIXYkey(60) THEN ShowFPS = TRUE
IF PIXYkey(61) THEN ShowFPS = FALSE
IF PIXYkey(68) THEN EndProgram

IF PIXYkey(1) THEN ConfirmExit


IF RecordDemo = TRUE THEN
 
  ' ---- Record RIGHT key ----
  IF PIXYkey(KeyRight) THEN
    IF RecordRight = 0 THEN
      RecordBuffer = RecordBuffer + "!R"
      RecordRight = 1
    ELSE
      RecordRight = RecordRight + 1
    END IF
  END IF
  IF NOT PIXYkey(KeyRight) AND RecordRight > 0 THEN
    RecordBuffer = RecordBuffer + "!r" + STR$(RecordRight)
    RecordRight = 0
  END IF


END IF


END SUB

SUB ControlPlayer


a% = PIXYgetActionMap((BackGroundX + (PlayerX - 12)) / 32, (PlayerY + 17) / 32)
b% = PIXYgetActionMap((BackGroundX + (PlayerX)) / 32, (PlayerY + 17) / 32)



' ---- HANDLE DOWN ----
IF Ladder = FALSE AND LiftActive = FALSE AND (a% <> 1 AND b% <> 1) AND PY1 = 0 THEN
  IF a% <> 2 AND b% <> 2 THEN PlayerAnimation = FALL
  PY2 = PY2 + 1
  PlayerY = PlayerY + PY2
ELSE
  IF a% <> 2 OR b% <> 2 THEN PY2 = 0
END IF


' -- The BIG checker --
IF PIXYgetActionMap((BackGroundX + PlayerX - 12) / 32, (PlayerY + 16) / 32) = 1 OR PIXYgetActionMap((BackGroundX + PlayerX) / 32, (PlayerY + 16) / 32) = 1 THEN
  IF PlayerY > INT(PlayerY / 32) * 32 THEN PlayerY = INT(PlayerY / 32) * 32
END IF



' BIG Checker for 'Stop on top' events
IF PIXYgetActionMap((BackGroundX + PlayerX - 12) / 32, (PlayerY + 16) / 32) = 2 OR PIXYgetActionMap((BackGroundX + PlayerX) / 32, (PlayerY + 16) / 32) = 2 THEN
  IF PIXYgetActionMap((BackGroundX + PlayerX - 12) / 32, (PlayerY) / 32) <> 2 AND PIXYgetActionMap((BackGroundX + PlayerX + 12) / 32, (PlayerY) / 32) <> 2 THEN
    IF PY1 = 0 AND PY2 > 0 THEN
      PY2 = 0
      IF PlayerY > INT(PlayerY / 32) * 32 THEN PlayerY = INT(PlayerY / 32) * 32
    END IF
  END IF
END IF


' ---- HANDLE UP ----
IF PIXYgetActionMap((BackGroundX + PlayerX - 12) / 32, (PlayerY - 17) / 32) = 1 OR PIXYgetActionMap((BackGroundX + PlayerX) / 32, (PlayerY - 17) / 32) = 1 THEN
  PY2 = PY2 + 1
  PY1 = 0
END IF




' ---- HANDLE LEFT / RIGHT ----
IF PIXYgetActionMap((BackGroundX + PlayerX + 8) / 32, (PlayerY + 15) / 32) = 1 THEN
  PX1 = -3
END IF
IF PIXYgetActionMap((BackGroundX + PlayerX + 8) / 32, (PlayerY) / 32) = 1 THEN
  PX1 = -3
END IF


IF PIXYgetActionMap((BackGroundX + PlayerX - 16) / 32, (PlayerY + 15) / 32) = 1 THEN
  PX2 = -3
END IF
IF PIXYgetActionMap((BackGroundX + PlayerX - 16) / 32, (PlayerY) / 32) = 1 THEN
  PX2 = -3
END IF


' ---- Handle Ladder ----
IF PIXYgetActionMap((BackGroundX + PlayerX - 5) / 32, (PlayerY + 14) / 32) = 3 THEN
  IF PIXYgetActionMap((BackGroundX + PlayerX - 5) / 32, (PlayerY - 17) / 32) <> 1 THEN
    IF PIXYkey(KeyUp) THEN Ladder = TRUE
    IF PIXYkey(KeyDown) THEN Ladder = TRUE
  ELSE
    LadderY1 = -1
  END IF
ELSE
  Ladder = FALSE
END IF

IF Ladder = TRUE THEN
  PlayerAnimation = CRAWL
  IF PIXYkey(KeyUp) THEN
    PlayerCrawlCount2 = PlayerCrawlCount2 + 1
    IF LadderY1 < 3 THEN LadderY1 = LadderY1 + 1
  ELSE
    IF LadderY1 > 0 THEN LadderY1 = LadderY1 - 1
  END IF
  IF PIXYkey(KeyDown) THEN
    PlayerCrawlCount2 = PlayerCrawlCount2 + 1
    IF LadderY2 < 3 THEN LadderY2 = LadderY2 + 1
  ELSE
    IF LadderY2 > 0 THEN LadderY2 = LadderY2 - 1
  END IF
  IF PIXYgetActionMap((BackGroundX + PlayerX - 5) / 32, (PlayerY + 14) / 32) = 3 THEN PlayerY = PlayerY - LadderY1
  IF PIXYgetActionMap((BackGroundX + PlayerX - 5) / 32, (PlayerY + 17) / 32) = 3 THEN PlayerY = PlayerY + LadderY2
END IF



' ---- The LIFT ----
LiftActive = FALSE
IF (PlayerY + 33) > LiftY AND (PlayerY + 20) < LiftY THEN
  IF (PlayerX + BackGroundX) > (LiftX - 18) AND (PlayerX + BackGroundX) < (LiftX + 29) THEN
    LiftActive = TRUE
    IF LiftDir = UP THEN PlayerY = (LiftY - 32)
    IF LiftDir = DOWN THEN PlayerY = (LiftY - 31)
  END IF
END IF




END SUB

REM $DYNAMIC
SUB EndProgram


CloseTheMusic

Freemem& = FRE(-1) + (80000 * 2)
a& = SETMEM(Freemem&)

IF RecordDemo = TRUE THEN
  CLOSE
  OPEN "DATA\Demo1.dat" FOR OUTPUT AS #2
  WRITE #2, RecordBuffer
END IF



SCREEN 0
WIDTH 80, 25
CLS
COLOR 15, 4
Text$ = "The little Pixy 2   ver. v1.3 - Shut down"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0

PIXYclose

COLOR 15, 0

Text$ = "Credits": LOCATE 8, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Programming :  AM": LOCATE 10, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Graphics :  TM": LOCATE 11, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Music :  Various": LOCATE 12, 40 - (LEN(Text$) / 2): PRINT Text$

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

SUB GetReady



' ---- SHOW the stuff ----
ShowTiles
ShowPlayer
ShowActions
ShowInformation

PIXYputBIG VARSEG(VIDEO%(0)), 151, 130, 70, 82, 26

PIXYprint "Level :" + STR$(Level), VARSEG(VIDEO%(0)), 136, 110, 0
PIXYprint "Level :" + STR$(Level), VARSEG(VIDEO%(0)), 137, 109, 199

PIXYpalOff
PIXYtoScreen VARSEG(VIDEO%(0))
PIXYfadeIn Pal


FOR i = 0 TO 80
  PIXYwait
NEXT


END SUB

SUB HearSample (Sam%)

IF MusicEnabled = TRUE THEN
  IF Sam% = 31 THEN
    PlaySample 5, Sam%, 4000, 64, 8
  ELSE
    PlaySample 5, Sam%, 10000, 64, 8
  END IF
END IF



END SUB

REM $DYNAMIC
SUB InstallProgram

' --------- Install ---------
SCREEN 0
WIDTH 80, 25
CLS
COLOR 15, 4
Text$ = "The little Pixy 2   v1.3 - Startup"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0
PRINT "Wait a moment.."

PRINT "Free memory: "; FRE(-1)



' ---- Open SETUP file and get settings ----
PRINT
PRINT "Reading settings...";
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
PRINT "ok"



PRINT "Sound settings.....";

MusicEnabled = TRUE
IF SoundCard = 0 THEN
  PRINT "no sound or music"
  MusicEnabled = FALSE
END IF
IF SoundCard = 1 THEN SoundCardName$ = "GUS"
IF SoundCard = 2 THEN SoundCardName$ = "SB1X"
IF SoundCard = 3 THEN SoundCardName$ = "SB2X"
IF SoundCard = 4 THEN SoundCardName$ = "SBPRO"
IF SoundCard = 5 THEN SoundCardName$ = "SB16"
IF SoundCard = 6 THEN SoundCardName$ = "PAS"

'MusicEnabled = FALSE

IF MusicEnabled = TRUE THEN
  MSE$ = LTRIM$("Drivers\" + SoundCardName$ + ".MSE")
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
  PRINT SoundCardString$
ELSE
  PRINT "no sound or music"
END IF


PRINT "XMS memory...";
Result% = PIXYinit(1000)
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

PRINT
PRINT "Initalizing ok"
PRINT

PIXYfadeToBlack


END SUB

REM $STATIC
SUB Intro

IF MusicEnabled = TRUE THEN
    PlaySong "Intro"
END IF


PIXYpalOff

a = PIXYopenDataFile("DATA\PIXY2.DAT", "PIXY2")
IF NOT a = 0 THEN ErrorHandler "Couldn't open PIXY2.BIN" + STR$(a)

a = PIXYunpackPal("PAL")
PIXYgetPal Pal

a = PIXYunpackPal("IPAL")
PIXYgetPal Pal2

GOTO QuitIntro



FOR i = 0 TO 49
  SnowX(i) = INT((208 - 110 + 1) * RND + 110)
  SnowY(i) = INT((120 - 60 + 1) * RND + 60)
  SnowDir(i) = INT((1 - 0 + 1) * RND + 0)
  SnowSpeed(i) = INT((4 - 1 + 1) * RND + 1)
NEXT




' ---- Setup for TMB Logo ----
PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0
a = PIXYunpackImage("LOGO1", VARSEG(VIDEO%(0)), 90, 70)

PIXYboxF &HA000, 0, 0, 319, 199, 0
PIXYpalOff
PIXYtoScreen VARSEG(VIDEO%(0))



' ---- The TIMING of TMB logo ----
FOR i = 0 TO 80
  PIXYwait
  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
NEXT

PIXYfadeIn Pal

FOR i = 0 TO 120
  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
  PIXYwait
NEXT

PIXYfadeToBlack






' ---- First intro image ----
PIXYpalOff

PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0
a = PIXYunpackImage("INTRO1", VARSEG(VIDEO%(0)), 0, 0)

FOR i = 0 TO 170
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, i, 98, 1
  PIXYstoreBIGsprite VARSEG(Sprite%(0)), i
NEXT
PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0


' ---- SHOW intro ----
FOR I2 = 0 TO 60
  PIXYputBIG2 VARSEG(VIDEO%(0)), I2, 110, 60 + I2
NEXT
FOR I3 = 0 TO 49
  PIXYpset VARSEG(VIDEO%(0)), SnowX(I3), SnowY(I3), 206 + SnowSpeed(I3)
NEXT

PIXYtoScreen VARSEG(VIDEO%(0))

PIXYfadeIn Pal2


FOR i = 0 TO 40
  FOR I2 = 0 TO 60
    PIXYputBIG2 VARSEG(VIDEO%(0)), I2, 110, 60 + I2
  NEXT
 
  ShowSnow 206, 120
 
  IF i = 10 THEN IntroText$ = "On christmas eve"
  IF i = 40 THEN IntroText$ = "in santa's workshop up north..."
  X = 160 - ((LEN(IntroText$) * 10) / 2)
  PIXYboxF VARSEG(VIDEO%(0)), 0, 140, 319, 150, 0
  FOR I3 = 1 TO LEN(IntroText$)
    PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 213 + INT(I3 / 2)
  NEXT

  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
 
  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
  PIXYwait
  PIXYwait
  PIXYwait
NEXT



' ---- Scroll landscape ----
FOR i = 0 TO 110
  FOR I2 = 0 TO 60
    PIXYputBIG2 VARSEG(VIDEO%(0)), i + I2, 110, 60 + I2
  NEXT
 
  ' ---- Handle text ----
  IF i = 30 THEN IntroText$ = "All santa's little pixies"
  IF i = 60 THEN IntroText$ = "have gotten a cold"
  IF i = 90 THEN IntroText$ = "exept one..."
  X = 160 - ((LEN(IntroText$) * 10) / 2)
  PIXYboxF VARSEG(VIDEO%(0)), 0, 140, 319, 150, 0
  FOR I3 = 1 TO LEN(IntroText$)
    'PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + 1 + (I3 * 10), 141, 137 + I3
    PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 213 + INT(I3 / 2)
  NEXT

  ShowSnow 206, 120

  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
 
  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
  PIXYwait
  PIXYwait
  PIXYwait
NEXT



FOR i = 0 TO 20
  FOR I2 = 110 TO 170
    PIXYputBIG2 VARSEG(VIDEO%(0)), I2, 110, I2 - 50
  NEXT

  ShowSnow 206, 120

  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro

  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
  PIXYwait
  PIXYwait
  PIXYwait
NEXT


PIXYfadeToBlack



' ---- Second intro image ----
PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0
a = PIXYunpackImage("INTRO2", VARSEG(VIDEO%(0)), 110, 60)
PIXYgetLayer VARSEG(VIDEO%(0))
PIXYtoScreen VARSEG(VIDEO%(0))

PIXYfadeIn Pal


FOR i = 0 TO 240
  PIXYputLayer VARSEG(VIDEO%(0))

  ' ---- Handle text ----
  IF i = 0 THEN IntroText$ = "He now must collect"
  IF i = 30 THEN IntroText$ = "all the toys and put them"
  IF i = 60 THEN IntroText$ = "into santa's sack."
  IF i = 90 THEN IntroText$ = " "
  IF i = 120 THEN IntroText$ = "There are 4 toys on each level"
  IF i = 150 THEN IntroText$ = "a present gives extra time..."
  IF i = 180 THEN IntroText$ = "and remember to avoid"
  IF i = 210 THEN IntroText$ = "drops and bounching balls."
  X = 160 - ((LEN(IntroText$) * 10) / 2)
  PIXYboxF VARSEG(VIDEO%(0)), 0, 140, 319, 150, 0
  FOR I3 = 1 TO LEN(IntroText$)
    IF i < 90 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 96 + INT(I3 / 2)
    IF i >= 120 AND i < 240 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 32 + INT(I3 / 2)
  NEXT

  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
 
  ShowSnow 152, 135
  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
  PIXYwait
  PIXYwait
  PIXYwait
NEXT




PIXYfadeToBlack

FOR i = 0 TO 80
  IF PIXYkey(28) THEN GOTO QuitIntro
  IF PIXYkey(1) THEN GOTO QuitIntro
  PIXYwait
NEXT


QuitIntro:
PIXYcloseDataFile




END SUB

SUB LoadGraphics


PIXYpalOff

a = PIXYopenDataFile("DATA\PIXY2.DAT", "PIXY2")
IF NOT a = 0 THEN ErrorHandler "Couldn't open PIXY2.BIN" + STR$(a)

a = PIXYunpackFont("FONT", Font)
IF NOT a = 0 THEN ErrorHandler "Where's the FONT?"
PIXYsetFont VARSEG(Font), VARPTR(Font)


a = PIXYunpackImage("T1", VARSEG(VIDEO%(0)), 0, 0)
X% = 0
Y% = 0
FOR i% = 0 TO 59
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), (X% * 32), (Y% * 32), 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), i%
  X% = X% + 1
  IF X% = 10 THEN
    X% = 0
    Y% = Y% + 1
  END IF
NEXT
PIXYgetLayer VARSEG(VIDEO%(0))




a = PIXYunpackImage("SPR1", VARSEG(VIDEO%(0)), 0, 0)

' ---- Fire place ----
I2 = 0
FOR i = 0 TO 4
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0 + (i * 32), 0, 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 60 + I2
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 32 + (i * 32), 0, 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 61 + I2
  I2 = I2 + 2
NEXT


' ---- Player animations ----
FOR i% = 0 TO 9
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0 + (i * 21), 68, 21, 28
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 80 + i%
NEXT
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 168, 67, 18, 29
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 88
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 186, 65, 19, 31
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 89
FOR i% = 0 TO 3
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 205 + (i * 19), 68, 19, 28
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 90 + i%
NEXT



' ---- Items ----
X% = 0
Y% = 32
FOR i% = 0 TO 11
  PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), (X% * 16), Y%, 16, 16
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 100 + i%
  X% = X% + 1
  IF X% = 6 THEN
    X% = 0
    Y% = Y% + 16
  END IF
NEXT


' ---- INFO sprites ----
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 117, 24, 6
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 140
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 123, 24, 6
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 141
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 129, 24, 6
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 142
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 24, 117, 18, 18
PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 143

' ---- TIME's up ----
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 136, 134, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 150

' ---- GO sprite ----
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 42, 109, 82, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 151


' ---- INGAME menu ----
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 133, 97, 165, 25
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 152
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 133, 122, 165, 25
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 153
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 133, 147, 165, 25
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 154
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 133, 172, 165, 23
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 155


PIXYboxF &HA000, 0, 0, 319, 199, 0
PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0

PIXYcloseDataFile



END SUB

SUB LoadLevelMap


CLOSE
OPEN FileName FOR INPUT AS #2

' ---- TILE Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    INPUT #2, i%
    PIXYsetTileMap X%, Y%, i%
  NEXT
NEXT


SELECT CASE Level

  CASE 1
    TimerCount = 75
  CASE 2
    TimerCount = 75
  CASE 3
    TimerCount = 85
  CASE 4
    TimerCount = 90
  CASE 5
    TimerCount = 82
  CASE 6
    TimerCount = 110
  CASE 7
    TimerCount = 80
  CASE 8
    TimerCount = 90
  CASE 9
    TimerCount = 160
END SELECT


PlayerX = 160
PlayerY = 0
LiftX = 0
LiftY = 0
SLiftY = 0
ELiftY = 0
LiftDir = UP
LiftArea = 0

FOR a = 0 TO 4
  BallX(a) = -1
  BallY(a) = 0
  BallSX(a) = -1
  BallSY(a) = 0
  BallA(a) = 1
  BallB(a) = 16
  BallDir(a) = DOWN
NEXT
BallNr = -1

FOR a = 0 TO 4
  DropX(a) = -1
  DropY(a) = 0
  DropA(a) = 0
NEXT
DropNr = -1



' ---- ACTION Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    INPUT #2, i%
    PIXYsetActionMap X%, Y%, i%
    IF i% = 7 THEN
      IF LiftArea = 0 THEN SLiftY = Y% * 32
      LiftArea = LiftArea + 1
      LiftX = X% * 32
      LiftY = Y% * 32
    END IF
    IF i% = 8 THEN
      PlayerX = (X% * 32): BackGroundX = 2
      IF X% > 6 THEN
        PlayerX = 160
        BackGroundX = ((X% - 5) * 32)
      END IF
      IF X% > (51) THEN
        PlayerX = ((X% - 51) * 32)
        BackGroundX = (51) * 32
      END IF
      PlayerY = Y% * 32
    END IF
    IF i% = 14 THEN
      DropNr = DropNr + 1
      DropX(DropNr) = X% * 32
      DropY(DropNr) = Y% * 32
    END IF
    IF i% = 20 THEN
      BallNr = BallNr + 1
      BallX(BallNr) = X% * 32
      BallY(BallNr) = Y% * 32
      BallSX(BallNr) = X% * 32
      BallSY(BallNr) = Y% * 32
    END IF
  NEXT
NEXT

CLOSE #2

ELiftY = (LiftY + 32)



END SUB

SUB Menu


IF MusicEnabled = TRUE THEN
  StopMusic
  StopOutput
  UnloadModule
  PlaySong "Intro"
END IF


PIXYpalOff

a = PIXYopenDataFile("DATA\PIXY2.DAT", "PIXY2")
IF NOT a = 0 THEN ErrorHandler "Couldn't open PIXY2.BIN" + STR$(a)


a = PIXYunpackImage("MENU1", VARSEG(VIDEO%(0)), 0, 0)

PIXYboxF &HA000, 0, 0, 319, 199, 0
PIXYcloseDataFile

PIXYpalOff
PIXYboxF VARSEG(VIDEO%(0)), 100, 110, 115, 150, 0
PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + 13, 100, 110
PIXYtoScreen VARSEG(VIDEO%(0))
PIXYfadeIn Pal


Y% = 110
Y2% = 110

DO

' ---- CONTROL Menu
IF PIXYkey(72) THEN Y2% = 110
IF PIXYkey(80) THEN Y2% = 130
IF PIXYkey(28) THEN
  PIXYfadeToBlack
  IF Y% = 110 THEN EXIT DO
  IF Y% = 130 THEN EndProgram
END IF

IF Y2% > Y% THEN Y% = Y% + 1
IF Y2% < Y% THEN Y% = Y% - 1

PIXYboxF VARSEG(VIDEO%(0)), 100, 110, 115, 150, 0
PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + 13, 100, Y%



' ---- SHOW result on screen ----
PIXYtoScreen VARSEG(VIDEO%(0))
PIXYwait

LOOP



END SUB

SUB PauseGame

TIMER OFF

WaitKey 25

i% = 0
DO

IF PIXYkey(2) THEN WaitKey 25: LoadNewLevel = TRUE: EXIT DO
IF PIXYkey(3) THEN WaitKey 25: MaxJump = 16: EXIT DO
IF PIXYkey(4) THEN
  WaitKey 25
  TimerCount = TimerCount + 10
  IF TimerCount > 199 THEN TimerCount = 199
  EXIT DO
END IF

IF PIXYkey(25) THEN WaitKey 25: EXIT DO


  i% = i% + 1
  IF i% = 40 THEN i% = 0
  IF i% > 29 THEN PIXYtoScreen VARSEG(VIDEO%(0))
  IF i% < 30 THEN PIXYprint "Pause", &HA000, 140, 50, 1
  PIXYwait
LOOP


TIMER ON


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


OverRate& = StartOutput(5, 0)
StartMusic



END SUB

SUB ShowActions


FOR X% = INT((BackGroundX + 32) / 32) TO INT((BackGroundX + 288) / 32)
  FOR Y% = 0 TO 5
  
    a% = PIXYgetActionMap(X%, Y%)
    IF a% > 8 AND a% < 20 AND NOT a% = 14 THEN PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + a%, (X% * 32 - BackGroundX) + 12, Y% * 32
    IF a% > 20 AND a% < 50 THEN PIXYputThings VARSEG(VIDEO%(0)), (32 - 21) + a%, (X% * 32 - BackGroundX), Y% * 32
    IF a% = 7 THEN PIXYputThings VARSEG(VIDEO%(0)), 37, (LiftX - BackGroundX), LiftY
   


    ' ---- GET an Item ----
    IF a% > 8 AND a% < 20 AND NOT a% = 14 THEN
      IF (BackGroundX + PlayerX + 10) > (X% * 32) AND (BackGroundX + (PlayerX - 20)) < (X% * 32) THEN
        IF (PlayerY + 16) > (Y% * 32) AND (PlayerY - 1) < (Y% * 32) THEN
          IF a% = 19 THEN
            PIXYsetActionMap X%, Y%, 0
            KeyActive = TRUE
            HearSample 34
          ELSE
            IF CurrentItem = 0 AND a% < 20 AND NOT a% = 13 THEN
              PIXYsetActionMap X%, Y%, 0
              CurrentItem = a%
              HearSample 35
            END IF
            IF a% = 13 THEN
              PIXYsetActionMap X%, Y%, 0
              TimerCount = TimerCount + 10
              HearSample 35
            END IF
          END IF
        END IF
      END IF
    END IF
    ' ---- OPEN door ----
    IF a% = 25 THEN
      IF (BackGroundX + PlayerX + 20) > (X% * 32) AND (BackGroundX + (PlayerX - 10)) < (X% * 32) THEN
        IF (PlayerY + 10) > (Y% * 32) AND (PlayerY - 4) < (Y% * 32) THEN
          IF KeyActive = TRUE THEN
            PIXYsetActionMap X%, Y%, 0
            KeyActive = FALSE
            HearSample 33
          ELSE
            PX1 = -1
          END IF
        END IF
      END IF
    END IF
    IF a% = 34 THEN
      IF (BackGroundX + PlayerX) > (X% * 32) AND (BackGroundX + (PlayerX - 30)) < (X% * 32) THEN
        IF (PlayerY + 10) > (Y% * 32) AND (PlayerY - 4) < (Y% * 32) THEN
          IF KeyActive = TRUE THEN
            PIXYsetActionMap X%, Y%, 0
            KeyActive = FALSE
            HearSample 33
          ELSE
            PX2 = -1
          END IF
        END IF
      END IF
    END IF

  NEXT
NEXT






' ---- CONTROL Lift ----
IF LiftArea > 0 THEN
  IF LiftDir = UP THEN
    LiftY = LiftY - 1
    IF LiftY < SLiftY THEN LiftDir = DOWN
  END IF
  IF LiftDir = DOWN THEN
    LiftY = LiftY + 1
    IF LiftY > ELiftY THEN LiftDir = UP
  END IF
END IF





' ---- Show & Control BALLS ----
FOR i = 0 TO 4
  IF BallX(i) > -1 THEN

    IF (PlayerX + BackGroundX) + 200 > BallX(i) AND (PlayerX + BackGroundX) - 200 < BallX(i) AND (BallX(i) - BackGroundX) > 20 THEN
      PIXYputEvilItem VARSEG(VIDEO%(0)), 111, (BallX(i) - BackGroundX), BallY(i)
     
      BallX(i) = BallX(i) - 1
      IF BallDir(i) = DOWN THEN
        BallY(i) = BallY(i) + BallA(i)
        BallA(i) = BallA(i) + 1
        IF BallA(i) > BallB(i) THEN BallA(i) = BallB(i)
        IF BallY(i) > 146 + BallB(i) THEN HearSample 31: BallDir(i) = UP
      END IF
      IF BallDir(i) = UP THEN
        BallY(i) = BallY(i) - BallA(i)
        BallA(i) = BallA(i) - 1
        IF BallA(i) < 0 THEN
          BallDir(i) = DOWN
          BallA(i) = 0
          BallB(i) = BallB(i) - 1
        END IF
      END IF
     
      ' If a ball should bounce off the screen
      IF BallB(i) < 1 THEN BallY(i) = BallY(i) + 1
      IF BallY(i) > 210 THEN
        BallX(i) = BallSX(i)
        BallY(i) = BallSY(i)
        BallA(i) = 1
        BallB(i) = 16
        BallDir(i) = DOWN
      END IF

      ' If player touch a ball
      IF PlayerFlash = 0 THEN
        IF (BackGroundX + PlayerX + 20) > BallX(i) AND (BackGroundX + (PlayerX - 20)) < BallX(i) THEN
          IF (PlayerY + 20) > BallY(i) AND (PlayerY - 4) < BallY(i) THEN
            PlayerFlash = 40
            HearSample 32
            TimerCount = TimerCount - 3
          END IF
        END IF
      END IF

    END IF
  END IF
NEXT




' ---- Show & Control DROPS ----
DropSpeed = DropSpeed + 1
FOR i = 0 TO 4
 
  IF DropSpeed > 2 THEN
    IF i = 4 THEN DropSpeed = 0
    DropA(i) = DropA(i) + 1
  END IF

  IF DropX(i) > -1 THEN

    IF (PlayerX + BackGroundX) + 170 > DropX(i) AND (PlayerX + BackGroundX) - 200 < DropX(i) AND (DropX(i) - BackGroundX) > 20 THEN
      PIXYputEvilItem VARSEG(VIDEO%(0)), 105, (DropX(i) - BackGroundX), DropY(i)
    
      DropY(i) = DropY(i) + DropA(i)
     
      IF DropY(i) > 190 THEN
        DropY(i) = -16
        DropA(i) = 0
        HearSample 36
      END IF

      ' If player touch a Drop
      IF PlayerFlash = 0 THEN
        IF (BackGroundX + PlayerX + 20) > DropX(i) AND (BackGroundX + (PlayerX - 20)) < DropX(i) THEN
          IF (PlayerY + 10) > DropY(i) AND (PlayerY - 4) < DropY(i) THEN
            PlayerFlash = 40
            HearSample 32
            TimerCount = TimerCount - 3
          END IF
        END IF
      END IF

    END IF
  END IF
NEXT




END SUB

SUB ShowInformation

PIXYborder VARSEG(VIDEO%(0))

IF ShowFPS = TRUE THEN PIXYprint "FPS:" + STR$(FPSCount), VARSEG(VIDEO%(0)), 40, 4, 1

IF TimerCount < 1 THEN TimerCount = 0

PIXYputInfo VARSEG(VIDEO%(0)), 141, 2, 60
PIXYprint LTRIM$(STR$(TimerCount)), VARSEG(VIDEO%(0)), 4, 80, FontColour

PIXYputInfo VARSEG(VIDEO%(0)), 140, 292, 20
PIXYprint STR$(PlayerLives), VARSEG(VIDEO%(0)), 292, 40, 199

PIXYputInfo VARSEG(VIDEO%(0)), 142, 292, 80
PIXYputBox VARSEG(VIDEO%(0)), 143, 292, 100
IF CurrentItem > 0 THEN PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + CurrentItem, 293, 101

PIXYputBox VARSEG(VIDEO%(0)), 143, 292, 130
IF KeyActive > 0 THEN PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + 19, 293, 131

IF TimerCount < 11 THEN
  FontColour = FontColour + 1
  IF FontColour > 202 THEN FontColour = 197
END IF

IF TimerCount < 1 THEN TimeUP


END SUB

SUB ShowPlayer

IF PlayerFlash > 0 THEN
  PlayerFlash = PlayerFlash - 1
  IF INT(PlayerFlash / 2) = PlayerFlash / 2 THEN EXIT SUB
END IF

IF PlayerDIR = RIGHT THEN
  IF PlayerAnimation = STAND THEN PIXYputPixy VARSEG(VIDEO%(0)), 80, PlayerX, PlayerY + 4, 21, 28
  IF PlayerAnimation = WALK THEN PIXYputPixy VARSEG(VIDEO%(0)), 81 + PlayerAniCount, PlayerX, PlayerY + 4, 21, 28
  IF PlayerAnimation = JUMP THEN PIXYputPixy VARSEG(VIDEO%(0)), 88, PlayerX, PlayerY + 3, 18, 29
  IF PlayerAnimation = FALL THEN PIXYputPixy VARSEG(VIDEO%(0)), 89, PlayerX, PlayerY + 1, 19, 31
END IF

IF PlayerDIR = LEFT THEN
  IF PlayerAnimation = STAND THEN PIXYputPixy2 VARSEG(VIDEO%(0)), 80, PlayerX, PlayerY + 4, 21, 28
  IF PlayerAnimation = WALK THEN PIXYputPixy2 VARSEG(VIDEO%(0)), 81 + PlayerAniCount, PlayerX, PlayerY + 4, 21, 28
  IF PlayerAnimation = JUMP THEN PIXYputPixy2 VARSEG(VIDEO%(0)), 88, PlayerX, PlayerY + 3, 18, 29
  IF PlayerAnimation = FALL THEN PIXYputPixy2 VARSEG(VIDEO%(0)), 89, PlayerX, PlayerY + 1, 19, 31
END IF

IF PlayerAnimation = CRAWL THEN PIXYputPixy VARSEG(VIDEO%(0)), 90 + PlayerCrawlCount, PlayerX, PlayerY + 4, 19, 28

' ---- Control the walking animations ----
PlayerAniCount2 = PlayerAniCount2 + 1
IF PlayerAniCount2 = 3 THEN
  PlayerAniCount2 = 0
  PlayerAniCount = PlayerAniCount + 1
  IF PlayerAniCount > 6 THEN PlayerAniCount = 0
END IF

IF PlayerCrawlCount2 = 3 THEN
  PlayerCrawlCount2 = 0
  PlayerCrawlCount = PlayerCrawlCount + 1
  IF PlayerCrawlCount > 3 THEN PlayerCrawlCount = 0
END IF



END SUB

SUB ShowSnow (Colour%, Y2%)

  ' ---- The SNOW ----
  FOR I3 = 0 TO 49
    PIXYpset VARSEG(VIDEO%(0)), SnowX(I3), SnowY(I3), Colour% + SnowSpeed(I3)
    IF SnowDir(I3) = RIGHT THEN
      SnowX(I3) = SnowX(I3) + 1
      IF SnowX(I3) > 207 THEN SnowX(I3) = 112
    END IF
    IF SnowDir(I3) = LEFT THEN
      SnowX(I3) = SnowX(I3) - 1
      IF SnowX(I3) < 112 THEN SnowX(I3) = 200
    END IF
    SnowY(I3) = SnowY(I3) + SnowSpeed(I3)
    IF SnowY(I3) > Y2% THEN SnowY(I3) = 60
  NEXT



END SUB

SUB ShowTiles


FOR X% = INT((BackGroundX + 32) / 32) TO INT((BackGroundX + 288) / 32)
  FOR Y% = 0 TO 5
   
    a% = PIXYgetActionMap(X%, Y%)
    IF a% <> 5 AND a% <> 6 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), PIXYgetTileMap(X%, Y%), X% * 32 - BackGroundX, Y% * 32
  
    IF a% = 5 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), 60 + FirePlaceCount, X% * 32 - BackGroundX, Y% * 32
    IF a% = 6 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), 61 + FirePlaceCount, X% * 32 - BackGroundX, Y% * 32
    ' ---- BAG of toys ----
    IF PIXYgetTileMap(X%, Y%) = 30 AND CurrentItem > 0 THEN
      IF (BackGroundX + PlayerX + 20) > (X% * 32) AND (BackGroundX + (PlayerX - 20)) < (X% * 32) THEN
        IF (PlayerY + 10) > (Y% * 32) AND (PlayerY - 4) < (Y% * 32) THEN
          ItemsCollected = ItemsCollected + 1
          IF ItemsCollected = 4 THEN LoadNewLevel = TRUE
          CurrentItem = 0
          HearSample 35
        END IF
      END IF
    END IF


  NEXT
NEXT


FC2 = FC2 + 1
IF FC2 > 5 THEN
  FC2 = 0
  FirePlaceCount = FirePlaceCount + 4
  IF FirePlaceCount > 11 THEN FirePlaceCount = 0
END IF



END SUB

SUB TheEnd

DIM CreditY(5), CreditX(5), CreditA(5), CreditB(5), CreditDir(5)


IF MusicEnabled = TRUE THEN
  StopMusic
  StopOutput
  UnloadModule
  PlaySong "Intro"
END IF

a = PIXYopenDataFile("DATA\PIXY2.DAT", "PIXY2")
IF NOT a = 0 THEN ErrorHandler "Couldn't open PIXY2.BIN"


PIXYfadeToBlack


PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0
a = PIXYunpackImage("END1", VARSEG(VIDEO%(0)), 110, 60)
PIXYgetLayer VARSEG(VIDEO%(0))


' ---- SHOW intro ----
FOR I3 = 0 TO 49
  PIXYpset VARSEG(VIDEO%(0)), SnowX(I3), SnowY(I3), 152 + SnowSpeed(I3)
NEXT

PIXYtoScreen VARSEG(VIDEO%(0))

PIXYfadeIn Pal


FOR i = 0 TO 500
  PIXYputLayer VARSEG(VIDEO%(0))

  ShowSnow 152, 134
 
  IF i = 10 THEN IntroText$ = "All presents have been put"
  IF i = 40 THEN IntroText$ = "into Santa's sack"
  IF i = 70 THEN IntroText$ = "before Christmas eve."
  IF i = 130 THEN IntroText$ = "Thanks little pixy."
  IF i = 160 THEN IntroText$ = "You have done"
  IF i = 190 THEN IntroText$ = "a christmassive job"
  IF i = 220 THEN IntroText$ = "and saved Christmas."
  IF i = 250 THEN IntroText$ = "You are promoted the head pixy"
  IF i = 280 THEN IntroText$ = "of the workshop."
  IF i = 340 THEN IntroText$ = "TMB wishes you"
  IF i = 370 THEN IntroText$ = "a merry Christmas and"
  IF i = 400 THEN IntroText$ = "a happy New Year"
  IF i = 460 THEN IntroText$ = "Thank you for playing"
  
  X = 160 - ((LEN(IntroText$) * 10) / 2)
  PIXYboxF VARSEG(VIDEO%(0)), 0, 140, 319, 150, 0
  FOR I3 = 1 TO LEN(IntroText$)
    IF i > 0 AND i < 100 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 32 + INT(I3 / 2)
    IF i >= 130 AND i < 310 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 64 + INT(I3 / 2)
    IF i >= 340 AND i < 430 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 96 + INT(I3 / 2)
    IF i >= 460 AND i < 490 THEN PIXYprint MID$(IntroText$, I3, 1), VARSEG(VIDEO%(0)), X + (I3 * 10), 140, 194 + INT(I3 / 2)
  NEXT

  IF PIXYkey(28) THEN GOTO QuitEnd
  IF PIXYkey(1) THEN GOTO QuitEnd

  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
  PIXYwait
  PIXYwait
  PIXYwait
NEXT




' ---- Credits ----
PIXYfadeToBlack

FOR i = 0 TO 249
  SnowX(i) = INT((319 - 1 + 1) * RND + 1)
  SnowY(i) = INT((199 - 1 + 1) * RND + 1)
  SnowDir(i) = INT((1 - 0 + 1) * RND + 0)
  SnowSpeed(i) = INT((4 - 1 + 1) * RND + 1)
NEXT


PIXYclearScreen VARSEG(VIDEO%(0)), 0
a = PIXYunpackImage("END2", VARSEG(VIDEO%(0)), 0, 0)
' ---- CREDITS sprites ----
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 0, 165, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 0
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 26, 165, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 1
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 52, 165, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 2
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 78, 165, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 3
PIXYgetFullXMSsprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0, 104, 165, 26
PIXYstoreBIGsprite VARSEG(Sprite%(0)), 4



' ---- SHOW intro ----
FOR I3 = 0 TO 49
  PIXYpset VARSEG(VIDEO%(0)), SnowX(I3), SnowY(I3), 152 + SnowSpeed(I3)
NEXT


PIXYclearScreen &HA000, 0
PIXYfadeIn Pal


FOR i = 0 TO 4
  CreditY(i) = -30
  CreditX(i) = 80
  CreditA(i) = 1
  CreditB(i) = 20
  CreditDir(i) = DOWN
NEXT


I2 = 0
PlayerX = 10
PlayerY = 150
I4 = 0


DO
  PIXYclearScreen VARSEG(VIDEO%(0)), 0


  ' ---- SHOW credits sprites ----
  IF CreditDir(I2) = DOWN THEN
    CreditY(I2) = CreditY(I2) + CreditA(I2)
    CreditA(I2) = CreditA(I2) + 1
    IF CreditA(I2) > CreditB(I2) THEN CreditA(I2) = CreditB(I2)
    IF CreditY(I2) > 150 THEN CreditDir(I2) = UP
  END IF
  IF CreditDir(I2) = UP THEN
    CreditY(I2) = CreditY(I2) - CreditA(I2)
    CreditA(I2) = CreditA(I2) - 1
    IF CreditA(I2) < 0 THEN
      CreditDir(I2) = DOWN
      CreditA(I2) = 0
      CreditB(I2) = CreditB(I2) - 2
    END IF
  END IF
  

  IF CreditB(I2) < 1 THEN
    CreditY(I2) = CreditY(I2) - CreditA(I2)
    CreditA(I2) = CreditA(I2) + 1
    CreditDir(I2) = LEFT
    IF CreditY(I2) < -40 THEN I2 = I2 + 1
    IF I2 > 4 THEN GOTO QuitEnd
  END IF
 
  PIXYputBIG VARSEG(VIDEO%(0)), I2, CreditX(I2), CreditY(I2), 165, 24




  ' ---- SHOW player ----
  IF PlayerDIR = RIGHT THEN PIXYputPixy VARSEG(VIDEO%(0)), 81 + PlayerAniCount, PlayerX, PlayerY + 4, 21, 28
  IF PlayerDIR = LEFT THEN PIXYputPixy2 VARSEG(VIDEO%(0)), 81 + PlayerAniCount, PlayerX, PlayerY + 4, 21, 28

  IF PlayerDIR = RIGHT THEN
    PlayerX = PlayerX + 2
    IF PlayerX > 290 THEN PlayerDIR = LEFT
  END IF
  IF PlayerDIR = LEFT THEN
    PlayerX = PlayerX - 2
    IF PlayerX < 10 THEN PlayerDIR = RIGHT
  END IF

  ' ---- Control the walking animations ----
  I4 = I4 + 1
  IF I4 > 3 THEN
    PlayerAniCount = PlayerAniCount + 1
    IF PlayerAniCount > 6 THEN PlayerAniCount = 0
  END IF
 

  ' ---- The SNOW ----
  FOR I3 = 0 TO 249
    IF I4 > 3 THEN
      IF SnowDir(I3) = RIGHT THEN
        SnowX(I3) = SnowX(I3) + 1
        IF SnowX(I3) > 319 THEN SnowX(I3) = 1
      END IF
      IF SnowDir(I3) = LEFT THEN
        SnowX(I3) = SnowX(I3) - 1
        IF SnowX(I3) < 1 THEN SnowX(I3) = 319
      END IF
      SnowY(I3) = SnowY(I3) + SnowSpeed(I3)
      IF SnowY(I3) > 199 THEN SnowY(I3) = 1
    END IF
    PIXYpset VARSEG(VIDEO%(0)), SnowX(I3), SnowY(I3), 152 + SnowSpeed(I3)
  NEXT

  IF PIXYkey(28) THEN GOTO QuitEnd
  IF PIXYkey(1) THEN GOTO QuitEnd

  IF I4 > 3 THEN I4 = 0

 
  PIXYtoScreen VARSEG(VIDEO%(0))
  PIXYwait
LOOP




QuitEnd:
PIXYfadeToBlack

PIXYcloseDataFile




END SUB

SUB TimeUP

PlayerLives = PlayerLives - 1
IF PlayerLives = -1 THEN
  ToMenu = TRUE
  PIXYfadeToBlack
  EXIT SUB
END IF


PIXYgetLayer VARSEG(VIDEO%(0))

Y% = -30
a% = 1
b% = 20
Dir = DOWN
DO
  IF Dir = DOWN THEN
    Y% = Y% + a%
    a% = a% + 1
    IF a% > b% THEN a% = b%
    IF Y% > 140 THEN Dir = UP ': a% = 0
  END IF
  IF Dir = UP THEN
    Y% = Y% - a%
    a% = a% - 1
    IF a% < 0 THEN
      Dir = DOWN
      a% = 0
      b% = b% - 2
    END IF
  END IF
 
  IF b% < 1 THEN EXIT DO
 
  PIXYputLayer VARSEG(VIDEO%(0))
  PIXYputBIG VARSEG(VIDEO%(0)), 150, 100, Y, 134, 26
  PIXYtoScreen VARSEG(VIDEO%(0))
LOOP

Level = Level - 1
LoadNewLevel = TRUE

PIXYfadeToBlack


END SUB

SUB WaitKey (i%)


DO: LOOP WHILE PIXYkey(i%)



END SUB

