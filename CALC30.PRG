
/* Calc.prg - Finally, one in 5.x code!
 *
 * Author and owner: Touchstone Business Creations, Jim Gale
 *
 * Calc (c) Touchstone Business Creations, Jim Gale, 1991-2022
 *
 *
 * Ver 1.3 - 6/12/91
 * Rev 1.4 - 9/18/91   - change to SINGLE box characters for int'l compat.
 * Rev 1.5 - 6/20/92   - added Position, setup, better use & docs
 *                     - fix   += prob
 *          (9/25/92)  - added Scrolling, better NG, CalcMemory(),
 *                       better UDF usage, proper CalcPos().
 * Rev 2.0 -11/01/93   - Spanish, Mousable, Trig
 * Rev 3.0 -10/03/2022 - removed paid-license requirement, uploaded to GitHub - MIT license
 */

#include "inkey.ch"
#include "set.ch"

#define False .F.
#define True  .T.
#define VERSION   30

#define PRINT_NORMAL  0
#define PRINT_HOLD    1
#define PRINT_HOLDALL 2
#define PRINT_NEVER   3

#define Figure(nVal)  Alltrim(If(nFixed=-1,KillZeros(Str(nVal)),Str(nVal,15,nFixed)))
#define PadL(c1,n1)   (Substr( Space(n1-Len(c1))+c1,1,n1))
Static nMemory:=0, saColors, nReg:=0, z1:=0, z2:=0, saInit:={}, sbCalcExit,;
   saCalcSetp:={}, slEachKey:=False, aScroll:={}, lScrollOff := .N., nScrollPos:=1
Static cPrint:="", nPrint:=-9, sbCalcInkey:={|ct,cl,n|Calckey(n,ct,cl,.T.)}, lMousekey:=.F.
Static nLanguage:=0, nSetDec:=-2, nLastDec:=-1, nTempx, saCalcSetH:={}
Static eTemp

#ifdef TEST
Function Test(cl)
Local GetList:={}, n:=1.77777, n2:=3.22222, c:=Space(10)

   //CalcReg(110000)

   If !Empty(cl)
      CalcLanguage(cl)
      ? "Using "+cl
   Endif

   Set Key K_F1 to CALCULATOR
   SetKey(K_ALT_E,{|| CalcLanguage("ENG"),"" })
   SetKey(K_ALT_S,{|| CalcLanguage("SPA"),"" })
   SetKey(K_ALT_G,{|| CalcLanguage("GER"),"" })
   SetKey(K_ALT_T,{|| CalcLanguage("DUT"),"" })
   SetKey(K_ALT_P,{|| CalcLanguage("POR"),"" })

// If CM_IsMouse()
//    CM_Init()
// Endif

   ? Calculator()

Return NIL
#endif

Function CalcInit(aColors,aInit)
Local xInit:=saInit
   saColors:=aColors
   If ValType(aInit)="A"
      saInit:=aInit
   Endif
Return xInit

Function CalcUDF(bCalcExit,lEachKey)
Local blCalcExit := sbCalcExit
   If ValType(bCalcExit)="B"
      sbCalcExit := bCalcExit
   Endif
   If ValType(lEachKey)="L"
      slEachKey  := lEachKey
   Endif
Return blCalcExit

Function CalcPos(aCalcSetup)
Local alCalcSetup:=saCalcSetp
   If ValType(aCalcSetup)="A"
      saCalcSetp := aCalcSetup
   Endif
Return alCalcSetup

Function CalcHPos(aCalcSetup)
Local alCalcSetup:=saCalcSetH
   If ValType(aCalcSetup)="A"
      saCalcSetH := aCalcSetup
   Endif
Return alCalcSetup

Function CalcMemory(nNewMem)
Local nOldMem := nMemory
   If ValType(nNewMem)="N"
      nMemory := nNewMem
   Endif
Return nOldMem

Function CalcDec(nNewDec) //-2 = Use default from get system OR inputted var.
Local nOldDec := nSetDec  //-1 = Set Floating (always)
   If ValType(nNewDec)="N"//0-9? = Set Decimals!
      nSetDec:=nNewDec
   Endif
Return nOldDec

Function CalcReg(nRegL)
   If nReg=0 .or. nRegL=-1
      nReg:=nRegL
   Endif
Return NIL

//0=Normal Op. 1=Net Hold for operation, then print, 2=Net Hold for app. or 32K
//ONLY VALID ON #2: (-1)prints, (-2)=cancel
Function CalcPrint(nNewPrint)
Local nOldPrint := nPrint
   If nPrint=-9 //not used yet!
      nPrint := If(Empty(NetName()),0,1)
      nOldPrint := nPrint
   Endif
   If ValType(nNewPrint)="N"
      If nNewPrint = -1    //print all now! and purge!
         Set Print ON
         Set Console OFF
         ?? cPrint
         If !Right(cPrint,1)==Chr(12)
            Eject
         Endif
         Set Console ON
         Set Print OFF
         cPrint := ""
      Elseif nNewPrint=-2
         cPrint := ""
      Elseif nNewPrint>-1 .and. nNewPrint<4 .and. nNewPrint=Int(nNewPrint)
         nPrint := nNewPrint
      Endif
   Endif
Return nOldPrint

Function CalcPTape(cNewPrint)
Local cOldPrint := cPrint
   If ValType(cNewPrint)="C"
      cPrint := cNewPrint
   Endif
Return cOldPrint

Function CalcInkey(bCalcInkey)
Local blCalcInkey := sbCalcInkey
   If ValType(bCalcInkey)="B"
      sbCalcInkey := bCalcInkey
   Endif
Return blCalcInkey

Function CalcLanguage(cLang)
Local cOldLang:={"ENGLISH","SPANISH","GERMAN","DUTCH","PORTUGUESE"}[nLanguage+1]
   If ValType(cLang)="C"
      Do Case
         Case Upper(cLang)="ENG"
            nLanguage:=0
         Case Upper(cLang)="SPA"
            nLanguage:=1
         Case Upper(cLang)="GER"
            nLanguage:=2
         Case Upper(cLang)="DUT"
            nLanguage:=3
         Case Upper(cLang)="POR"
            nLanguage:=4
      Endcase
   Endif
Return cOldLang

Static Function CalcCkDec(oGet)
Static cDec:="."
   If ValType(oGet)="O"
      If !Empty(oGet:picture ) .and. oGet:picture = "@" ; //british format
         .and. AtIn("E",oGet:picture)<AtIn(" ",oGet:picture)
         cDec:=","
      Else
         cDec:="."
      Endif
      Return oGet
   Elseif PCount()=1
      Return NIL
   Endif
Return cDec

