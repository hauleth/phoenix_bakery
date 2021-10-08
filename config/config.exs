import Config

config :logger, :console,
  format: "[$level] $metadata $message\n",
  metadata: :all

config :phoenix,
  json_library: Jason,
  static_compressors: [
    PhoenixBakery.Gzip,
    PhoenixBakery.Brotli,
    PhoenixBakery.Zstd
  ]
