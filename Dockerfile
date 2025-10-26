##############################################################################

# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.

# Date: 2025, VERSAILLES, FRANCE

# License: "All Rights Reserved – View Only"

# Permission is hereby granted to view and share this code in its original,
# unmodified form for educational or reference purposes only.

# Any other use, including but not limited to copying, modification,
# redistribution, commercial use, or inclusion in other projects, is strictly
# prohibited without the express written permission of the author.

# The Software is provided "AS IS", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose, and noninfringement. In no event shall the
# author be liable for any claim, damages, or other liability arising from the
# use of the Software.

# Contact: MIRKO THULKE (for permission requests)

##############################################################################


# Notes
# For Flutter Android builds, the container must have Android SDK & NDK.
# For iOS builds, Docker on Linux cannot compile — iOS requires Xcode on macOS.
# Rust FFI binaries for Android require setting NDK toolchains properly. You can set CC_aarch64_linux_android etc. if needed.



##  How to Use This Dockerfile

## Build the Docker image:

# docker build -t flutter-rust-builder .


## Run the container with your local project mounted:

# docker run --rm -it \
#  -v /path/to/project:/app \
#  -v ~/.cargo:/root/.cargo \
#  -v ~/.pub-cache:/root/.pub-cache \
#  flutter-rust-builder




# Base image
FROM ubuntu:22.04

# -------------------------------
# Environment variables
# -------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"
ENV RUST_BACKTRACE=1
ENV ANDROID_SDK_ROOT=/opt/android/sdk
ENV ANDROID_NDK_HOME=/opt/android/ndk
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
WORKDIR /app

# -------------------------------
# Install essential packages
# -------------------------------
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa build-essential \
    cmake ninja-build python3 python3-pip clang pkg-config openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install Flutter SDK
# -------------------------------
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable \
    && flutter doctor

# -------------------------------
# Install Rust toolchain
# -------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# -------------------------------
# Install Android SDK Command Line Tools
# -------------------------------
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools \
    && mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm sdk-tools.zip

# Accept Android licenses
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses

# -------------------------------
# Install cargo-ndk
# -------------------------------
RUN cargo install cargo-ndk

# -------------------------------
# Copy project (or mount as volume)
# -------------------------------
COPY . /app

# -------------------------------
# Make build script executable
# -------------------------------
RUN chmod +x build_rust.sh

# -------------------------------
# Build Rust FFI libraries
# -------------------------------
RUN ./build_rust.sh

# -------------------------------
# Pre-fetch Flutter dependencies
# -------------------------------
RUN flutter pub get

# -------------------------------
# Optional: Build Flutter APK (Android)
# -------------------------------
# RUN flutter build apk --release

# -------------------------------
# Default command
# -------------------------------
# Build Rust + Flutter APK automatically every time it runs:
CMD ["bash", "-c", "./build_rust.sh && flutter build apk --release && bash"]