Static Function AtIn(c,cString)
Return If(c$cString,At(c,cString),Len(cString)+1)

Function Calculator(nInit2,lInit2)
//:Save Video and printer status
Local aGet:=CalcCkDec(GetActive()), nLen:=0, cDec:=CalcCkDec()
Local nDec2:=If(!Empty(aGet),MakeDec(aGet:buffer,aGet:type),MakeDec(nInit2))
Local lInit:=(If(ValType(lInit2)="L",lInit2,(!Empty(aGet).and.aGet:type$"NCM").or.ValType(nInit2)="N"))
Local nInit:=If(ValType(nInit2)="N",nInit2,If(lInit.and.aGet:type="N",;
         If(nDec2>-1,Val(Str(aGet:varGet(),Len(aGet:buffer),nDec2)),Val(Str(aGet:varGet()))),0))
Local ct:=CalcPos2(1,MaxRow()-12), cl:=CalcPos2(2,If(Col()>(MaxCol()+1)/2,0,MaxCol()-24))
Local oError:=ErrorBlock({|e|eTemp:=e,Break(e)})
Local lMCurs:=CM_Cursor(.F.)
Local aScreen:={SaveScreen(0,cl,ct+12,cl+24),SetCursor(0),;
         Row(),Col(),SetColor()}
