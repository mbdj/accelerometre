with STM32.GPIO;   use STM32.GPIO;
with STM32.Device; use STM32.Device;

package My_I2C is
   Screen_I2C_SDA : GPIO_Point renames PB9;
   Screen_I2C_SCL : GPIO_Point renames PB8;

   procedure Initialize;

end My_I2C;
