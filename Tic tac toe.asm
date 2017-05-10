INCLUDE Irvine32.INC
.DATA
	Board BYTE '1', '2', '3', '4', '5', '6', '7', '8', '9'
	AskPlayer1 BYTE "Player 1, please enter the number of the square where you want to place your X: ", 0
	AskPlayer2 BYTE "Player 2, please enter the number of the square where you want to place your O: ", 0
	Input BYTE 100 DUP (?), 0
	InvalidMSG BYTE "Invalid input !!!", 0
	Player1Wins BYTE "Player1 wins !", 0
	Player2Wins BYTE "Player2 wins !", 0
	Draw BYTE "Draw !", 0
	Player1Counter DWORD 0
	Player2Counter DWORD 0
	ScoreMSG1 BYTE "Player1 ", 0
	ScoreMSG2 BYTE " : ", 0
	ScoreMSG3 BYTE " Player2", 0
	ContinueMSG BYTE "Do you want to play again? Enter Y for yes or N for no: ", 0
	Player1Color DWORD LIGHTGREEN
	Player2Color DWORD LIGHTRED
	FreeSquaresColor DWORD YELLOW
	BoardersColor DWORD LIGHTBLUE
	InvalidColor DWORD LIGHTMAGENTA
	DrawColor DWORD LIGHTCYAN

;*****************************************************************************************************************

.CODE
;	DrawBorder
;	Drawing a border.
DrawBorder PROC USES EAX ECX
	MOV EAX, BoardersColor
	CALL SETTEXTCOLOR
	MOV ECX, 3
	
	DrawBorderPLUS:
		MOV AL, '+'
		CALL WRITECHAR
		
		PUSH ECX
		MOV ECX, 3
		
		MOV Al, '-'
		DrawBorderMinus:
			CALL WRITECHAR
		LOOP DrawBorderMinus
		
		POP ECX
	LOOP DrawBorderPLUS
	
	MOV Al, '+'
	CALL WRITECHAR
	CALL CRLF
	RET
DrawBorder ENDP

;-----------------------------------------------------------------------------------------------------------------

;	DrawBoard
;	Drawing the game board.
;	Recieves: ESI = Board offset.
DrawBoard PROC USES EAX ECX ESI
	CALL CRLF
	MOV ECX, 3
	
	DrawBoardROWS:	;Loop the 3 rows.
		CALL DrawBorder
		PUSH ECX
		MOV ECX, 3

		DrawBoardColumns:	;Loop the 3 columns.
			MOV EAX, BoardersColor
			
			CALL SETTEXTCOLOR
			MOV Al, '|'
			CALL WRITECHAR
			MOV Al, ' '
			CALL WRITECHAR
			
			CMP BYTE PTR [ESI], 'X'
			JE DrawBoardPLAYER1	;Player1.
			
			CMP BYTE PTR [ESI], 'O'	;Player2.
			JE DrawBoardPLAYER2

			MOV EAX, FreeSquaresColor	;Free place.
			JMP DrawBoardSKIP

			DrawBoardPLAYER1:	;Player1.
				MOV EAX, Player1Color
				JMP DrawBoardSKIP
			
			DrawBoardPLAYER2:	;Player2
				MOV EAX, Player2Color
				JMP DrawBoardSKIP
			
			DrawBoardSKIP:
				;TODO.
			
			CALL SETTEXTCOLOR
			MOV Al, [ESI]
			CALL WRITECHAR
			MOV Al, ' '
			CALL WRITECHAR
			
			INC ESI
		LOOP DrawBoardColumns
		
		MOV EAX, BoardersColor
		CALL SETTEXTCOLOR
		MOV Al, '|'
		CALL WRITECHAR
		CALL CRLF
		
		POP ECX
	LOOP DrawBoardROWS
	
	CALL DrawBorder
	CALL CRLF
	CALL CRLF
	RET
DrawBoard ENDP

;-----------------------------------------------------------------------------------------------------------------

