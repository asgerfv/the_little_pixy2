DEFINT A-Z
'$DYNAMIC

DECLARE SUB ControlKeyboard ()
DECLARE SUB EndProgram ()
DECLARE SUB ErrorHandler (Text$)
DECLARE SUB InstallProgram ()
DECLARE SUB LoadLevelMap ()
DECLARE SUB LoadGraphics ()
DECLARE SUB ShowTiles ()

DECLARE SUB ShowCursor ()
DECLARE SUB ShowGraphics ()
DECLARE SUB SaveLevelMap ()


'$INCLUDE: 'MAP-PIXY.BI'



' ---- Activate ErrorHandler ----
ON ERROR GOTO ErrorHandler





' ---- Setup memory ----
CLEAR , , 4096






' ---------- Buffers ----------
DIM SHARED Sprite%(2026), VIDEO%(31999), Font AS STRING * 2305
DIM SHARED Pal AS STRING * 768



' ---- Level data ----
DIM SHARED Filename AS STRING
DIM SHARED Level AS INTEGER
DIM SHARED BackGroundX AS INTEGER
DIM SHARED PX1, PX2, PY1, PY2 AS INTEGER
DIM SHARED CursorX, CursorY AS INTEGER
DIM SHARED SelectedTile, SelectedAction AS INTEGER
DIM SHARED ActionText(20) AS STRING * 15
DIM SHARED FirePlaceCount, FC2 AS INTEGER


' Things that can be troggled
DIM SHARED LoadNewLevel AS INTEGER
DIM SHARED ShowGrid AS INTEGER




InstallProgram

SCREEN 13


Level = 1


NewLevel:
LoadNewLevel = FALSE
FirePlaceCount = 0
FC2 = 0

Filename = "DATA\Level" + LTRIM$(STR$(Level)) + ".LEV"
Filename = LTRIM$(RTRIM$(Filename))

' ---- Begin loading graphics to show loading screen ----
LoadGraphics

LoadLevelMap

ActionText(0) = "Nothing"
ActionText(1) = "Stop tile"
ActionText(2) = "Sto2 - On top"
ActionText(3) = "Ladder"
ActionText(4) = "Bounce"
ActionText(5) = "Fireplace"
ActionText(6) = "Fireplace 2"
ActionText(7) = "Lift Up/Down"
ActionText(8) = "Start position"
ActionText(9) = "Book"
ActionText(10) = "Game boy"
ActionText(11) = "Basket ball"
ActionText(12) = "Car"
ActionText(13) = "Present"
ActionText(14) = "Drop"
ActionText(15) = "Chess board"
ActionText(16) = "Doll"
ActionText(17) = "Teddy bear"
ActionText(18) = "Shaker"
ActionText(19) = "Key"
ActionText(20) = "Ball"

PX1 = 0
PX2 = 0
CursorX = 32
CursorY = 0
BackGroundX = 0 '(50 * 32)
SelectedTile = 0
SelectedAction = 0
ShowGrid = TRUE


DO
ControlKeyboard

ShowGraphics

PIXYborder VARSEG(VIDEO%(0))
ShowCursor
PIXYtoScreen VARSEG(VIDEO%(0))
'PIXYwait

IF LoadNewLevel = TRUE THEN GOTO NewLevel
Count = Count + 1
LOOP







ErrorHandler:
  PIXYcloseDataFile
  PIXYclose

  SCREEN 0
  WIDTH 80, 25
  CLS
  COLOR 15, 4
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
SUB ControlKeyboard


' ---- ESC ----
IF PIXYkey(1) THEN EndProgram

IF PIXYkey(31) THEN
  DO: LOOP WHILE PIXYkey(31)
  SaveLevelMap
END IF

IF PIXYkey(38) THEN
  DO: LOOP WHILE PIXYkey(38)
  LoadNewLevel = TRUE
END IF

FOR I = 2 TO 10
  IF PIXYkey(I) THEN
    DO: LOOP WHILE PIXYkey(I)
    Level = (I - 1)
    Filename = "DATA\Level" + LTRIM$(STR$(Level)) + ".LEV"
    Filename = LTRIM$(RTRIM$(Filename))
  END IF
NEXT


' ---- ENTER ----
IF PIXYkey(28) THEN
  DO: LOOP WHILE PIXYkey(28)
  IF ShowGrid = TRUE THEN
    ShowGrid = FALSE
  ELSE
    ShowGrid = TRUE
  END IF
END IF


