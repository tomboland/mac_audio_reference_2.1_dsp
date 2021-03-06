defmodule DspUart do
  def serial_baud_rate, do: 192000
  def serial_timeout, do: 2
  def mcu_command_prefix, do: <<0x04::8>>
  def mcu_init_prefix, do: <<0x03::8>>
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
    serialise_message(message)
  end

  @spec serialise_mcu_init_command(binary) :: binary
  def serialise_mcu_init_command(command_value) do
    message = mcu_init_prefix() <> command_value
    serialise_message(message)
  end

  @spec serialise_message(binary) :: binary
  def serialise_message(message) do
    prefix = mcu_message_prefix() <> :binary.encode_unsigned(byte_size(message))
    prefix <> append_serial_message_checksum(message)
  end

  @spec get_serial_connection(String.t) :: pid
  def get_serial_connection(dev \\ "tnt0") do
    {:ok, pid} = Circuits.UART.start_link()
    :ok = Circuits.UART.open(pid, dev, speed: serial_baud_rate(), active: false)
    pid
  end

  def rs232_test(pid) do
    {:ok, <<0xff::8>>} = send_serial_message_recv(pid, serialise_mcu_init_command(<<07>>))
  end

  def dsp_type_test(pid) do
    {:ok, <<0x11::8>>} = send_serial_message_recv(pid, serialise_mcu_init_command(<<08>>))
  end

  def send_serial_message_recv(pid, message) do
    IO.inspect(message)
    #Circuits.UART.flush(pid)
    Circuits.UART.write(pid, message)
    Circuits.UART.read(pid, 100)
  end

  def send_serial_message(pid, message) do
    IO.inspect(message)
    #Circuits.UART.flush(pid)
    Circuits.UART.write(pid, message)
  end

  @spec commit_messages(String.t, [binary]) :: [any]
  def commit_messages(dev, messages) do
    pid = get_serial_connection(dev)
    messages
    |> List.flatten()
    |> Enum.chunk_every(8)
    |> Enum.map(&:erlang.list_to_binary/1)
    |> Enum.map(&send_serial_message(pid, &1))
  end

end
