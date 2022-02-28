ARG IMAGE=rust:1.59.0-alpine3.15
FROM ${IMAGE} as Builder
ARG RUSTFLAGS="-C target-feature=-crt-static"
RUN apk add --no-cache musl-dev libpq-dev
RUN cargo install diesel_cli --no-default-features --features postgres --force
RUN cargo install watchexec-cli
WORKDIR /build
RUN cp $(which diesel) ./diesel && cp $(which watchexec) ./watchexec

FROM ${IMAGE}
RUN apk add --no-cache musl-dev libpq-dev
COPY --from=builder /build/ /bin/
RUN mkdir -p /target
WORKDIR /app
ENTRYPOINT rm -rf target || true && watchexec -w=/app -r "rm -rf target || true && CARGO_TARGET_DIR=/target cargo run"