defmodule PhoenixBakery.Gzip do
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @behaviour Phoenix.Digester.Compressor

  @default_opts %{
    level: :best_compression,
    window_bits: 15,
    mem_level: 9
  }

  import PhoenixBakery

  @impl true
  def file_extensions, do: ~w[.gz]

  @impl true
  def compress_file(file_path, content) do
    if gzippable?(file_path) do
      gzip(content)
    else
      :error
    end
  end

  defp gzip(content) do
    zstream = :zlib.open()
    options = options(:gzip, @default_opts)

    data =
      try do
        :zlib.deflateInit(
          zstream,
          options.level,
          :deflated,
          16 + options.window_bits,
          options.mem_level,
          :default
        )

        data = :zlib.deflate(zstream, content, :finish)
        :zlib.deflateEnd(zstream)
        data
      after
        :zlib.close(zstream)
      end

    IO.iodata_to_binary(data)
  end
end