;	AskPosition
;	Ask the current player to choose the square where the player wants to play.
;	Recieves: EBX = 0 if player1 is the current player, EBX = 1 otherwise. 
;	Recieves: ESI = offset of player1 message, EDI = offset of player2 message.
AskPosition PROC USES EAX ESI EDI
	CMP EBX, 0
	JE AskPositionPLAYER1	;Player1.
	
	;Player2.
	MOV EAX, Player2Color
	MOV EDX, EDI
	JMP AskPositionSKIPPLAYER1

	AskPositionPLAYER1:	;Player1.
		MOV EAX, Player1Color
		MOV EDX, ESI
	
	AskPositionSKIPPLAYER1:
		;TODO.
	
	;Show the message.
	CALL SETTEXTCOLOR
	CALL WRITESTRING
	RET
AskPosition ENDP

;-----------------------------------------------------------------------------------------------------------------

;	ValidatePosition
;	Take the chosen position from the player. If it is valid, replace it in the board with
;	the player mark and return true or return false otherwise.
;	Recieves: EBX = 0 if player1 is the current player, EBX = 1 otherwise.
;	Recieves: ECX = Input string size, ESI = Input string offset, EDI = Board offset.
;	Returns: EAX = 0 if invalid input, EAX = 1 otherwise.
ValidatePosition PROC USES EDX EDI
	;Read string.
	MOV EDX, ESI
	CALL READSTRING
	CALL CRLF
	
	;Cases invalid input.
	CMP EAX, 1	;Number of entered characters.
	JNE ValidatePositionINVALID
	
	CMP BYTE PTR [ESI], '1'
	JB ValidatePositionINVALID
	
	CMP BYTE PTR [ESI], '9'
	JA ValidatePositionINVALID
	
	MOV EDX, 0
	MOV DL, [ESI]
	SUB DL, '1'
	ADD EDI, EDX
	
	CMP BYTE PTR [EDI], 'X'
	JE ValidatePositionINVALID
	
	CMP BYTE PTR [EDI], 'O'
	JE ValidatePositionINVALID
	
	CMP EBX, 0
	JE ValidatePositionPLAYER1
	
	;Player2.
	MOV BYTE PTR [EDI], 'O'	;Change the number in the board with the mark.
	JMP ValidatePositionSKIP_PLAYER1
	
	ValidatePositionPLAYER1:	;Player1.
		MOV BYTE PTR [EDI], 'X'	;Change the number in the board with the mark.
	
	ValidatePositionSKIP_PLAYER1:
		;TODO.
	
	;Case valid.
	MOV EAX, 1
	JMP ValidatePositionSKIP_INVALID
	
	ValidatePositionINVALID:	;Case invalid.
		MOV EAX, 0
	
	ValidatePositionSKIP_INVALID:
		;TODO.
	RET
ValidatePosition ENDP

;-----------------------------------------------------------------------------------------------------------------

;	CheckRows
;	Check if the current player placed 3 respective marks horizontally after the current turn.
;	Recieves: ESI = Board offset, DL = The current player mark.
;	Returns: EAX = 1 if the player succeeded, EAX = 0 otherwise.
CheckRows PROC USES EBX ECX ESI
	MOV ECX, 3
	
	CheckRowsL1:	;LOOP the 3 rows.
		MOV EBX, 0
		PUSH ECX
		MOV ECX, 3
		
		CheckRowsL2:	;LOOP the 3 characters in the current row.
			CMP [ESI], DL
			JE CheckRowsEQUAL	;Correct mark.
			JMP CheckRowsSKIP_EQUAL
			
			CheckRowsEQUAL:	;Correct mark.
				INC EBX
			
			CheckRowsSKIP_EQUAL:
				;TODO.
			
			INC ESI
		LOOP CheckRowsL2
		
		POP ECX
		CMP EBX, 3
		JE CheckRowsSUCCEED	;Complete row.
	LOOP CheckRowsL1

	;No complete row.
	MOV EAX, 0
	JMP CheckRowsSKIP_SUCCEED
	
	CheckRowsSUCCEED:	;Complete row.
		MOV EAX, 1
	
	CheckRowsSKIP_SUCCEED:
		;TODO.
	RET
CheckRows ENDP

;-----------------------------------------------------------------------------------------------------------------

