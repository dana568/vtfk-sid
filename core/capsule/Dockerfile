FROM rust:1.99 AS build
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs \
    && cargo build --release && rm -rf src
COPY src ./src
RUN touch src/main.rs && cargo build --release

FROM debian:12-slim
COPY --from=build /app/target/release/sidkit /usr/local/bin/sidkit
CMD ["/usr/local/bin/sidkit"]
