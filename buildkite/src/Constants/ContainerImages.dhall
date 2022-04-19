-- TODO: Automatically push, tag, and update images #4862
-- NOTE: minaToolchainStretch is also used for building Ubuntu Bionic packages in CI
{
  toolchainBase = "codaprotocol/ci-toolchain-base:v3",
  minaToolchainStretch = "gcr.io/o1labs-192920/mina-toolchain@sha256:281cfb0203c223422340325d778d655796f0610b86c76e4f557026bd97c60279",
  minaToolchainBuster = "gcr.io/o1labs-192920/mina-toolchain@sha256:dbc6803da7ff8c42831c4f444591657e8b3b6260bee4f85e30dbd13c86346491",
  minaToolchainBullseye = "gcr.io/o1labs-192920/mina-toolchain@sha256:aa544043a4b9dca7bba86a286788ec586d5c8a9681911d75e6350784debd2ce1",
  minaToolchainFocal = "gcr.io/o1labs-192920/mina-toolchain@sha256:e9503ee658a02ee008ad4ee8d963e7b708b19b652a80a4ea21aa3ea023ca18ab",
  delegationBackendToolchain = "gcr.io/o1labs-192920/delegation-backend-production@sha256:8ca5880845514ef56a36bf766a0f9de96e6200d61b51f80d9f684a0ec9c031f4",
  elixirToolchain = "elixir:1.10-alpine",
  rustToolchain = "codaprotocol/coda:toolchain-rust-e855336d087a679f76f2dd2bbdc3fdfea9303be3",
  nodeToolchain = "node:14.13.1-stretch-slim",
  ubuntu1804 = "ubuntu:18.04",
  xrefcheck = "serokell/xrefcheck@sha256:8fbb35a909abc353364f1bd3148614a1160ef3c111c0c4ae84e58fdf16019eeb"
}