;	CheckColumns
;	Check if the current player placed 3 respective marks vertically after the current turn.
;	Recieves: ESI = Board offset, DL = The current player mark.
;	Returns: EAX = 1 if the player succeeded, EAX = 0 otherwise.
CheckColumns PROC USES EBX ECX ESI
	MOV ECX, 3
	
	CheckColumnsL1:	;LOOP the 3 columns.
		MOV EBX, 0
		PUSH ECX
		MOV ECX, 3

		CheckColumnsL2:	;LOOP each character in the current column.
			CMP [ESI], DL
			JE CheckColumnsEQUAL	;Correct mark.
			JMP CheckColumnsSKIP_EQUAL
			
			CheckColumnsEQUAL:	;Correct mark.
				INC EBX
			
			CheckColumnsSKIP_EQUAL:
				;TODO.
			
			ADD ESI, 3	;Next character.
		LOOP CheckColumnsL2
		
		POP ECX
		CMP EBX, 3
		JE CheckColumnsSUCCEED	;Complete column.
		SUB ESI, 8	;Next column.
	LOOP CheckColumnsL1
	
	;No complete column.
	MOV EAX, 0
	JMP CheckColumnsSKIP_SUCCEED
	
	CheckColumnsSUCCEED:	;Complete column.
		MOV EAX, 1
	
	CheckColumnsSKIP_SUCCEED:
		;TODO.
	RET
CheckColumns ENDP

;-----------------------------------------------------------------------------------------------------------------

;	CheckDiagonals
;	Check if the current player placed 3 respective marks diagonally after the current turn.
;	Recieves: ESI = Board offset, DL = The current player mark.
;	Returns: EAX = 1 if the player succeeded, EAX = 0 otherwise.
CheckDiagonals PROC USES EBX ECX ESI
	;Left diagonal.
	MOV ECX, 3
	MOV EBX, 0

	CheckDiagonalsL1:	;Loop each character in the left diagonal.
		CMP [ESI], DL
		JE CheckDiagonalsEQUAL1	;Correct mark.
		JMP CheckDiagonalsSKIP_EQUAL1
		
		CheckDiagonalsEQUAL1:	;Correct mark.
			INC EBX
		
		CheckDiagonalsSKIP_EQUAL1:
			;TODO.
		
		ADD ESI, 4	;Next character.
	LOOP CheckDiagonalsL1
	
	CMP EBX, 3
	JE CheckDiagonalsSUCCEED	;Complete left diagonal.
	
	;Right diagonal.
	MOV ECX, 3
	MOV EBX, 0
	SUB ESI, 10

	CheckDiagonalsL2:	;Loop each character in the right diagonal.
		CMP [ESI], DL
		JE CheckDiagonalsEQUAL2	;Correct mark.
		JMP CheckDiagonalsSKIP_EQUAL2
		
		CheckDiagonalsEQUAL2:	;Correct mark.
			INC EBX
		
		CheckDiagonalsSKIP_EQUAL2:
			;TODO.
		
		ADD ESI, 2	;Next character.
	LOOP CheckDiagonalsL2
	
	CMP EBX, 3
	JE CheckDiagonalsSUCCEED	;Complete right diagonal.
	
	;No complete diagonal.
	MOV EAX, 0
	JMP CheckDiagonalsSKIP_SUCCEED
	
	CheckDiagonalsSUCCEED:	;Complete diagonal.
		MOV EAX, 1
	
	CheckDiagonalsSKIP_SUCCEED:
		;TODO.
	RET
CheckDiagonals ENDP

;-----------------------------------------------------------------------------------------------------------------