' ---- SPACE ----
IF PIXYkey(57) THEN
  IF SelectedAction = 0 THEN PIXYsetTileMap INT((CursorX + BackGroundX) / 32), INT(CursorY / 32), SelectedTile
  PIXYsetActionMap INT((CursorX + BackGroundX) / 32), INT(CursorY / 32), SelectedAction
END IF

' ---- RIGHT ----
IF PIXYkey(77) AND PX1 < 8 THEN PX1 = PX1 + 1
IF NOT PIXYkey(77) AND PX1 > 0 THEN PX1 = PX1 - 1
IF PX1 > 0 THEN
  IF CursorX > 170 THEN
    IF BackGroundX = (51 * 32) THEN
      CursorX = CursorX + PX1
    ELSE
      BackGroundX = BackGroundX + PX1
    END IF
   
  ELSE
    CursorX = CursorX + PX1
  END IF
END IF
IF BackGroundX > (51 * 32) THEN BackGroundX = (51 * 32)
IF CursorX > 287 THEN CursorX = 287


' ---- LEFT ----
IF PIXYkey(75) AND PX2 < 8 THEN PX2 = PX2 + 1
IF NOT PIXYkey(75) AND PX2 > 0 THEN PX2 = PX2 - 1
IF PX2 > 0 THEN
  IF CursorX < 130 THEN
    IF BackGroundX = 0 THEN
      CursorX = CursorX - PX2
    ELSE
      BackGroundX = BackGroundX - PX2
    END IF
  ELSE
    CursorX = CursorX - PX2
  END IF
END IF
IF BackGroundX < 0 THEN BackGroundX = 0
IF CursorX < 32 THEN CursorX = 32


' ---- DOWN ----
IF PIXYkey(80) AND PY1 < 8 THEN PY1 = PY1 + 1
IF NOT PIXYkey(80) AND PY1 > 0 THEN PY1 = PY1 - 1
IF PY1 > 0 THEN CursorY = CursorY + PY1
IF CursorY > (5 * 32) + 27 THEN CursorY = (5 * 32) + 27


' ---- UP ----
IF PIXYkey(72) AND PY2 < 8 THEN PY2 = PY2 + 1
IF NOT PIXYkey(72) AND PY2 > 0 THEN PY2 = PY2 - 1
IF PY2 > 0 THEN CursorY = CursorY - PY2
IF CursorY < 0 THEN CursorY = 0


' ---- ALT = Select Tile ----
IF PIXYkey(56) THEN
  DO: LOOP WHILE PIXYkey(56)
  Y% = INT(SelectedTile / 10)
  X% = ABS((10 * Y%) - SelectedTile)
  DO
    PIXYputLayer VARSEG(VIDEO%(0))
   
    IF PIXYkey(77) AND X% < 9 THEN
      DO: LOOP WHILE PIXYkey(77)
      X% = X% + 1
    END IF
    IF PIXYkey(75) AND X% > 0 THEN
      DO: LOOP WHILE PIXYkey(75)
      X% = X% - 1
    END IF
    IF PIXYkey(80) AND Y% < 5 THEN
      DO: LOOP WHILE PIXYkey(80)
      Y% = Y% + 1
    END IF
    IF PIXYkey(72) AND Y% > 0 THEN
      DO: LOOP WHILE PIXYkey(72)
      Y% = Y% - 1
    END IF
   
    PIXYbox VARSEG(VIDEO%(0)), (X% * 32), (Y% * 32), (X% * 32) + 31, (Y% * 32) + 31, 2
    PIXYpset VARSEG(VIDEO%(0)), (X% * 32) + 16, (Y% * 32) + 16, 2
    PIXYtoScreen VARSEG(VIDEO%(0))
  LOOP UNTIL PIXYkey(56)
  DO: LOOP WHILE PIXYkey(56)
  SelectedTile = (Y% * 10) + X%
END IF




