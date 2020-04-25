# MacAudioDsp

This software should be able to configure a MacAudio Reference 2.1 DSP amplifier.  The software provided with the DSP is fairly limited.  Notable limitations are:
 * the lack of Linkwitz-Riley crossover filters, or indeed any type of crossover other than butterworth.
 * There is no way to link two channels together to adjust EQ/delay etc.
 * The steps between delay settings are too large.
 * The hardware supports full 11-band parametric EQ, however, I don't know how to expose this.
 * There are commands defined in the XML schema for the original software that aren't implemented, such as treble and bass settings on all individual channels.
 * The EQ commands define a coefficient, g, which is not implemented.  Need to test if it can specify the frequency for full parametric EQ.
 * The Crossover commands define a coefficient, k, which is not implemented.
 * There are arbitray limitations on Q values.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mac_audio_dsp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mac_audio_dsp, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mac_audio_dsp](https://hexdocs.pm/mac_audio_dsp).