Local aSettings:={Set(2,If(lInit,("."$AllTrim(Str(nInit)).or.nDec2>-1).and.!nSetDec=-1,.F.)),Set(3,If(Set(2),nDec2 /*Len(AllTrim(Str(nInit)))-At(".",AllTrim(Str(nInit)))*/,10))}
Local nKey, cKey, cLine:=Alltrim(If(nSetDec=-1,Str(nInit),Str(nInit,20,nDec2))), xRet, cOldValue:="", nCurValue, cOldOp:=" "
Local lLineDone:=lInit, nLine, nKey2, cKey2, aLevel:={}, aLevPtr:=0, nLKey:=Lastkey()
Local nCeil:=ct, lPrint:=.F., lParen:=.F., bSetKey:=SetKey(nLKey,NIL), x, cClrTemp, y, z0
Local nFixed:=If(Set(2),Set(3),nTempX), cLKey, cLastVal:=cLine, lEject:=.F., cl2:=If(cl>40,0,45)
Local lPaper:=False, lNumLock := FT_NUMLOCK(.T.), ct2, n1, n2, lt2

   If nPrint=-9 //not used yet!
      nPrint := If(Empty(NetName()),0,1)
   Endif

   aScroll := {} ; nScrollPos := 1 ; lScrollOff := .N.

   If ValType(saColors)="C"
      SetColor(saColors)
   Elseif ValType(saColors)="A"
      If (x:=AScan(saColors,{|elem|aScreen[5]=Upper(Substr(elem[1],1,At(",",elem[1])))}))>0
         SetColor(saColors[x,2])
      Endif
   Elseif ValType(saColors)="U"
      If IsColor()
         SetColor("W+/B")
      Endif
   Endif

   If ValType(sbCalcExit)="B"
      ErrorBlock(oError)
      If ValType(xRet:=Eval(sbCalcExit,ProcName(),VERSION,ReadVar(),Val(cLine),cLine,0/*Init*/,SetColor(),0))="L" .and. xRet
         SetCursor(aScreen[2])
         Set Decimals to (aSettings[2])
         Set Fixed (aSettings[1])
         SetKey(nLKey,bSetKey)
         SetColor(aScreen[5])
         FT_NUMLOCK(lNumLock)
         Return 0
      Endif
      ErrorBlock({||Break(NIL)})
   Endif

   COTAN(9)

   If !Empty(aGet) .and. aGet:type$"CNM"
     // If aGet:type="N"
         nLen:=Len(aGet:buffer)          //Str(aGet:varGet()))
         //nDec:=aGet:decPos
         //nDec2:=nLen-nDec
     // Elseif aGet:type="C"
         //nLen:=Len(aGet:buffer)
     // Endif
   Endif

   If Valtype(xRet)="C"
      Keyboard xRet
   Elseif ValType(xRet)="N"
      cLine:=Figure(xRet)
      cLastVal:=cLine
      lLineDone:=.T.
   Endif

   @ct+ 0,cl SAY "�����������������������Ŀ"
   @ct+ 1,cl SAY "�                       �"
   @ct+ 2,cl SAY "�����������������������Ĵ"
   @ct+ 3,cl SAY "�ESC� / � * � - � C �AC �"
   @ct+ 4,cl SAY "�����������������������Ĵ"
   @ct+ 5,cl SAY "� 7 � 8 � 9 �   �M+ �MR �"
   @ct+ 6,cl SAY "�����������Ĵ + �������Ĵ"
   @ct+ 7,cl SAY "� 4 � 5 � 6 �   �M- �MC �"
   @ct+ 8,cl SAY "�����������������������Ĵ"
   @ct+ 9,cl SAY "� 1 � 2 � 3 �=E � % � P �"
   @ct+10,cl SAY "�����������Ĵ n �������Ĵ"
   @ct+11,cl SAY "�   0   � "+cDec+" � t � F � H �"
   @ct+12,cl SAY "�������������������������"

   cKey:="~"

   If CM_IsMouse()
      CM_Init()
   Endif

   Do While .T.

      BEGIN SEQUENCE

      Do While .T.
      //:Show Line

         @ct+1,cl+1 Say cOldOp  //do inverse!
         If cOldOp="("
            cOldOp:=" "
         Endif
         @ct+1,cl+2 Say If(nMemory==0.0," ","M")
         @ct+1,cl+3 Say If(nFixed=-1," ","F")

         If "***"$cLine   //OVERFLOW ERR
            If nLanguage=1
               CalcMsg("RESULTADO MUY LARGO",ct,cl)
            ElseIf nLanguage=3
               CalcMsg("OVERLOOP ERROR     ",ct,cl)
            ElseIf nLanguage=4
               CalcMsg("ERRO DE OVERFLOW   ",ct,cl)
            Else
               CalcMsg("OVERFLOW ERR       ",ct,cl)
            Endif
            lLineDone:=.F.
            cLine:="0"
            Loop
         Endif

         If cDec=","
            @ct+1,cl+7 Say StrTran(PadL(cLine,16),".",",")
         Else
            @ct+1,cl+7 Say PadL(cLine,16)
         Endif

         Light(cKey,ct,cl)
         If cKey="P"
            If lPrint
               cClrTemp:=SetColor("N/W")
               @ ct+9,cl+21 Say " P "
               SetColor(cClrTemp)
            Else
               @ ct+9,cl+21 Say " P "
            Endif
         Endif
         cLKey:=cKey

         CM_On()
         cKey:=Upper(Chr(nKey:=Eval(sbCalcInkey,ct,cl)))
         CM_Off()

         If slEachKey .and. ValType(sbCalcExit)="B"
            ErrorBlock(oError)
            If ValType(xRet:=Eval(sbCalcExit,ProcName(),VERSION,ReadVar(),Val(cLine),cLine,1/*Key*/,SetColor(),nKey))="L" .and. xRet
               SetCursor(aScreen[2])
               Set Decimals to (aSettings[2])
               Set Fixed (aSettings[1])
               SetKey(nLKey,bSetKey)
               SetColor(aScreen[5])

               Break
            Endif
            ErrorBlock({||Break(NIL)})

            If ValType(xRet)="N"
               cLine:=Figure(xRet)
               cLastVal:=cLine
               lLineDone:=.T.
            Elseif ValType(xRet)="C"
               Keyboard xRet
               Loop
            Endif
         Endif

         Do Case
            Case !SetKey(nKey)=NIL .and. !nKey=nLKey
               ErrorBlock(oError)
               xRet:=Eval(SetKey(nKey),ProcName(),VERSION,ReadVar(),Val(cLine),cLine)
               ErrorBlock({||Break(NIL)})
               If ValType(xRet)="N"
                  cLine:=Figure(xRet)
                  cLastVal:=cLine
                  lLineDone:=.T.
               Elseif ValType(xRet)="C"
                  Keyboard xRet
                  Loop
               Endif

            Case nKey=K_ALT_F12
               If Inkey(.5)=K_ALT_F11 .and. Inkey(.5)=K_ALT_F12
                  cLine:=Figure(nReg)
                  cLastVal:=cLine
                  lLineDone:=.T.
               Endif

            Case nKey = 8  //backspace
               If Len(cLine)=1
                  cLine:="0"
               Else
                  cLine:=Substr(cLine,1,Len(cLine)-1)
               Endif

            Case !cKey $ "0123456789"+cDec+".+-*/=CM%FAPH()"+Chr(27)+Chr(13)+Chr(10)+;
                 Chr(K_CTRL_LEFT)+Chr(K_CTRL_RIGHT)+Chr(K_UP)+Chr(K_DOWN)+;
                 Chr(K_PGUP)+Chr(K_PGDN)+Chr(K_HOME)+Chr(K_END)

               If ValType(sbCalcExit)="B" //special key handler
                  ErrorBlock(oError)
                  If ValType(xRet:=Eval(sbCalcExit,ProcName(),VERSION,ReadVar(),Val(cLine),cLine,2/*Exception*/,SetColor(),nKey))="L" .and. xRet
                     SetCursor(aScreen[2])
                     Set Decimals to (aSettings[2])
                     Set Fixed (aSettings[1])
                     SetKey(nLKey,bSetKey)
                     SetColor(aScreen[5])

                     Break
                  Endif
                  ErrorBlock({||Break(NIL)})

                  If ValType(xRet)="N"
                     cLine:=Figure(xRet)
                     cLastVal:=cLine
                     lLineDone:=.T.
                  Elseif ValType(xRet)="C"
                     Keyboard xRet
                     Loop
                  Endif
               Endif

               Loop

            Case nKey=10 .and. lInit .and. "*"$Str(Val(cLine),nLen,nDec2)
               If nLanguage=1
                  Alert("CALC: El resultado es muy largo para ser transferido.")
               Elseif nLanguage=2
                  Alert("CALC: Ergebnis zu gro� zum �bernehmen.")
               Elseif nLanguage=3
                  Alert("CALC: Uitkomst te groot om te kopieren.")
               Elseif nLanguage=4
                  Alert("CALC: Resultado demasiado longo para transferir.")
               Else
                  Alert("CALC: Result is too large to transfer.")
               Endif
               Loop

            Case  cKey $ "0123456789."+cDec .and. !(cKey="0" .and. cLine=="0") ;
                 .and. !((cKey=cDec.or.cKey=".") .and. (cDec$cLine.or."."$cLine) .and. !lLineDone) .and. ;
                  Len(cLine)<15

               If lLineDone
                  cLine:="0"
                  lLineDone:=.F.
               Endif
               If cLine=="0"
                  cLine:=""
               Endif
               cLine:=cLine+If(cKey==cDec,".",cKey)

            Case  cKey ==")".and.aLevPtr=0
               Loop

            Case  cKey $ "+-*/=%)"+Chr(13)+Chr(10)    //operand

               If Substr(cLine,Len(cLine),1)=cDec
                  cLine:=Substr(cLine,1,Len(cLine)-1)
               Endif

               If cKey = Chr(10) .and. !lInit
                  Exit
               Endif

               If lLineDone              //If you typed a num in, save it
                  cLine:=cLastVal
                  If !cOldOp=" " .and. cKey$"+-*/%"
                     cOldOp:=cKey
                  Endif
               Else
                  cLastVal:=cLine
               Endif

               lLineDone:=.T.

               //NEW:6-25-92
               If cLKey$"+-" .and. cKey$"="+Chr(13)+Chr(10)  //*,/ gone
                  nLine:=0
                  cLine:="0"
               Endif

               If cKey=="%"  //If percentage (What to do?)
                  If cOldOp $ "+-"
                     nLine:= Val(cOldValue)*(Val(cLine)/100)
                     cLine:= Figure(nLine)
                     cLastVal:=cLine
                     Loop
                  Elseif cOldOp $ "*/"
                     nLine:= Val(cLine)/100
                     cLine:= Figure(nLine)
                     cKey:="="
                     cLastVal:=cLine
                  Endif
               Endif

               //:Protect div by 0
               If cOldOp$"/%" .and. Val(cLine)==0.0
                  If nLanguage=1
                     CalcMsg("!NO DIVIDA/CERO",ct,cl)
                  ElseIf nLanguage=3
                     CalcMsg("DELEN DOOR 0   ",ct,cl)
                  Else
                     CalcMsg("DIV BY ZERO ERR",ct,cl)
                  Endif
                  lLineDone:=.F.
                  cLine:="0"
                  Loop
               Endif

               Upwards(PadL(If(lParen,"( ","")+cLine,19)+" "+If(nKey=13,"=",cKey),@nCeil,ct,cl,lPrint)
               lPaper:=True
               If lPrint
                  lEject:=.T.
               Endif
               lParen:=.F.

               Begin Sequence
                  nCurValue:=&(cOldValue+cOldOp+cLine)
               Recover
                  nCurValue:=0
               End Sequence

               cOldValue:=Figure(nCurValue)

               cOldOp   :=cKey
               cLine:=cOldValue

               If cOldOp="=" .or. cOldOp=Chr(13)
                  While aLevPtr>0                       //new 9-23-92
                     cLastVal:=cLine
                     cOldValue:=aLevel[aLevPtr,1]
                     cOldOp:=aLevel[aLevPtr,2]
                     aLevPtr--

                     Begin Sequence
                        nCurValue:=&(cOldValue+cOldOp+cLine)
                     Recover
                        nCurValue:=0
                     End Sequence

                     cOldValue:=Figure(nCurValue)

                     cOldOp   :=cKey
                     cLine:=cOldValue
                  Enddo

                  Upwards(PadL(If(nFixed=-1,KillZeros(cOldValue),cOldValue),19)+" T",@nCeil,ct,cl,lPrint)
                  Upwards(Space(21),@nCeil,ct,cl,lPrint)
                  lPaper:=True

                  cOldOp:=" "
                  cOldValue:=" "
                  cLastVal:=cLine
               Endif

               If cOldOp=")"
                  cLastVal:=cLine
                  cOldValue:=aLevel[aLevPtr,1]
                  cOldOp:=aLevel[aLevPtr,2]
                  aLevPtr--
               Endif

               If nKey = 10 .and. lInit     //Ctrl-Return! (Keyboard it!)
                  If !Empty(aGet).and.aGet:type="N"    //if initial field is numeric...

                /*If ValType(saColors)="B"
                     ErrorBlock(oError)
                     If ValType(xRet:=Eval(saColors,ProcName(),VERSION,ReadVar(),Val(cLine),cLine,"INIT",SetColor()))="N"
                        Do Case
                           Case xRet = 0  // Abort Calc completely - no paste
                              Exit
                           Case xRet = 1  // Abort Paste & continue
                              ErrorBlock({||Break(NIL)})
                              Loop
                        Endcase
                     Endif
                     ErrorBlock({||Break(NIL)})
                */
                     ///aGet:varPut(Val(PadL(Str(Val(cLine)
                     //Keyboard Chr(1)+Chr(25)+Chr(1)+Chr(25)+cLine+Chr(13)
                     ///aGet:varPut(Val(cLine))
                     ///Keyboard Chr(1)+Chr(25)+cLine+Chr(13) // kill current & insert this.
                     aGet:pos:=1
                     Keyboard Chr(25)+AllTrim(Str(Val(cLine),nLen,nDec2))+;
                        If(!Set(_SET_CONFIRM).and.(nDec2>0.or.;
                        nLen=Len(AllTrim(Str(Val(cLine),nLen,nDec2)))),;
                        "",Chr(13))
                  Else
                     //If going to push off side,
                     If !Empty(aGet) .and. aGet:pos>(nLen-Len(cLine)+1)
                        aGet:pos:=(nLen-Len(cLine)+1)
                     Endif
                     Keyboard cLine         //else send as is.
                  Endif
                  Exit
               Endif

            Case cKey="C"   //just clear for now
               lLineDone:=.F.
               cLine:="0"

            Case nKey = 27
               Exit

            Case cKey == "H"
               ct2 := Min(Max(ct,10),MaxRow()-12)
               lt2 := .Y.
               If !Empty(saCalcSetH)
                  ct2 := saCalcSetH[1]+10
                  cl2 := saCalcSetH[2]
                  If Len(saCalcSetH)>2
                     If ValType(lt2 := saCalcSetH[3])#"L"
                        lt2:=.Y.
                     Endif
                  Endif
               Endif
               x := SaveScreen(ct2-10,cl2,ct2+12,cl2+34)

               If nLanguage=1
                  @ct2-10,cl2 SAY   "����������Ĵ Calc Ayuda ���������Ŀ"
                  @ct2- 9,cl2 SAY   "�                                 �"
                  @ct2- 8,cl2 SAY   "� AC =Borra todo (excepto memoria)�"
                  @ct2- 7,cl2 SAY   "� C  =Borrar el registro.         �"
                  @ct2- 6,cl2 SAY   "� P  =Switch de la impresara      �"
                  @ct2- 5,cl2 SAY   "� F x=Fijar los decimales a (x)   �"
                  @ct2- 4,cl2 SAY   "�     x=(0-9 fijo, otro flotante) �"
                  @ct2- 3,cl2 SAY   "� %  =Porciento                   �"
                  @ct2- 2,cl2 SAY   "� (  =Empezar un subcalculo       �"
                  @ct2- 1,cl2 SAY   "� )  =Terminar un subcalculo      �"
                  @ct2   ,cl2 SAY   "� =  =Total (y terminar todas los �"
                  @ct2+ 1,cl2 SAY   "�               sub-calculos)     �"
                  @ct2+ 2,cl2 SAY   "� M+ =Sumar a la memoria          �"
                  @ct2+ 3,cl2 SAY   "� M- =Restar de la memoria        �"
                  @ct2+ 4,cl2 SAY   "� M* =Multiplicar por la memoria  �"
                  @ct2+ 5,cl2 SAY   "� M/ =Dividir la memoria          �"
                  @ct2+ 6,cl2 SAY   "� MR =Llamar la memoria           �"
                  @ct2+ 7,cl2 SAY   "� MC =Borrar la memoria           �"
                  @ct2+ 8,cl2 SAY   "� Esc=Salirse de la calculadora   �"
                  @ct2+ 9,cl2 SAY   "� Ctrl-Left / Ctrl-Right =Moverse �"
                  @ct2+10,cl2 SAY   "� Home/End/Up/Down/PgUp/PgDn TAPE �"
                  @ct2+11,cl2 SAY   "� "+If(lInit,"Ctrl-Enter=Tranferir resultado  ",;
                                                Space(32))  +"�"
                  @ct2+12,cl2 SAY   "�����������������������������������"
               Elseif nLanguage=2
                  @ct2-10,cl2 SAY   "�������Ĵ Kalkulator Hilfe ������Ŀ"
                  @ct2- 9,cl2 SAY   "�                                 �"
                  @ct2- 8,cl2 SAY   "� AC  = Alles L�schen au�.Speicher�"
                  @ct2- 7,cl2 SAY   "� C   = Eingabe L�schen           �"
                  @ct2- 6,cl2 SAY   "� P   = Drucken Ein-/Ausschalten  �"
                  @ct2- 5,cl2 SAY   "� F n = Dezim.stellen auf n setzen�"
                  @ct2- 4,cl2 SAY   "�       (0-9 fest, anderes float) �"
                  @ct2- 3,cl2 SAY   "� %   = Prozentwert               �"
                  @ct2- 2,cl2 SAY   "� (   = Subkalkulation - Anfang   �"
                  @ct2- 1,cl2 SAY   "� )   =   Subkalkulation - Ende   �"
                  @ct2   ,cl2 SAY   "� =   = Gesamtwert (und Ende      �"
                  @ct2+ 1,cl2 SAY   "�         aller Subkalkulationen) �"
                  @ct2+ 2,cl2 SAY   "� M+  = Addieren zum Speicher     �"
                  @ct2+ 3,cl2 SAY   "� M-  = Subtrahieren vom Speicher �"
                  @ct2+ 4,cl2 SAY   "� M*  = Multiplizieren m. Speicher�"
                  @ct2+ 5,cl2 SAY   "� M/  = Speicher Dividieren durch �"
                  @ct2+ 6,cl2 SAY   "� MR  = Speicher Zur�ckholen      �"
                  @ct2+ 7,cl2 SAY   "� MC  = Speicher L�schen          �"
                  @ct2+ 8,cl2 SAY   "� Esc = Kalkulator Verlassen      �"
                  @ct2+ 9,cl2 SAY   "� Strg-"+Chr(26)+" / Strg-"+Chr(27)+" = VERSCHIEBEN   �"
                  @ct2+10,cl2 SAY   "� Pos1/Ende/"+Chr(24)+"/"+Chr(25)+"/Bild"+Chr(24)+"/Bild"+Chr(25)+" = TAPE�"
                  @ct2+11,cl2 SAY   "� "+If(lInit,"Strg-� = Ergebnis �BERNEHMEN   ",;
                                                Space(32))  +"�"
                  @ct2+12,cl2 SAY   "�����������������������������������"
               Elseif nLanguage=3
                  @ct2-10,cl2 SAY   "������Ĵ Rekenmachine Help ������Ŀ"
                  @ct2- 9,cl2 SAY   "�                                 �"
                  @ct2- 8,cl2 SAY   "� AC  =Wis alles, behalve geheugen�"
                  @ct2- 7,cl2 SAY   "� C   =Wis invoer                 �"
                  @ct2- 6,cl2 SAY   "� P   =Druk af op papier (aan/uit)�"
                  @ct2- 5,cl2 SAY   "� F n =Stel aantal dec.in 0-9 voor�"
                  @ct2- 4,cl2 SAY   "�     vast, anders vliegende komma�"
                  @ct2- 3,cl2 SAY   "� %   =Procenten                  �"
                  @ct2- 2,cl2 SAY   "� (   =Begin sub-berekening       �"
                  @ct2- 1,cl2 SAY   "� )   =Stop sub-berekening        �"
                  @ct2   ,cl2 SAY   "� =   =Totaliseer (en stop alle   �"
                  @ct2+ 1,cl2 SAY   "�       sub-berekeningen)         �"
                  @ct2+ 2,cl2 SAY   "� M+  =Tel op bij geheugen        �"
                  @ct2+ 3,cl2 SAY   "� M-  =Trek af van geheugen       �"
                  @ct2+ 4,cl2 SAY   "� M*  =Vermenigvuldig met geheugen�"
                  @ct2+ 5,cl2 SAY   "� M/  =Deel door het geheugen     �"
                  @ct2+ 6,cl2 SAY   "� MR  =Roep geheugeninhoud op     �"
                  @ct2+ 7,cl2 SAY   "� MC  =Maak geheugen schoon       �"
                  @ct2+ 8,cl2 SAY   "� Esc =Verlaat Rekenmachine       �"
                  @ct2+ 9,cl2 SAY   "� Ctrl-Left/Ctrl-Right = VERSCHUIF�"
                  @ct2+10,cl2 SAY   "� Home/End///PgUp/PgDn TELSTROOK�"
                  @ct2+11,cl2 SAY   "� "+If(lInit,"Ctrl-Enter = Neem resultaat over",;
                                                Space(32))  +"�"
                  @ct2+12,cl2 SAY   "�����������������������������������"
               Elseif nLanguage=4
                  @ct2-10,cl2 SAY   "�����Ĵ HELP da calculadora �����Ŀ"
                  @ct2- 9,cl2 SAY   "�                                 �"
                  @ct2- 8,cl2 SAY   "� AC  = Limpar (excepto a mem�ria)�"
                  @ct2- 7,cl2 SAY   "� C   = Limpar a entrada          �"
                  @ct2- 6,cl2 SAY   "� P   = Ligar a impressora        �"
                  @ct2- 5,cl2 SAY   "� F n = Fixar decimais em (n)     �"
                  @ct2- 4,cl2 SAY   "�       (0-9 fixa, outra - flut.) �"
                  @ct2- 3,cl2 SAY   "� %   = Percentagem               �"
                  @ct2- 2,cl2 SAY   "� (   = Iniciar um sub-c�lculo    �"
                  @ct2- 1,cl2 SAY   "� )   = Finalizar um sub-c�lculo  �"
                  @ct2   ,cl2 SAY   "� =   = Total (e finalizar todos  �"
                  @ct2+ 1,cl2 SAY   "�               os sub-c�lculos)  �"
                  @ct2+ 2,cl2 SAY   "� M+  = Adicionar � Mem�ria       �"
                  @ct2+ 3,cl2 SAY   "� M-  = Subtrair da Mem�ria       �"
                  @ct2+ 4,cl2 SAY   "� M*  = Multiplicar a Mem�ria     �"
                  @ct2+ 5,cl2 SAY   "� M/  = Dividir a Mem�ria         �"
                  @ct2+ 6,cl2 SAY   "� MR  = Chamar o valor da Mem�ria �"
                  @ct2+ 7,cl2 SAY   "� MC  = Limpar a Mem�ria          �"
                  @ct2+ 8,cl2 SAY   "� Esc = Sa�r da calculadora       �"
                  @ct2+ 9,cl2 SAY   "� Ctrl-Left / Ctrl-Right = Mover  �"
                  @ct2+10,cl2 SAY   "� Home/End/Up/Down/PgUp/PgDn FITA �"
                  @ct2+11,cl2 SAY   "� "+If(lInit,"Ctrl-Enter = Passar o resultado ",;
                                                Space(32))  +"�"
                  @ct2+12,cl2 SAY   "�����������������������������������"
               Else
                  @ct2-10,cl2 SAY   "�������Ĵ Calculator Help �������Ŀ"
                  @ct2- 9,cl2 SAY   "�                                 �"
                  @ct2- 8,cl2 SAY   "� AC  = All Clear (except memory) �"
                  @ct2- 7,cl2 SAY   "� C   = Clear Entry               �"
                  @ct2- 6,cl2 SAY   "� P   = Toggle Print (exit ejects)�"
                  @ct2- 5,cl2 SAY   "� F n = Set Fixed Decimals to (n) �"
                  @ct2- 4,cl2 SAY   "�       (0-9 fix, other to float) �"
                  @ct2- 3,cl2 SAY   "� %   = Percentage                �"
                  @ct2- 2,cl2 SAY   "� (   = Begin a sub-calculation   �"
                  @ct2- 1,cl2 SAY   "� )   =   End a sub-calculation   �"
                  @ct2   ,cl2 SAY   "� =   = Total (and end all sub-   �"
                  @ct2+ 1,cl2 SAY   "�                  calculations)  �"
                  @ct2+ 2,cl2 SAY   "� M+  = Add to Memory             �"
                  @ct2+ 3,cl2 SAY   "� M-  = Subtract from Memory      �"
                  @ct2+ 4,cl2 SAY   "� M*  = Multiply to Memory        �"
                  @ct2+ 5,cl2 SAY   "� M/  = Divide into Memory        �"
                  @ct2+ 6,cl2 SAY   "� MR  = Recall Memory             �"
                  @ct2+ 7,cl2 SAY   "� MC  = Clear Memory              �"
                  @ct2+ 8,cl2 SAY   "� Esc = Quit Calculator           �"
                  @ct2+ 9,cl2 SAY   "� Ctrl-Left / Ctrl-Right = MOVE   �"
                  @ct2+10,cl2 SAY   "� Home/End/Up/Down/PgUp/PgDn TAPE �"
                  @ct2+11,cl2 SAY   "� "+If(lInit,"Ctrl-Enter = PASTE Result",;
                                                Space(25))  +"       �"
                  @ct2+12,cl2 SAY   "�����������������������������������"
               Endif

               If !lt2
                  @ct2-10,cl2 SAY   "���������������������������������Ŀ"
               Endif

               CM_On()
               While Chr(Eval(sbCalcInkey,ct,cl))==Chr(0)
               Enddo
               CM_Off()

               RestScreen(ct2-10,cl2,ct2+12,cl2+34,x)

            Case cKey == "F"
               If nLanguage=1
                  @ ct+1,cl+3 Say "FIJO"
               Elseif nLanguage=2
                  @ ct+1,cl+3 Say "FEST"
               Elseif nLanguage=3
                  @ ct+1,cl+3 Say "VAST"
               Else
                  @ ct+1,cl+3 Say "FIX"
               Endif
               cKey2:=Upper(Chr(nKey2:=Eval(sbCalcInkey,ct,cl,30)))
               If cKey2$"0123456789"
                  Set Fixed ON
                  Set Decimals to (Val(cKey2))
                  nFixed:=Val(cKey2)
               Else
                  nFixed:=-1
                  Set Fixed OFF
                  Set Decimals to (aSettings[2])
               Endif
               If nLanguage#0
                  @ ct+1,cl+3 Say "    "
               Else
                  @ ct+1,cl+3 Say "   "
               Endif

            Case cKey == "M"                         //memory
               cKey2:=Upper(Chr(nKey2:=Eval(sbCalcInkey,ct,cl,30)))
               cKey+=cKey2
               Do Case
                  Case cKey2="+"
                     nMemory+=Val(cLine)
                  Case cKey2="-"
                     nMemory-=Val(cLine)
                  Case cKey2="*"
                     nMemory*=Val(cLine)
                  Case cKey2="/" .and. !Val(cLine)=0
                     nMemory/=Val(cLine)
                  Case cKey2="R"
                     cLine:=Figure(nMemory)
                     cLastVal:=cLine
                     lLineDone:=.T.
                  Case cKey2="C"
                     nMemory:=0
               Endcase

            Case cKey == "A"
               cKey2:=Upper(Chr(nKey2:=Eval(sbCalcInkey,ct,cl,30)))

               If cKey2 == "C"
                  cKey+=cKey2
                  lLineDone:=.F.
                  cLine:="0"
                  cOldValue:=" "
                  cOldOp:=" "
                  aLevPtr:=0
                  aLevel:={}
                  nCeil:=ct
                  RestScreen(0,cl,ct-1,cl+24,aScreen[1])
                  @ ct,cl+ 1 Say Chr(196)
                  @ ct,cl+23 Say Chr(196)
                  lPaper:=False
                  aScroll := {} ; nScrollPos := 1 ; lScrollOff := .N.
               Endif

            Case cKey == "P"
               lPrint:=!lPrint
               If lPrint
                  If nLanguage=1
                     @ nCeil-1,cl+1 Say "����> IMPRIMIENDO <��Ŀ"
                  Elseif nLanguage=2
                     @ nCeil-1,cl+1 Say "������> DRUCKEN <����Ŀ"
                  Elseif nLanguage=3
                     @ nCeil-1,cl+1 Say "�����> AFDRUKKEN <���Ŀ"
                  Elseif nLanguage=4
                     @ nCeil-1,cl+1 Say "�����> A IMPRIMIR <��Ŀ"
                  Else
                     @ nCeil-1,cl+1 Say "������> PRINTING <���Ŀ"
                  Endif
               Else
                  @ nCeil-1,cl+1 Say "���������������������Ŀ"
               Endif
               @ ct,cl+ 1 Say Chr(193)
               @ ct,cl+23 Say Chr(193)
               lPaper:=True

            Case cKey == "(" .and. aLevPtr<16 .and. lLineDone  //save level
               ++aLevPtr
               AAdd(aLevel,{cOldValue,cOldOp})
               cOldValue:=" "
               cOldOp:="("
               lLineDone:=.T.
               lParen:=.T.

            Case nKey == K_CTRL_LEFT .or. nKey == K_CTRL_RIGHT
               //:Restore old screen - Grab new screen & replace calc, chgg "cl"
               x:={SaveScreen(ct,cl,ct+12,cl+24),;
                   If(lPaper,SaveScreen(nCeil-1,cl+1,ct-1,cl+23),NIL)}
               RestScreen(0,cl,ct+12,cl+24,aScreen[1])
               If nKey == K_CTRL_LEFT
                  cl:=If(cl=0,MaxCol()-24,If(cl=MaxCol()-24,27,0))
               Else
                  cl:=If(cl=0,27,If(cl=MaxCol()-24,0,MaxCol()-24))
               Endif
               aScreen[1]:=SaveScreen(0,cl,ct+12,cl+24)
               RestScreen(ct,cl,ct+12,cl+24,x[1])
               If lPaper
                  RestScreen(nCeil-1,cl+1,ct-1,cl+23,x[2])
               Endif

            Case nKey == K_PGUP .or. nKey == K_PGDN .or. ;
                 nKey == K_UP   .or. nKey == K_DOWN .or. ;
                 nKey == K_HOME .or. nKey == K_END

               If !lScrollOff
                  nScrollPos := (Len(aScroll)-(ct-nCeil))+1
               Endif

               lScrollOff := .Y.
               Do Case
                  Case nKey == K_PGUP
                     x := -( ct-nCeil )
                  Case nKey == K_PGDN
                     x :=  ( ct-nCeil )
                  Case nKey == K_UP
                     x := -1
                  Case nKey == K_DOWN
                     x := 1
                  Case nKey == K_HOME
                     x := 0
                     nScrollPos := 1
                  Case nKey == K_END
                     x := 0
                     nScrollPos := Len(aScroll)-(ct-nCeil)+1
                     lScrollOff := .N.  //at end, buddy
               Endcase

               nScrollPos += x
               nScrollPos := Max(nScrollPos,1)
               nScrollPos := Min(nScrollPos,Len(aScroll)-(ct-nCeil)+1)

               y:=0
               AEval(aScroll,{|e|SetPos(nCeil+ y++,cl+2),DevOut(e)},nScrollPos,(ct-nCeil))

         Endcase

      Enddo

      RECOVER using oError
         If oError=NIL
            FT_NUMLOCK(lNumLock)
            CM_Cursor(lMCurs)
            Return 0
         Endif

         If nLanguage=1
            CalcMsg("--ERROR INTERNO--  ",ct,cl)
         ElseIf nLanguage=3
            CalcMsg("CALC: INTERNE FOUT ",ct,cl)
         Else
            CalcMsg("CALC INTERNAL ERR  ",ct,cl)
         Endif
         lLineDone:=.F.
         cLine:="X"
         cOldOp:=" "
      END SEQUENCE

      If !cLine="X"
         Exit
      Else
         cLine:="0"
      Endif

   Enddo

   If lEject //printed at some time!
      If nPrint=PRINT_HOLD  //print all NOW
         Set Print ON
         Set Console OFF
         ?? cPrint
         Eject
         Set Console ON
         Set Print OFF
         cPrint := ""
      Elseif nPrint=PRINT_HOLDALL
         cPrint += Chr(12)
      Elseif !nPrint=PRINT_NEVER
         Set Print ON
         Set Console OFF
         Eject
         Set Console ON
         Set Print OFF
         cPrint := ""
      Endif
   Endif

   RestScreen(0,cl,ct+12,cl+24,aScreen[1])
   SetCursor(aScreen[2])
   @ aScreen[3],aScreen[4] Say ''
   nLastDec:=nFixed
   Set Decimals to (aSettings[2])
   Set Fixed (aSettings[1])
   SetKey(nLKey,bSetKey)
   SetColor(aScreen[5])
   FT_NUMLOCK(lNumLock)
   ErrorBlock(oError)

   If ValType(sbCalcExit)="B" //was saColors
      Eval(sbCalcExit,ProcName(),VERSION,ReadVar(),Val(cLine),cLine,3/*End*/,SetColor(),0)
   Endif
   CM_Cursor(lMCurs)
   If CM_IsMouse()
      CM_Exit()
   Endif