' ---- CTRL = Select Action ----
IF PIXYkey(29) THEN
  DO: LOOP WHILE PIXYkey(29)
  IF SelectedAction > 10 THEN Over = (SelectedAction - 10)
  DO
    IF PIXYkey(80) AND SelectedAction < 50 THEN
      DO: LOOP WHILE PIXYkey(80)
      SelectedAction = SelectedAction + 1
      IF SelectedAction > 10 THEN Over = Over + 1
    END IF
    IF PIXYkey(72) AND SelectedAction > 0 THEN
      DO: LOOP WHILE PIXYkey(72)
      SelectedAction = SelectedAction - 1
      IF SelectedAction > 9 THEN Over = Over - 1
    END IF
 
    ' ---- Page Up ----
    IF PIXYkey(73) AND SelectedAction > 0 THEN
      SelectedAction = SelectedAction - 2
      IF SelectedAction < 0 THEN SelectedAction = 0
      IF SelectedAction > 9 THEN Over = Over - 2
    END IF
    ' ---- Page Down ----
    IF PIXYkey(81) AND SelectedAction < 50 THEN
      SelectedAction = SelectedAction + 2
      IF SelectedAction > 10 THEN Over = Over + 2
    END IF


    ' ---- Background ----
    PIXYboxF VARSEG(VIDEO%(0)), 2, 2, 115, 134, 0
    PIXYbox VARSEG(VIDEO%(0)), 2, 2, 115, 135, 1
    FOR I = 0 TO 50
      Y = (5 + (I * 12)) - (Over * 12)
      IF Y > 3 AND Y < 130 THEN
        IF I < 21 THEN
          PIXYprint ActionText(I), VARSEG(VIDEO%(0)), 5, Y, 2
        ELSE
          PIXYprint "Tile" + STR$(I - 21), VARSEG(VIDEO%(0)), 5, Y, 2
        END IF
      END IF
    NEXT
   

    ' ---- Show image of event ----
    PIXYboxF VARSEG(VIDEO%(0)), 2, 142, 35, 175, 0
    PIXYbox VARSEG(VIDEO%(0)), 2, 142, 35, 175, 1
    IF SelectedAction > 4 THEN
      IF SelectedAction < 7 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), 60 + (SelectedAction - 5), 3, 143
      IF SelectedAction > 8 AND SelectedAction < 21 THEN PIXYputItem VARSEG(VIDEO%(0)), 100 + (SelectedAction - 9), 4, 143
      IF SelectedAction > 20 AND SelectedAction < 50 THEN PIXYputThings VARSEG(VIDEO%(0)), 32 + (SelectedAction - 21), 3, 143
    END IF

    ' ---- Selected item ----
    Y = ((SelectedAction * 12) + 3)
    IF SelectedAction > 10 THEN Y = Y - (Over * 12)
    PIXYbox VARSEG(VIDEO%(0)), 3, Y, 114, Y + 11, 3
    PIXYtoScreen VARSEG(VIDEO%(0))
  LOOP UNTIL PIXYkey(29)
  DO: LOOP WHILE PIXYkey(29)
END IF




END SUB

REM $DYNAMIC
SUB EndProgram




SCREEN 0
WIDTH 80, 25
CLS
COLOR 15, 4
Text$ = "The little Pixy 2 - Level Maker  ver. v1.0 - Shut down"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0

PIXYclose

COLOR 15, 0

Text$ = "Credits": LOCATE 8, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Programming :  AM": LOCATE 10, 40 - (LEN(Text$) / 2): PRINT Text$
Text$ = "Graphics :  TM": LOCATE 11, 40 - (LEN(Text$) / 2): PRINT Text$


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
COLOR 15, 4
TextHead$ = "Error"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(TextHead$) / 2): PRINT TextHead$
COLOR 7, 0
PRINT
PRINT Text$
PRINT
PRINT
PIXYcloseDataFile
PIXYclose



SYSTEM






END SUB

REM $DYNAMIC
SUB InstallProgram

' --------- Install ---------
SCREEN 0
WIDTH 80, 25
CLS
COLOR 15, 4
Text$ = "The little Pixy 2 - Level maker  v1.0 - Startup"
LOCATE 1, 1: PRINT SPACE$(80): LOCATE 1, 40 - (LEN(Text$) / 2): PRINT Text$
COLOR 7, 0
PRINT "Wait a moment.."


PRINT "Free memory....."; FRE(-1)





PRINT "XMS memory......";
Result% = PIXYinit(2000)
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


PIXYpalOff
A = PIXYopenDataFile("DATA\PIXY2.DAT", "PIXY2")
IF NOT A = 0 THEN ErrorHandler "Couldn't open PIXY2.DAT"

A = PIXYunpackFont("FONT", Font)
IF NOT A = 0 THEN ErrorHandler "Where's the FONT?"
PIXYsetFont VARSEG(Font), VARPTR(Font)


A = PIXYunpackImage("T1", VARSEG(VIDEO%(0)), 0, 0)
X% = 0
Y% = 0
FOR I% = 0 TO 59
  PIXYgetFullXMSSprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), (X% * 32), (Y% * 32), 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), I%
  X% = X% + 1
  IF X% = 10 THEN
    X% = 0
    Y% = Y% + 1
  END IF
