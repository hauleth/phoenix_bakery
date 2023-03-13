defmodule PhoenixBakery.Brotli do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @behaviour Phoenix.Digester.Compressor

  import PhoenixBakery

  require Logger

  @impl true
  def file_extensions, do: ~w[.br]

  @impl true
  def compress_file(file_path, content, opts \\ []) do
    if gzippable?(file_path) do
      compress(content, opts)
    else
      :error
    end
  end

  defp compress(content, opts) do
    quality = Keyword.get(opts, :quality, 11)
    options = options(:brotli, %{quality: quality})

    case encode(content, options) do
      {:ok, compressed} when byte_size(compressed) < byte_size(content) ->
        {:ok, compressed}

      _ ->
        :error
    end
  end

  defp encode(content, options) do
    cond do
      Code.ensure_loaded?(:brotli) and function_exported?(:brotli, :encode, 1) ->
        :brotli.encode(content, %{quality: options.quality})

      path = find_executable(:brotli) ->
        run(:brotli, content, path, ~w[-c -q #{options.quality}])

      true ->
        raise "No `brotli` utility"
    end
  end
end
