
--
-- Mehdi 14/07/2022 --
--
-- Mise en oeuvre d'un écran oled sh1106
--

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board; use STM32.Board;
with STM32.User_Button;
with STM32.Setup;

with Ada.Real_Time; use Ada.Real_Time;

with SH1106; use SH1106;
with STM32.Device; use STM32.Device;

with Ravenscar_Time;

with HAL.Bitmap;

with Bitmapped_Drawing;
with BMP_Fonts;


procedure Main is
-- pragma Priority (System.Priority'First);

	Period : constant Time_Span := Milliseconds (50);
	Next_Release : Time := Clock;

	Compteur : Natural := 0; -- compteur de clics sur le bouton

	My_Screen    : SH1106_Screen (Buffer_Size_In_Byte => (128 * 64) / 8,
										 Width               => 128,
										 Height              => 64,
										 Port                => I2C_1'Access,
										 RST                 => PA0'Access, -- reset de l'écran ; PA0 choix arbitraire car pas utilisé mais obligatoire
										 Time                => Ravenscar_Time.Delays);

begin

	STM32.Board.Initialize_LEDs;
	STM32.User_Button.Initialize (Use_Rising_Edge => False);
	STM32.Board.Turn_On (Green_LED);

	-- initialisation de I2C pour l'écran oled sh1106 en i2c
	STM32.Setup.Setup_I2C_Master  (Port => I2C_1,
										  SDA => PB9,
										  SCL => PB8,
										  SDA_AF => GPIO_AF_I2C1_4,
										  SCL_AF => GPIO_AF_I2C1_4,
										  Clock_Speed => 100_000); -- 100 MHz


	-- initialisation de l'oled sh1106
	My_Screen.Initialize;
	My_Screen.Initialize_Layer;
	My_Screen.Turn_On;

	-- clear screen
	My_Screen.Hidden_Buffer.Set_Source (HAL.Bitmap.Black);
	My_Screen.Hidden_Buffer.Fill;
	--My_Screen.Update_Layer;

	-- draw line
	My_Screen.Hidden_Buffer.Set_Source (HAL.Bitmap.White);
	My_Screen.Hidden_Buffer.Draw_Line ((0, 0), (127, 63));
	--My_Screen.Update_Layer;

	-- draw string
	Bitmapped_Drawing.Draw_String (My_Screen.Hidden_Buffer.all,
										  Start      => (0, 20),
										  Msg       => "Made with Ada",
										  Font       => BMP_Fonts.Font8x8,
										  Foreground => HAL.Bitmap.Black,
										  Background => HAL.Bitmap.White);

	Bitmapped_Drawing.Draw_String (My_Screen.Hidden_Buffer.all,
										  Start      => (10, 30),
										  Msg       => "Ada",
										  Font       => BMP_Fonts.Font16x24,
										  Foreground => HAL.Bitmap.White,
										  Background => HAL.Bitmap.Black);

	Bitmapped_Drawing.Draw_String (My_Screen.Hidden_Buffer.all,
										  Start      => (0, 0),
										  Msg       => "Ada",
										  Font       => BMP_Fonts.Font12x12,
										  Foreground => HAL.Bitmap.Black,
										  Background => HAL.Bitmap.White);

	My_Screen.Update_Layer;


	STM32.Board.Turn_Off (Green_LED);

	loop
		if STM32.User_Button.Has_Been_Pressed then
			STM32.Board.Toggle (Green_LED);

			Compteur := Compteur + 1;

			Bitmapped_Drawing.Draw_String (My_Screen.Hidden_Buffer.all,
											 Start      => (0, 50),
											 Msg        => Compteur'Image,
											 Font       => BMP_Fonts.Font12x12,
											 Foreground => HAL.Bitmap.Black,
											 Background => HAL.Bitmap.White);

			My_Screen.Update_Layer;

		end if;

		Next_Release := Next_Release + Period;
		delay until Next_Release;
	end loop;
end Main;
