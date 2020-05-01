defmodule Dsp do
  import DspEqCommands

  def reset_eq() do
   woofers = for channel <- [:fl, :fr], band <- 1..31 do
     eq channel, band: band, q: 5.8, gain: 0.0
   end
   tweeters = for channel <- [:rl, :rr], band <- 1..11 do
     eq channel, band: band, q: 5.8, gain: 0.0
   end
   subwoofer = for channel <- [:sl, :sr], band <- 1..11 do
     eq channel, band: band, q: 5.8, gain: 0.0
   end
   [woofers, tweeters, subwoofer]
   |> List.flatten()
   |> Enum.chunk_every(8)
   |> Enum.map(&:erlang.list_to_binary/1)
   |> IO.inspect()
  end

  def main(_args \\ []) do
    reset_messages = reset_eq()
    DspUart.commit_messages("ttyUSB0", reset_messages)
  end
end