;	PlayerWins
;	Check if the current player wins after the current turn.
;	Recieves: EBX = 0 if player1 is the current player, EBX = 1 otherwise, ESI = Board offset.
;	Returns: EAX = 1 if the current player wins, EAX = 0 otherwise.
PlayerWins PROC USES ECX EDX
	MOV ECX, 0
	CMP EBX, 0
	JE PlayerWinsPlayer1	;Case player1.
	
	;Case player2.
	MOV DL, 'O'
	JMP PlayerWinsSKIP_PLAYER1
	
	PlayerWinsPLAYER1:	;Case player1.
		MOV DL, 'X'
	
	PlayerWinsSKIP_PLAYER1:
		;TODO.
	
	;Check if the current player wins horizontally, vertically or diagonally.
	CALL CheckRows
	OR ECX, EAX
	CALL CheckColumns
	OR ECX, EAX
	CALL CheckDiagonals
	OR ECX, EAX
	MOV EAX, ECX
	RET
PlayerWins ENDP

;-----------------------------------------------------------------------------------------------------------------

;	TicTacToe
;	The game main entry point.
TicTacToe PROC USES EAX EBX ECX EDX ESI EDI
	;EBX = 0 if the current player is player1, EBX = 1 otherwise.
	MOV ECX, 9	;ECX = Number of turns.
	
	CALL CLRSCR	;Clear screen.

	;Draw initial state of the board.
	MOV ESI, OFFSET Board
	CALL DrawBoard

	TicTacToeGAME_ON:
		PUSH ESI
		PUSH ECX
		
		MOV ECX, SIZEOF Input
		TicTacToePLAY:
			;Passing arguments.
			MOV ESI, OFFSET AskPlayer1
			MOV EDI, OFFSET AskPlayer2
			CALL AskPosition
			
			;Passing arguments.
			MOV ESI, OFFSET Input
			MOV EDI, OFFSET Board
			CALL ValidatePosition
			
			CMP EAX, 1
			JE TicTacToeContinue	;Case valid input.
			
			;Case invalid input.
			MOV EAX, InvalidColor
			CALL SETTEXTCOLOR
			MOV EDX, OFFSET InvalidMSG
			CALL WRITESTRING
			CALL CRLF
			CALL CRLF
			JMP TicTacToePLAY
		
		TicTacToeContinue:	;Case valid input.
			;TODO.
		
		POP ECX
		POP ESI
		
		;Draw current state of the board.
		MOV ESI, OFFSET Board
		CALL DrawBoard
		
		CALL PlayerWins
		
		CMP EAX, 1
		JE TicTacToeSTOP	;There is a player wins after current turn.
		JMP TicTacToeSKIP_STOP	;No player wins after current turn.
		
		TicTacToeSTOP:	;There is a player wins after current turn.
			CMP EBX, 0
			JE TicTacToePLAYER1_WINS	;Player1 wins.
			JMP TicTacToePLAYER2_WINS	;Player2 wins.
		
		TicTacToeSKIP_STOP:	;No player wins after current turn.
			;TODO.
		
		XOR EBX, 1
	LOOP TicTacToeGAME_ON
	
	;Case draw.
	MOV EAX, DrawColor
	MOV EDX, OFFSET Draw
	JMP TicTacToeSKIP
	
	TicTacToePLAYER1_WINS:	;Player1 wins.
		MOV EAX, Player1Color
		MOV EDX, OFFSET Player1Wins
		INC Player1Counter
		JMP TicTacToeSKIP
	
	TicTacToePLAYER2_WINS:	;Player2 wins.
		MOV EAX, Player2Color
		MOV EDX, OFFSET Player2Wins
		INC Player2Counter
	
	TicTacToeSKIP:
		;TODO.
	
	;Output "Player1 wins", "Player2 wins" or "Draw".
	CALL SETTEXTCOLOR
	CALL WRITESTRING
	CALL CRLF
	CALL CRLF
	RET
TicTacToe ENDP

;-----------------------------------------------------------------------------------------------------------------