NEXT
PIXYgetLayer VARSEG(VIDEO%(0))




A = PIXYunpackImage("SPR1", VARSEG(VIDEO%(0)), 0, 0)

' ---- Fire place ----
I2 = 0
FOR I = 0 TO 4
  PIXYgetFullXMSSprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 0 + (I * 32), 0, 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 60 + I2
  PIXYgetFullXMSSprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), 32 + (I * 32), 0, 32, 32
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 61 + I2
  I2 = I2 + 2
NEXT


' ---- Items ----
X% = 0
Y% = 32
FOR I% = 0 TO 11
  PIXYgetFullXMSSprite VARSEG(VIDEO%(0)), VARSEG(Sprite%(0)), (X% * 16), Y%, 16, 16
  PIXYstoreFullXMSSprite VARSEG(Sprite%(0)), 100 + I%
  X% = X% + 1
  IF X% = 6 THEN
    X% = 0
    Y% = Y% + 16
  END IF
NEXT



PIXYboxF VARSEG(VIDEO%(0)), 0, 0, 319, 199, 0
A = PIXYunpackPal("PAL")


PIXYcloseDataFile



END SUB

SUB LoadLevelMap

OPEN Filename FOR INPUT AS #1

' ---- TILE Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    INPUT #1, I%
    PIXYsetTileMap X%, Y%, I%
  NEXT
NEXT

' ---- ACTION Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    INPUT #1, I%
    PIXYsetActionMap X%, Y%, I%
  NEXT
NEXT

CLOSE #1





END SUB

SUB SaveLevelMap

OPEN Filename FOR OUTPUT AS #1

' ---- TILE Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    PRINT #1, PIXYgetTileMap(X%, Y%)
  NEXT
NEXT

' ---- ACTION Map ----
FOR Y% = 0 TO 39
  FOR X% = 0 TO 59
    PRINT #1, PIXYgetActionMap(X%, Y%)
  NEXT
NEXT


CLOSE #1




END SUB

SUB ShowCursor


Y% = CursorY
IF Y% > 160 THEN Y% = 160
X% = CursorX
IF X% > 256 THEN X% = 256
PIXYsolidXMS VARSEG(VIDEO%(0)), SelectedTile, X%, Y%

FOR I% = 0 TO 4
  PIXYpset VARSEG(VIDEO%(0)), CursorX + I%, CursorY + I%, 1 + I%
NEXT



END SUB

SUB ShowGraphics

' ---- Show Tiles ----
FOR X% = INT((BackGroundX + 32) / 32) TO INT((BackGroundX + 288) / 32)
  FOR Y% = 0 TO 5
    A% = PIXYgetActionMap(X%, Y%)
    IF A% <> 5 AND A% <> 6 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), PIXYgetTileMap(X%, Y%), X% * 32 - BackGroundX, Y% * 32
   
    ' ---- Show grid ----
    IF ShowGrid = TRUE THEN PIXYpset VARSEG(VIDEO%(0)), X% * 32 - BackGroundX, Y% * 32, 1

    ' ---- Show Action text ----
    IF A% > 0 AND A% < 10 THEN
      PIXYprint LEFT$(ActionText(A%), 4), VARSEG(VIDEO%(0)), X% * 32 - BackGroundX, Y% * 32, 1
      IF A% = 5 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), 60 + FirePlaceCount, X% * 32 - BackGroundX, Y% * 32
      IF A% = 6 THEN PIXYsolidXMS VARSEG(VIDEO%(0)), 61 + FirePlaceCount, X% * 32 - BackGroundX, Y% * 32
    END IF
    IF A% > 8 AND A% < 21 THEN PIXYputItem VARSEG(VIDEO%(0)), (100 - 9) + A%, (X% * 32 - BackGroundX) + 12, Y% * 32
    IF A% > 20 AND A% < 50 THEN PIXYputThings VARSEG(VIDEO%(0)), (32 - 21) + A%, (X% * 32 - BackGroundX), Y% * 32
   
  NEXT
NEXT

FC2 = FC2 + 1
IF FC2 > 5 THEN
  FC2 = 0
  FirePlaceCount = FirePlaceCount + 4
  IF FirePlaceCount > 11 THEN FirePlaceCount = 0
END IF

PIXYprint "Level :" + STR$(Level), VARSEG(VIDEO%(0)), 131, 5, 0
PIXYprint "Level :" + STR$(Level), VARSEG(VIDEO%(0)), 130, 4, 199


END SUB