Return Val(cLine)


Static Function Light(cKey,ct,cl)
Local nPtr
Static aKeys:={ {Chr(27), 3, 2, 1},;   // Key type 1 is normal (1 row x 3 cols)
               {    "7", 5, 2, 1},;
               {    "4", 7, 2, 1},;
               {    "1", 9, 2, 1},;
               {    "0",11, 4, 2},;    // Key type 2 is twice as wide
               {    "/", 3, 6, 1},;
               {    "8", 5, 6, 1},;
               {    "5", 7, 6, 1},;
               {    "2", 9, 6, 1},;
               {    "*", 3,10, 1},;
               {    "9", 5,10, 1},;
               {    "6", 7,10, 1},;
               {    "3", 9,10, 1},;
               {    ".",11,10, 1},;
               {    "-", 3,14, 1},;
               {    "+", 6,14, 3},;   // Key type 3 is twice as tall
               {    "=",10,14, 3},;
               {Chr(13),10,14, 3},;
               {    "C", 3,18, 1},;
               {   "M+", 5,18, 1},;
               {   "M-", 7,18, 1},;
               {    "%", 9,18, 1},;
               {    "F",11,18, 1},;
               {   "AC", 3,22, 1},;
               {   "MR", 5,22, 1},;
               {   "MC", 7,22, 1},;
               {    "P", 9,22, 1},;
               {    "H",11,22, 1}  }


