# PhoenixBakery

<!-- start:PhoenixBakery -->
Better compression for your Phoenix assets.

This is set of modules that implement [`Phoenix.Digester.Compressor`][]
behaviour which can be used together with Phoenix 1.6 or later for better
compression of the static assets served by `Plug.Static`.

[`Phoenix.Digester.Compressor`]: https://hexdocs.pm/phoenix/1.6.0/Phoenix.Digester.Compressor.html

## Installation

First thing to do is to add `PhoenixBakery` as a dependency.

```elixir
def deps do
  [
    {:phoenix_bakery, "~> 0.1.0", runtime: false}
  ]
end
```

And configure your `Plug.Static`:

```elixir
plug Plug.Static,
  encodings: [{"zstd", ".zst"}],
  gzip: true,
  brotli: true,
  # Rest of the options…
```

> #### WARNING {: .warning }
>
> Plug 1.12 do not support `:encodings` option and this option is ignored.
> So Zstandard-compressed files will not be served to the clients, even
> if client will have support for such format.

Then you need to configure your compressors via Phoenix configuration:

```elixir
config :phoenix,
  static_compressors: [
    # Pick all that you want to use
    PhoenixBakery.Gzip,
    PhoenixBakery.Brotli,
    PhoenixBakery.Zstd
  ]
```

[pr-1050]: https://github.com/elixir-plug/plug/pull/1050
<!-- end:PhoenixBakery -->

## Supported compressors

### `PhoenixBakery.Gzip`

<!-- start:PhoenixBakery.Gzip -->
Replacement of default [`Phoenix.Digester.Gzip`][] that provides better default
compression ratio (defaults to maximum possible) instead of default option that
compromises between compression speed and compression ratio.

It uses built-in `zlib` library, which mean, that there is no external
dependencies and it will work OotB on any installation.

#### Configuration

`PhoenixBakery.Gzip` provides 3 different knobs that you can alter via
application configuration:

```elixir
config :phoenix_bakery, :gzip_opts, %{
    level: :best_speed, # defaults to: `:best_compression`
    window_bits: 8, # defaults to: `15` (max)
    mem_level: 8 # defaults to: `9` (max)
  }
```

The shown above are defaults. For description of each option check [`zlib`
documentaion][erl-zlib]

[`Phoenix.Digester.Gzip`]: https://hexdocs.pm/phoenix/1.6.0/Phoenix.Digester.Gzip.html
[erl-zlib]: https://erlang.org/doc/man/zlib.html
<!-- end:PhoenixBakery.Gzip -->

### `PhoenixBakery.Brotli`

<!-- start:PhoenixBakery.Brotli -->
[Brotli][br] is algorithm that offers better compression ratio when compared
with Gzip, but at the cost of greater memory consumption during compression. It
provides quite good decompression speed. [It is supported by all major modern browsers][caniuse-br]

[br]: https://tools.ietf.org/html/rfc7932
[caniuse-br]: https://caniuse.com/brotli

#### Requirements

To use `PhoenixBakery.Brotli` you need at least one of:

- Add `{:brotli, ">= 0.0.0", runtime: false}` to use NIF version of the Brotli
  compressor. It requires C code compilation and it can slow down compilation a
  little as the compilation isn't the fastest.
- Have `brotli` utility available in `$PATH` or configured via
  `config :phoenix_bakery, :brotli, "/path/to/brotli"`

If none of the above is true then compressor will raise.

#### Configuration

```elixir
config :phoenix_bakery,
  brotli_opts: %{
    quality: 5 # defaults to: `11` (max)
  }
```
<!-- end:PhoenixBakery.Brotli -->

### `PhoenixBakery.Zstd`

<!-- start:PhoenixBakery.Zstd -->
[Zstandard][zstd] is algorithm that offers quite good compression ratio when
compared with Gzip, but slightly worse than Brotli, but with much better
decompression speed. It is currently not supported by browsers, but is already
IANA standard, so the rollout of the support should be pretty fast.

[zstd]: https://datatracker.ietf.org/doc/html/rfc8878

#### Requirements

To use `PhoenixBakery.Zstd` you need at least one of:

- Add `{:ezstd, "~> 1.0", runtime: false}` to use NIF version of Zstd
  compressor. It requires C code compilation and `git` tool to be available to
  fetch the code of `zstandard` code.
- Have `zstd` utility available in `$PATH` or configured via
  `config :phoenix_bakery, :zstd, "<path-to-zstd-executable>/zstd"`

If none of the above is true then compressor will raise.

#### Configuration

```elixir
config :phoenix_bakery,
  zstd_opts: %{
    level: 10 # defaults to: `22` (ultra-max)
  }
```
<!-- end:PhoenixBakery.Zstd -->

## Compression gains

Test files are composed out of Phoenix JS 1.6.2 library and Phoenix LiveView JS
0.16.4 bundled with ESBuild 0.12.17 installed from NPM repository using command

```sh
esbuild ./js/app.js --minify --target=es2020 --bundle --outdir=../priv/static/js --color=true
```

First we will declare our baseline. These are "regular" bundle and minified
bundle and the same files compressed with default `Phoenix.Digest.Gzip`
compressor shipped with Phoenix:

```
155311	phoenix_app.js
77351	phoenix_app.min.js
34341	phoenix_app.js.gz
24393	phoenix_app.min.js.gz
```

These are results produced by the compressors available in this package:

```
34033	phoenix_app.js.gz
30323	phoenix_app.js.zst
29017	phoenix_app.js.br
24339	phoenix_app.min.js.gz
23202	phoenix_app.min.js.zst
21843	phoenix_app.min.js.br
```

This show us that with this input file we gain only a little bit better results
for GZIP compression (<1% for non-minified and <0.5% for minified), but quite
substantial for different compression methods, namely:

- ~12% for ZSTD on non-minified file and ~5% on minified JS file
- ~15.5% for Brotli on non-minified file and ~10.5% on minified JS file

When compared with default compression from Phoenix.

ZSTD while it provides slightly worse compression ratio it provides better
decompression times, which may be preferred on slower or low powered devices.
