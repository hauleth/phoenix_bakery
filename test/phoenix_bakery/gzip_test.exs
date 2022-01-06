defmodule PhoenixBakery.GzipTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  @assets_dir "test/fixtures/"

  @tag :tmp_dir
  test "encode files", %{tmp_dir: tmp_dir} do
    run([Path.join(@assets_dir, "regular"), "-o", tmp_dir])
    files = File.ls!(tmp_dir)

    refute "empty.txt.gz" in files
    assert "test.txt.gz" in files
    assert_integral([tmp_dir, "test.txt.gz"])
    assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.gz" in files
    assert_integral([tmp_dir, "test-2482cc4df40800ca35f6b294884c0fe6.txt.gz"])
  end

  @tag :tmp_dir
  @tag :huge
  test "encode huge files", %{tmp_dir: tmp_dir} do
    run([Path.join(@assets_dir, "huge"), "-o", tmp_dir])

    files = File.ls!(tmp_dir)

    assert "roman-roads.svg.gz" in files
    assert_integral([tmp_dir, "roman-roads.svg.gz"])
    assert "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.gz" in files
    assert_integral([tmp_dir, "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.gz"])
  end

  defp run(opts) do
    capture_io(fn ->
      Mix.Task.rerun("phx.digest", opts)
    end)
  end

  defp assert_integral(file) do
    path = PhoenixBakery.find_executable(:gzip)

    assert {_, 0} = System.cmd(path, ["-t", Path.join(List.wrap(file))])
  end
end
