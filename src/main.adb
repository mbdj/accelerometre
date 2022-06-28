--
-- Mehdi 19/06/2022 --
--

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board; use STM32.Board;
with STM32.User_Button;

with Ada.Real_Time; use Ada.Real_Time;

with Screen;

procedure Main is
-- pragma Priority (System.Priority'First);

	Period : constant Time_Span := Milliseconds (50);

	Next_Release : Time := Clock;

begin
	STM32.Board.Initialize_LEDs;
	STM32.User_Button.Initialize (Use_Rising_Edge => False);
	STM32.Board.Turn_On (Green_LED);

	Screen.Init;
	Screen.Clear_Screen;
	Screen.Put (X   => 0, Y   => 0, Msg => "HELLO MEHDI");
		Screen.Put (X   => 10, Y   => 20, Msg => "Make with Ada");

	STM32.Board.Turn_Off (Green_LED);

	loop
		if STM32.User_Button.Has_Been_Pressed then
			STM32.Board.Toggle (Green_LED);
		end if;

		Next_Release := Next_Release + Period;
		delay until Next_Release;
	end loop;
end Main;
