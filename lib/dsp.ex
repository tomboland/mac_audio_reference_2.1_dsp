defmodule Dsp do

  def frequency_from_band(band) do
    s = Atom.to_string(band)
    IO.inspect(s)
    [m] = Regex.run(~r/[[:digit:]]+$/, s)
    band_num = String.to_integer(m)
    case Regex.match?(~r/^EQ_F/, s) do
      true -> Enum.at(third_octave_bands(), band_num - 1)
      false -> Enum.at(octave_bands(), band_num - 1)
    end
  end

  def third_octave_bands, do: [
    20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250,
    1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000
  ]

  def octave_bands, do: [
    32, 64, 125, 250, 500, 800, 1200, 3100, 6000, 10000, 16000
  ]

  def eq(band, q, gain) do
    dsp_command = DspCommands.load_dsp_commands()
    freq = frequency_from_band(band)
    DspEq.dsp_eq_coeffs(freq, q, gain)
    |> Enum.map(fn {k, v} ->
        dsp_command.(band, k, v)
        |> DspUart.serialise_mcu_command()
      end)
  end

  def main(_args \\ []) do
    pid = DspUart.get_serial_connection()
    [
      eq(:EQ_FL_BAND6, 5.8, 1.0),
      eq(:EQ_FL_BAND7, 5.8, 1.0),
      eq(:EQ_FL_BAND9, 4.0, -2.0)
    ]
    |> Enum.map(fn m -> DspUart.send_serial_message(pid, m) end)
  end

end
