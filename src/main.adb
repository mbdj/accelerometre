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

-- oled screen
with SSD1306;                      use SSD1306;
with SSD1306.Standard_Resolutions; use SSD1306.Standard_Resolutions;
with STM32.Device;                 use STM32.Device;

with Ravenscar_Time;
with HAL.I2C;
with STM32.GPIO; use STM32.GPIO;

procedure Main is

	Period : constant Time_Span := Milliseconds (50);

	Next_Release : Time := Clock;

	OLED_I2C : HAL.I2C.Any_I2C_Port renames I2C_1'Access;
	OLED_SCK : GPIO_Point renames PD13;
	OLED_SDA : GPIO_Point renames PD14;
	OLED_RST : GPIO_Point renames PD15;

	Oled : SSD1306_128x64_Screen
	  (Port => OLED_I2C,
	 RST  => OLED_RST'Access, -- not used
	 Time => Ravenscar_Time.Delays);

begin
	STM32.Board.Initialize_LEDs;
	STM32.User_Button.Initialize (Use_Rising_Edge => False);
	STM32.Board.Turn_On(Green_LED);

	Enable_Clock (OLED_SDA & OLED_SCK & OLED_RST);

	Enable_Clock (I2C_Id_1);

	Configure_IO (OLED_SDA & OLED_SCK & OLED_RST,
					(Resistors   => Floating, Mode => Mode_Out,
		Output_Type => Push_Pull,
		Speed       => Speed_100MHz));


	Oled.Initialize (External_VCC => False);
	STM32.Board.Turn_Off(Green_LED);

	Oled.Turn_On;
	Oled.Set_Background(R => 255,
							G => 255,
							B => 255);

	STM32.Board.Turn_Off(Green_LED);

	loop
		if STM32.User_Button.Has_Been_Pressed then
			STM32.Board.Toggle (Green_LED);
		end if;

		Next_Release := Next_Release + Period;
		delay until Next_Release;
	end loop;
end Main;