aKeys[14,1]:=CalcCkDec()
If (nPtr:=AScan(aKeys,{|elem|elem[1]==cKey}))>0
   Do Case
      Case aKeys[nPtr,4] = 1
         BackLight(ct+aKeys[nPtr,2],cl+aKeys[nPtr,3]-1,ct+aKeys[nPtr,2],cl+aKeys[nPtr,3]+1)

      Case aKeys[nPtr,4] = 2  //double width
         BackLight(ct+aKeys[nPtr,2],cl+aKeys[nPtr,3]-3,ct+aKeys[nPtr,2],cl+aKeys[nPtr,3]+3)

      Case aKeys[nPtr,4] = 3  //double height
         BackLight(ct+aKeys[nPtr,2]-1,cl+aKeys[nPtr,3]-1,ct+aKeys[nPtr,2]+1,cl+aKeys[nPtr,3]+1)

   Endcase
Endif
Return NIL

Static Function BackLight(t,l,b,r)
Local cScreen:=SaveScreen(t,l,b,r), cStd:=If("/W"$Substr(SetColor(),1,;
      At(",",SetColor())),Chr(7),Chr(112)), nKey
   RestScreen(t,l,b,r,TRANSFORM( cScreen,REPLICATE("X"+cStd, Len(cScreen)/2)))
   nKey:=If(CM_IsMouse(),CM_Wait(0,lMousekey),Inkey(.2))
   If nKey>0
      Keyboard Chr(nKey)
   Endif
   RestScreen(t,l,b,r,cScreen)
