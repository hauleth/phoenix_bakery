import Config

config :logger, :console,
  format: "[$level] $metadata $message\n",
  metadata: :all

config :phoenix,
  json_library: Jason,
  static_compressors: [PhoenixBakery.Brotli, PhoenixBakery.Zstd]
