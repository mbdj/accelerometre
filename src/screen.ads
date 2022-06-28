with SSD1306; use SSD1306;
with STM32.Device; use STM32.Device;
with Ravenscar_Time;
with HAL.Time;
with BMP_Fonts;     use BMP_Fonts;
with HAL.Bitmap;

package Screen is

	HAL_Time  : constant HAL.Time.Any_Delays := Ravenscar_Time.Delays;
	My_Screen : SSD1306_Screen (Buffer_Size_In_Byte => (128 * 64) / 8,
									  Width               => 128,
									  Height              => 64,
									  Port                => I2C_1'Access,
									  RST                 => PA9'Access, -- pas utilisé
									  Time                => HAL_Time);

	Default_Text_Color       : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.White;
	Default_Background_Color : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
	Default_Font             : constant BMP_Font := Font8x8;

	Current_Text_Color       : HAL.Bitmap.Bitmap_Color := Default_Text_Color;
	Current_Background_Color : HAL.Bitmap.Bitmap_Color := Default_Background_Color;


	procedure Clear_Screen;

	----------------------------------------------------------------------------

	--  These routines maintain a logical line and column, such that text will
	--  wrap around to the next "line" when necessary, as determined by the
	--  current orientation of the screen.

	procedure Put_Line (Msg : String);
	--  Note: wraps around to the next line if necessary.
	--  Always calls procedure New_Line automatically after printing the string.

	procedure Put (Msg : String);
	--  Note: wraps around to the next line if necessary.

	procedure Put (Msg : Character);

	procedure New_Line;
	--  A subsequent call to Put or Put_Line will start printing characters at
	--  the beginning of the next line, wrapping around to the top of the LCD
	--  screen if necessary.

	----------------------------------------------------------------------------

	--  These routines are provided for convenience, as an alternative to
	--  using both this package and an instance of Bitmnapped_Drawing directly,
	--  when wanting both the wrap-around semantics and direct X/Y coordinate
	--  control. You can combine calls to these routines with the ones above but
	--  these do not update the logical line/column state, so more likely you
	--  will use one set or the other. If you only need X/Y coordinate control,
	--  consider directly using an instance of HAL.Bitmap.

	procedure Put (X, Y : Natural; Msg : Character);
	--  Prints the character at the specified location. Has no other effect
	--  whatsoever, especially none on the state of the current logical line
	--  or logical column.

	procedure Put (X, Y : Natural; Msg : String);
	--  Prints the string, starting at the specified location. Has no other
	--  effect whatsoever, especially none on the state of the current logical
	--  line or logical column. Does not wrap around.

	procedure Init;

end Screen;