Return NIL

Static Function Upwards(cLine,nCeil,ct,cl,lPrint)
Local y

   If lScrollOff
      lScrollOff := .N.
      nScrollPos := (Len(aScroll)-(ct-nCeil)) + 1
      y:=0
      AEval(aScroll,{|e|SetPos(nCeil+ y++,cl+2),DevOut(e)},nScrollPos,(ct-nCeil))
   Endif

   //:Move all numerics upwords
   If nCeil > 1
      nCeil--
      @ ct,cl+ 1 Say Chr(193)
      @ ct,cl+23 Say Chr(193)
   Endif
   If lPrint
      If nLanguage=1
         @ nCeil-1,cl+1 Say "����> IMPRIMIENDO <��Ŀ"
      Elseif nLanguage=2
         @ nCeil-1,cl+1 Say "������> DRUCKEN <����Ŀ"
      Elseif nLanguage=3
         @ nCeil-1,cl+1 Say "�����> AFDRUKKEN <���Ŀ"
      Elseif nLanguage=4
         @ nCeil-1,cl+1 Say "�����> A IMPRIMIR <��Ŀ"
      Else
         @ nCeil-1,cl+1 Say "������> PRINTING <���Ŀ"
      Endif
   Else
      @ nCeil-1,cl+1 Say "���������������������Ŀ"
   Endif
   Scroll(nCeil,cl+1,ct-1,cl+23,1)

   If CalcCkDec()=","
      @ ct-1, cl+1 Say "�"+StrTran(cLine,".",",")+"�"   //fix! make it match the F-setting
   Else
      @ ct-1, cl+1 Say "�"+cLine+"�"   //fix! make it match the F-setting
   Endif

   If lPrint
      If nPrint=PRINT_HOLD .or. nPrint=PRINT_HOLDALL
         If Len(cPrint)<32000
            cPrint+=cLine+Chr(13)+Chr(10)
         Endif
      Elseif !nPrint=PRINT_NEVER //(then normal)
         Set Print ON
         Set Console OFF
         ?? cLine+Chr(13)+Chr(10)
         Set Console ON
         Set Print OFF
      Endif
   Endif

   //Add to aScroll for paperback ability
   If Len(aScroll)=1000
      ADel(aScroll,1)
      aScroll[1000] := cLine
   Else
      AAdd(aScroll,cLine)
   Endif

