defmodule Dsp do
  import DspEqCommands

  def reset_eq() do
   for channel <- [:fl, :fr], band <- 1..31 do
     eq channel, band: band, q: 5.8, gain: 0.0
   end
   |> List.flatten()
   |> Enum.chunk_every(8)
   |> Enum.map(&:erlang.list_to_binary/1)
   |> IO.inspect()
  end

  def main(_args \\ []) do
    reset_eq()
    eq :fl, band: 6, q: 5.8, gain: 1.0
  end
end
