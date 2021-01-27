# Use native image as a base. Don't emulate as this is a dev image
FROM rust:1.49

WORKDIR /app/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    zip \
    g++-mingw-w64-i686 \
    && rm -rf /var/lib/apt/lists/

# Load the toolchain override; and cache it separately
COPY rust-toolchain /app/
RUN rustup show

# Trick cargo into getting the dependencies so docker can cache them
COPY Cargo.toml /app/
RUN mkdir src \
    && touch src/lib.rs \
    && cargo build --release

# Do the real build
COPY . /app/
RUN cargo build --release

WORKDIR /app/package

RUN cp /app/target/i686-pc-windows-gnu/release/zipfixup.dll . \
    && cp /app/Misc/* . \
    && ls -l \
    && zip ZipperFixup-`cargo pkgid | cut -d# -f2 | cut -d: -f2`.zip ./* \
    && ls -l

CMD ["/bin/bash", "-c", "cp ./ZipperFixup*.zip /package/"]
