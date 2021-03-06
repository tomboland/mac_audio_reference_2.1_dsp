defmodule DspCommands do

  def max_signed_int32, do: 2147483647
  def max_unsigned_int32, do: 4294967296


  @type command_name :: String.t()
  @type coeff_name :: atom()
  @type command :: binary()
  @type coeff_value :: float()
  @type signedness :: boolean()
  @type fractional_bits :: pos_integer()

  @type dsp_command :: [
    command: command,
    fractional_bits: fractional_bits,
    signedness: signedness
  ]
  @type dsp_coeff_command :: {coeff_name, [dsp_command]}
  @type dsp_commands :: %{command_name => %{coeff_name => [dsp_command]}}

  def load_dsp_commands(filename \\ "dsp.json") do
    dsp_commands =
      File.read!(filename)
      |> Jason.decode!()
      |> Map.new(fn {k, v} ->
        {k, dsp_commands_from_group(v)}
      end)
    make_dsp_command(dsp_commands)
  end

  @spec make_dsp_command(dsp_commands) :: (command_name, coeff_name, coeff_value -> binary)
  def make_dsp_command(dsp_commands) do
    fn (command_name, coeff_name, value) ->
      command = dsp_commands[command_name][coeff_name]
      fixed_point_value = fixed_point_from_float(
        command[:fractional_bits],
        command[:signedness],
        value
      )
      command[:command_hex] <> :binary.encode_unsigned(fixed_point_value)
    end
  end

  @spec dsp_commands_from_group(map) :: dsp_commands()
  def dsp_commands_from_group(command_group) do
    Map.new(command_group, fn x -> dsp_command_from_raw(x) end)
  end

  def dsp_command_from_raw(command) do
    coeff_name = String.to_atom(command["coefficient_name"])
    {command_int, ""} = Integer.parse(command["command_hex"], 16)
    command_hex = :binary.encode_unsigned(command_int)
    fractional_bits = command["fractional_bits"]
    signedness = if command["signedness"] == 0, do: false, else: true
    {
      coeff_name, [
        command_hex: command_hex,
        fractional_bits: fractional_bits,
        signedness: signedness
      ]
    }
  end

  def dsp_eq_commands(dsp_commands) do
    Enum.filter(dsp_commands, fn {k, _} -> String.starts_with?(k, "EQ_") end)
  end

  @spec fixed_point_from_float(fractional_bits, signedness, coeff_value) :: integer
  def fixed_point_from_float(fractional_bits, signedness, value) do
    intermediate = case fractional_bits do
      31 -> value * max_signed_int32()
      _ -> value * :math.pow(2, fractional_bits)
    end
    if signedness and intermediate < 0 do
      trunc(max_unsigned_int32() + intermediate)
    else
      trunc(intermediate)
    end
  end

end