Return NIL

Static Function CalcMsg(cMsg,ct,cl)
   @ct+1,cl+5 Say cMsg
   Eval(sbCalcInkey,ct,cl,15)
   @ct+1,cl+5 Say Space(Len(cMsg))
Return NIL

Static Function KillZeros(cNum) //Only called when NO FIXED positions exist.
Local cRet:="0", x
   If CalcCkDec()$cNum                  //If a decimal place is found...
      For x=Len(cNum) to At(CalcCkDec(),cNum) Step -1
         If !Substr(cNum,x,1)="0"
            cRet:=Substr(cNum,1,If(Substr(cNum,x,1)=CalcCkDec(),x-1,x))
            Exit
         Endif
      Next x
   Else
      cRet:=cNum
   Endif
Return cRet

Static Function CalcPos2(n,def)
Local x
   If Len(saCalcSetp)>=n .and. ValType(saCalcSetp[n])=ValType(def)
      x:=saCalcSetp[n]
   Else
      x:=def
   Endif
   If n=1
      x := Min(Max(x,0),MaxRow()-12)
   Elseif n=2
      x := Min(Max(x,0),MaxCol()-24)
   Endif
Return x

Function CalcKey(n,cRow,cCol,lSole)
Local nRet:=0, mRow, mCol, mButton, nPtr, nSec0
Static lButton:=.F.
Static aKeys:={ {Chr(27), 3, 2, 1},;   // Key type 1 is normal (1 row x 3 cols) aArray:=
               {    "7", 5, 2, 1},;
               {    "4", 7, 2, 1},;
               {    "1", 9, 2, 1},;
               {    "0",11, 4, 2},;   // Key type 2 is twice as wide
               {    "/", 3, 6, 1},;
               {    "8", 5, 6, 1},;
               {    "5", 7, 6, 1},;
               {    "2", 9, 6, 1},;
               {    "*", 3,10, 1},;
               {    "9", 5,10, 1},;
               {    "6", 7,10, 1},;
               {    "3", 9,10, 1},;
               {    ".",11,10, 1},;
               {    "-", 3,14, 1},;
               {    "+", 6,14, 3},;   // Key type 3 is twice as tall
               {    "=",10,14, 3},;
               {Chr(13),10,14, 3},;
               {    "C", 3,18, 1},;
               {   "M+", 5,18, 1},;
               {   "M-", 7,18, 1},;
               {    "%", 9,18, 1},;
               {    "F",11,18, 1},;
               {   "AC", 3,22, 1},;
               {   "MR", 5,22, 1},;
               {   "MC", 7,22, 1},;
               {    "P", 9,22, 1},;
               {    "H",11,22, 1} }

   aKeys[14,1]:=CalcCkDec()
   If(n=NIL,n:=0,NIL)
   If(lSole=NIL,lSole:=.T.,NIL)

   If CM_IsMouse()
      CM_On()
      nSec0:= (Seconds()+n)%86400
      While nRet=0 .and. (n=0 .or. nSec0 > Seconds())
         If (mButton:=CM_Button()) > 0  .and. !lButton //left button pressed!

            lButton:=.T.
            mRow:=CM_Row() - cRow
            mCol:=CM_Col() - cCol

            If mRow=1 .and. mCol>0 .and. mCol<25
               KeyBoard Chr(K_CTRL_ENTER)
            Elseif mCol<0 .and. lSole
               Keyboard Chr(K_CTRL_LEFT)
            Elseif mCol>25 .and. lSole
               Keyboard Chr(K_CTRL_RIGHT)
            Elseif !lSole .and. (mCol<0 .or. mCol>25)
               Keyboard Chr(K_ESC)
            Else
               nPtr:=AScan(aKeys,{|e|If(e[4]=1,e[2]=mRow.and.Abs(e[3]-mCol)<2,;
                                    If(e[4]=2,e[2]=mRow.and.Abs(e[3]-mCol)<4,;
                                    If(e[4]=3,Abs(e[2]-mRow)<2.and.Abs(e[3]-mCol)<2,.F.)))})

               If mButton=2
                  nPtr:=1
               Endif

               If nPtr>0 //yes, button on target!
                  Keyboard aKeys[nPtr,1]
                  lMousekey:=.T.
               Endif
            Endif
            Exit

         Elseif lButton .and. mButton=0

            lMousekey:=.F.
            lButton:=.F.

         Endif
         nRet:=Inkey()
      Enddo
      CM_Off()
   Else
      nRet:=Inkey(n)
   Endif

Return nRet

Static Function MakeDec(xVal,cType)
Local nDec:=-1

   nTempX:=-1
   If nSetDec>-2
      nDec:=nSetDec
   Else
      If ValType(cType)="C"
         If cType="N" .and. ValType(xVal)="C" .and. CalcCkDec()$xVal
            nDec:=Len(xVal)-At(CalcCkDec(),xVal)
         Endif
      Else  //val!
         If ValType(xVal)="N"
            xVal:=AllTrim(Str(xVal))
         Endif
         If ValType(xVal)="C"
            If "."$xVal
               nDec:=Len(xVal)-At(".",xVal)
            Else
               nDec:=0
            Endif
         //Else
         //   nDec:=
         Elseif ValType(xVal)="U"
            nDec:=nLastDec
            nTempX:=nDec
         Endif
      Endif
   Endif

Return nDec
