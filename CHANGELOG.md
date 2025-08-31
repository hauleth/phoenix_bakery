<a name="unreleased"></a>
## [Unreleased]

### Bug Fixes
- ignore compilation warnings about missing ZSTD module

### Documentation
- correct ZSTD extension

### Features
- warn about missing functionality instead of raising error
- use Erlang's zstd when it exists ([#8](https://github.com/hauleth/phoenix_bakery/issues/8))


<a name="v0.1.2"></a>
## [v0.1.2] - 2023-02-28
### Bug Fixes
- race condition with external binaries and files with the same content ([`50ad714`](https://github.com/hauleth/phoenix_bakery/commit/50ad714df9eccbacfa40b29cb7712cfc13cff6ae))
- update Phoenix dependency ([`585e6d2`](https://github.com/hauleth/phoenix_bakery/commit/585e6d2be6dbe181de1e4ff9e1c69de52485fa9b))

### Documentation
- use warning admonition in README ([`d07c766`](https://github.com/hauleth/phoenix_bakery/commit/d07c76601f6cc6ba24e61f9e063b208e92cee0d5))
- fix typo ([#2](https://github.com/hauleth/phoenix_bakery/issues/2)) ([`627a06a`](https://github.com/hauleth/phoenix_bakery/commit/627a06a4944ce43b1d98961f9963971c2985100f))


<a name="v0.1.1"></a>
## [v0.1.1] - 2021-10-08
### Bug Fixes
- lower supported Elixir version ([`4fb24f9`](https://github.com/hauleth/phoenix_bakery/commit/4fb24f95e0734a7d6c23d395eda68866a1261005))
- add tests for GZIP compressor ([`2c6d69f`](https://github.com/hauleth/phoenix_bakery/commit/2c6d69f6da2ec51c3a5298b374965b396317e8ac))
- rebuild modules on README change ([`bcb3b73`](https://github.com/hauleth/phoenix_bakery/commit/bcb3b7310321e34f8f83d214b3c3626ddeae09c2))

### Documentation
- fix configuration option name for Zstd ([`73c906c`](https://github.com/hauleth/phoenix_bakery/commit/73c906cd250f637ad4caa10ed5ab23d024eda0cb))
- fix link in README ([`1b6dc63`](https://github.com/hauleth/phoenix_bakery/commit/1b6dc637888c7b5f81e47f87b6208e5879084232))


<a name="v0.1.0"></a>
## v0.1.0 - 2021-10-06

[Unreleased]: https://github.com/hauleth/phoenix_bakery/compare/v0.1.2...HEAD
[v0.1.2]: https://github.com/hauleth/phoenix_bakery/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/hauleth/phoenix_bakery/compare/v0.1.0...v0.1.1
