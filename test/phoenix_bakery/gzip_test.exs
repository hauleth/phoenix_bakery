defmodule PhoenixBakery.GzipTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  @assets_dir "test/fixtures/"

  @tag :tmp_dir
  test "encode files", %{tmp_dir: tmp_dir} do
    run([@assets_dir, "-o", tmp_dir])
    files = File.ls!(tmp_dir)

    refute "empty.txt.gz" in files
    assert "test.txt.gz" in files
    assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.gz" in files
  end

  defp run(opts) do
    capture_io(fn ->
      Mix.Task.rerun("phx.digest", opts)
    end)
  end
end
