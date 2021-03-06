defmodule DspUartTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest DspUart

  def unsigned_max_for_byte_length(byte_length) do
    trunc(:math.pow(2, byte_length * 8) - 1)
  end

  def unsigned_min_for_byte_length(1), do: 0

  def unsigned_min_for_byte_length(byte_length) do
    unsigned_max_for_byte_length(byte_length - 1) + 1
  end

  defmacro test_serialised_message_structure_for_given_length(byte_length) do
    quote do
      imin = unsigned_min_for_byte_length(unquote(byte_length))
      imax = unsigned_max_for_byte_length(unquote(byte_length))

      check all(command <- StreamData.integer(imin..imax)) do
        message_prefix = :binary.decode_unsigned(DspUart.mcu_message_prefix())
        command_prefix = :binary.decode_unsigned(DspUart.mcu_command_prefix())

        <<
          ^message_prefix,
          length::size(8),
          ^command_prefix,
          mcommand::binary-size(unquote(byte_length)),
          checksum::size(8)
        >> = DspUart.serialise_mcu_command(:binary.encode_unsigned(command))

        assert(:binary.decode_unsigned(mcommand) == command)
        assert(<<message_prefix>> == DspUart.mcu_message_prefix())
        assert(<<command_prefix>> == DspUart.mcu_command_prefix())

        expected_length =
          [command_prefix, command]
          |> Enum.map(fn x -> :binary.encode_unsigned(x) end)
          |> Enum.map(fn x -> byte_size(x) end)
          |> Enum.sum()

        assert(length == expected_length)
      end
    end
  end

  test "Test serialised messages with byte length 1" do
    test_serialised_message_structure_for_given_length(1)
  end

  test "Test serialised messages with byte length 2" do
    test_serialised_message_structure_for_given_length(2)
  end

  test "Test serialised messages with byte length 4" do
    test_serialised_message_structure_for_given_length(4)
  end

  test "Test serialised messages with byte length 8" do
    test_serialised_message_structure_for_given_length(8)
  end

  test "Test message checksum examples" do
    cases = [{0xABCDEF, 2_882_400_103}, {0xFFFFFF, 4_294_967_293}]

    Enum.map(cases, fn {x, y} ->
      b = :binary.encode_unsigned(x)
      m = DspUart.append_serial_message_checksum(b)
      assert(:binary.decode_unsigned(m) == y)
    end)
  end

  @tag integration: true
  test "Serial connection can be made" do
    pid = DspUart.get_serial_connection("ttyUSB0")
    Circuits.UART.read(pid)
    DspUart.rs232_test(pid)
    DspUart.dsp_type_test(pid)
  end
end
