defmodule PhoenixBakery.Zstd do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @compile {:no_warn_undefined, :zstd}

  @behaviour Phoenix.Digester.Compressor

  @default_opts %{
    level: 22
  }

  import PhoenixBakery

  require Logger

  @impl true
  def file_extensions, do: ~w[.zst]

  @impl true
  def compress_file(file_path, content) do
    if gzippable?(file_path) do
      compress(content)
    else
      :error
    end
  end

  defp compress(content) do
    case encode(content) do
      {:ok, compressed} when byte_size(compressed) < byte_size(content) ->
        {:ok, compressed}

      _ ->
        :error
    end
  end

  defp encode(content) do
    options = options(:zstd, @default_opts)

    cond do
      Code.ensure_loaded?(:zstd) and function_exported?(:zstd, :compress, 2) ->
        {:ok,
         content
         |> :zstd.compress(%{compressionLevel: options.level})
         |> :erlang.iolist_to_binary()}

      Code.ensure_loaded?(:ezstd) and function_exported?(:ezstd, :compress, 2) ->
        {:ok, :ezstd.compress(content, options.level)}

      path = find_executable(:zstd) ->
        run(:zstd, content, path, ~w[-c --ultra -#{options.level}])

      true ->
        Logger.warning("No `zstd` utility")
        :error
    end
  end
end