;	ValidateChoice
;	Take the choice from the players. If it is valid, continue or exit the game.
;	Recieves: ECX = Input string size, ESI = Input string offset.
;	Returns: EAX = 0 if invalid input, EAX = 1 the if players want to exit the game, EAX = 2 otherwise.
ValidateChoice PROC USES EDX
	;Reading string.
	MOV EDX, ESI
	CALL READSTRING
	CALL CRLF

	CMP EAX, 1	;Compare number of entered characters with 1.
	JNE ValidateChoiceINVALID	;Case not equal "invalid".
	
	;Case no.
	CMP BYTE PTR [ESI], 'n'
	JE ValidateChoiceEXIT
	CMP BYTE PTR [ESI], 'N'
	JE ValidateChoiceEXIT
	
	;Case yes.
	CMP BYTE PTR [ESI], 'y'
	JE ValidateChoiceCONTINUE
	CMP BYTE PTR [ESI], 'Y'
	JE ValidateChoiceCONTINUE
	
	JMP ValidateChoiceINVALID
	
	ValidateChoiceEXIT:	;Case no.
		MOV EAX, 1
		JMP ValidateChoiceSKIP_INVALID
	
	ValidateChoiceCONTINUE:	;Case yes.
		MOV EAX, 2
		JMP ValidateChoiceSKIP_INVALID
	
	ValidateChoiceINVALID:	;Case invalid.
		MOV EAX, 0
	
	ValidateChoiceSKIP_INVALID:
		;TODO.
	RET
ValidateChoice ENDP

;-----------------------------------------------------------------------------------------------------------------

;	ResetBoard
;	Reset the board to its initial state.
;	Recieves: ESI = Board offset.
ResetBoard PROC USES EAX ECX ESI
	MOV AL, '1'
	MOV ECX, 9
	
	ResetBoardL:
		MOV [ESI], AL
		INC AL
		INC ESI
	LOOP ResetBoardL
	RET
ResetBoard ENDP

;-----------------------------------------------------------------------------------------------------------------

;	Main
;	Project main entry point.
Main PROC USES EAX EBX ECX EDX ESI
	MOV EBX, 0	;EBX = 0 if player1 will start the game, EBX = 1 otherwise.
	MainPLAY_GAME:
		;Reset board.
		MOV ESI, OFFSET Board
		CALL ResetBoard
		
		CALL TicTacToe	;Play a game
		
		;Compare number of winning games by player1 with player2.
		MOV EAX, Player1Counter
		CMP EAX, Player2Counter
		JE MainDRAW	;Case draw.
		
		CMP EAX, Player2Counter
		JA MainPLAYER1	;Case player1 more than player2.
		
		;Case player1 less than player2.
		MOV EAX, Player2Color
		JMP MainSKIP
		
		MainPLAYER1:	;Case player1 more than player2.
			MOV EAX, Player1Color
			JMP MainSKIP
		
		MainDRAW:	;Case draw
			MOV EAX, DrawColor
		
		MainSKIP:
			;TODO.
		
		;Output message like that "Player1 X : Y Player2".
		CALL SETTEXTCOLOR
		MOV EDX, OFFSET ScoreMSG1
		CALL WRITESTRING
		
		MOV EAX, Player1Counter
		CALL WRITEDEC
		
		MOV EDX, OFFSET ScoreMSG2
		CALL WRITESTRING
		
		MOV EAX, Player2Counter
		CALL WRITEDEC
		
		MOV EDX, OFFSET ScoreMSG3
		CALL WRITESTRING
		CALL CRLF
		CALL CRLF
		
		MaINCONTINUE_MSG:
			;Show continue message.
			MOV EAX, DrawColor
			CALL SETTEXTCOLOR
			MOV EDX, OFFSET ContinueMSG
			CALL WRITESTRING
			
			;Validate the choice of the players.
			MOV ECX, SIZEOF ContinueMSG
			MOV ESI, OFFSET Input
			CALL ValidateChoice
			
			;Case inalid input.
			CMP EAX, 0
			JE MainINVALID
			
			;Case no.
			CMP EAX, 1
			JE MainEXIT
			
			XOR EBX, 1
			JMP MainPLAY_GAME	;Case yes.
			
			MainINVALID:	;Case inalid.
				;Show invalid message.
				MOV EAX, InvalidColor
				CALL SETTEXTCOLOR
				MOV EDX, OFFSET InvalidMSG
				CALL WRITESTRING
				CALL CRLF
				CALL CRLF

				JMP MaINCONTINUE_MSG	;Take input again.
	
	MainEXIT:	;Case no.
		;TODO.
	EXIT
	RET
Main ENDP
END Main