defmodule DspUart do
  def serial_baud_rate, do: 192000
  def serial_timeout, do: 2
  def mcu_command_prefix, do: <<0x04::8>>
  def mcu_message_prefix, do: <<0x55::8>>
  def start_write_config_command, do: <<0x0201::16>>
  def end_write_config_command, do: <<0x0206::16>>
  def get_flash_status_command, do: <<0x02fe::16>>

  def flash_address_at_position(position) do
    {fa, _} = Integer.parse("#{position}000550#{position}", 16)
    fa
  end

  @spec append_serial_message_checksum(binary) :: binary
  @doc """
  Sum the bytes in a message, and append the least significant byte of the sum
  Effectively, rolling over the sum after 255.
  """
  def append_serial_message_checksum(message) do
    checksum = for <<i <- message>>, reduce: 0 do
      acc -> acc + i
    end
    message <> <<checksum :: 8>>
  end


  @spec serialise_mcu_command(binary) :: binary
  @doc """
    Takes a binary command value and serialises it in to a form ready to sent over the
    serial link.
  """
  def serialise_mcu_command(command_value) do
    message = mcu_command_prefix() <> command_value
    prefix = mcu_message_prefix() <> :binary.encode_unsigned(byte_size(message))
    prefix <> append_serial_message_checksum(message)
  end

end
