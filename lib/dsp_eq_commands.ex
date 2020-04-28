defmodule DspEqCommands do
  import DspConstants

  @spec eq_cmd_group_from_channel_band(atom, pos_integer) :: String.t()
  def eq_cmd_group_from_channel_band(channel, band) do
    schan = Atom.to_string(channel) |> String.upcase()
    iband = Integer.to_string(band)
    "EQ_#{schan}_BAND#{iband}"
  end

  @spec freq_from_channel_band(atom, pos_integer) :: any
  def freq_from_channel_band(channel, band) do
    cond do
      Enum.member?(third_octave_band_channels(), channel) ->
        third_octave_band_peq_enums()[band]
      Enum.member?(eleven_band_channels(), channel) ->
        eleven_band_peq_enums()[band]
      true -> nil
    end
  end

  @spec eq(atom, keyword) :: [binary]
  def eq(channel, opts \\ []) do
    %{band: band, q: q, gain: gain} =
      [band: 1, q: 5.8, gain: 0.0]
      |> Keyword.merge(opts)
      |> Enum.into(%{})
    cmd_group = eq_cmd_group_from_channel_band(channel, band)
    dsp_command = DspCommands.load_dsp_commands()
    freq = freq_from_channel_band(channel, band)
    DspEq.dsp_eq_coeffs(freq, q, gain)
    |> Enum.map(fn {k, v} ->
      dsp_command.(cmd_group, k, v)
      |> DspUart.serialise_mcu_command()
    end)
  end
end
