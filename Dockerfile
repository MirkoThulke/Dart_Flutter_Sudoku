##############################################################################
# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.
#
# Dockerfile for Flutter + Rust + Android + Web integration testing
# Fully self-contained environment for desktop, web, and mobile builds.
#
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

# Notes:
# - Flutter Android builds require Android SDK & NDK.
# - iOS builds cannot be compiled on Linux; Xcode on macOS is required.
# - Rust FFI for Android requires proper NDK toolchains (CC_aarch64_linux_android etc.).


# ------------------------------------------------------------
# How to Use This Dockerfile
# ------------------------------------------------------------

# Build the environment image once:
#   docker build -t flutter_rust_env .
#   docker build --no-cache -t flutter_rust_env .

# start an existing container interactively:
#   docker start -ai flutter_rust_env
# stop an existing container interactively:
#  docker stop flutter_rust_env
#  docker kill flutter_rust_env
#  docker rm flutter_rust_env
# 
# list all docker images / containers:
#   docker image ls
#   docker ps -s
#
# remove docker images / containers:
#  docker rmi <image_id>
#  docker rm <container_id>
#
# Clean build cache only :              docker builder prune
# To force:                             docker builder prune -f
# remove all builds for all builders:   docker builder prune --all -f
#
# Factory reset !! (removes all images, containers, volumes, networks not in use):
#  docker system prune -a --volumes -f
#  docker buildx prune --all --force
#  docker system prune -af --volumes
#  docker builder prune -af
#  docker builder prune -f  #Does not remove images !!
#  docker image prune -f  # Does not remove containers !!
#
# enter the docker container interactively:
#   docker run -it --rm -v /home/mirko/sudoku:/app flutter_rust_env /bin/bash
# Run the container with your local project mounted and build the project:
#   docker run --rm -v ${PWD}:/app -w /app flutter_rust_env bash -c "./scripts/build_all.sh release"
# ------------------------------------------------------------


# ------------------------------------------------------------
# Install essential packages
# ------------------------------------------------------------
# - curl, git: download and version control
# - unzip, xz-utils, zip: handle compressed files
# - libglu1-mesa: OpenGL library for desktop GUI tests
# - build-essential, cmake, ninja-build: compilation tools
# - python3, python3-pip, clang, pkg-config: build dependencies
# - openjdk-17-jdk: Android Java SDK


# ------------------------------------------------------------
# Add to Dockerfile after installing essential packages // for debugging on phone
#       Connect Your Android Phone (Windows Host)
#       Enable USB debugging on your phone.
#       Connect the phone via USB.

#       On your Windows host, switch to TCP/IP:
#       adb tcpip 5555
#       adb connect <PHONE_IP>:5555

#       
#       Example:
#       adb connect 192.168.1.42:5555


#       Verify connection:
#       adb devices

#       You should see:
#       192.168.1.42:5555 device

#       Your phone is now reachable over Wi-Fi — Docker doesn’t need USB access.

# ------------------------------------------------------------
# Optional: Setup ADB for Android device debugging over USB/Wi-Fi
# ------------------------------------------------------------

# Steps for connecting an Android phone from host:
# 1. Enable USB debugging on phone.
# 2. adb tcpip 5555 (on host)
# 3. adb connect <PHONE_IP>
# 4. adb devices to verify connection

# ---------- Multi-stage Dockerfile: Flutter + Android + Rust + Chrome ----------

# Build with log print to shell ON:
#   DOCKER_BUILDKIT=1 docker build --progress=plain -t flutter_rust_env .
#   DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t flutter_rust_env .

# ---------- Debugg into the built image on docker image layer level ----------
#   DOCKER_BUILDKIT=0 docker build -t flutter_rust_env . # (disable buildkit for layer inspection)
#   -> check internemage layers hash IDs .... then
#   docker run -it --rm <IMAGE_ID> /bin/bash

# ----------- docker debug my-app -----------
#   docker debug my-app
# --------------------------------------------

# ---------- Lint Dockerfile ---------
#   docker build --check .  # check rules without building
#   docker build --debug .  # 
# ------------------------------------


# ============================================================
# Base stage (ENV definitions)
# ============================================================
# ============================================================
# Global Build Arguments
#   Use ARG for build-time configuration (like versions of Java, Flutter, SDK tools).
#   ARG values on top-level are default values for all stages, but values are not inherited inside the stages.
#   ARG values are not available inside stage unless re-declared explicitly !
#   Use ENV for runtime configuration (like paths, SDK roots, API keys for running container, PATH additions).
# ============================================================

# ============================================================
#   Stage	            Base image	            Why
# ============================================================
#   env	                ubuntu:22.04	        Defines ENV only
#   base	            env	                    Adds system packages
#   android	            base	                Adds Android SDK
#   flutter	            android	                Needs Android SDK + system + ENV
#   rust	            base	                Needs system packages + ENV
# ============================================================

FROM ubuntu:22.04 AS env


# VERSIONS
ENV JAVA_VERSION=17

# check for updates on https://developer.android.com/studio#command-line-tools-only
ENV ANDROID_SDK_TOOLS_VERSION=13114758

ENV FLUTTER_VERSION=3.35.7
ENV RUST_VERSION=1.91.1

ENV NDK_MAIN=28.2.13676358
ENV CMAKE_MAIN=3.22.1
ENV COMPILE_SDK_BACKUP=34
ENV COMPILE_SDK=34
ENV BUILD_TOOLS_BACKUP=34.0.0
ENV BUILD_TOOLS=34.0.0


# PATHS
ENV ANDROID_SDK_ROOT=/opt/android/sdk
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV SDKMANAGER=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager
ENV ANDROID_NDK_HOME=${ANDROID_SDK_ROOT}/ndk/${NDK_MAIN}
ENV CHROME_USER_HOME=/usr/bin/google-chrome

ENV RUSTUP_HOME=/opt/rust/rustup
ENV CARGO_HOME=/opt/rust/cargo
ENV RUST_HOME=/opt/rust
ENV FLUTTER_ROOT=/opt/flutter
ENV ANDROID_ROOT=/opt/android
ENV GOOGLE_ROOT=/opt/google

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64

# JENKINS
ENV HOME=/home/jenkins
ENV XDG_CONFIG_HOME=/home/jenkins/.config
ENV XDG_CACHE_HOME=/home/jenkins/.cache

#OTHER OPTOIONS
ENV FLUTTER_SUPPRESS_ANALYTICS=true
ENV FLUTTER_ALLOW_ROOT=true

ENV JAVA_TOOL_OPTIONS="-Dhttps.protocols=TLSv1.2"
ENV _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

ENV BUILD_MODE=ci
ENV DEBIAN_FRONTEND=noninteractive

ENV CHROME_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --headless"

# PATH additions : 
# ${JAVA_HOME}/bin
# ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
# ${FLUTTER_ROOT}/bin
# ${FLUTTER_ROOT}/bin/cache/dart-sdk/bin
# $CARGO_HOME/bin
# ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin

ENV PATH="${JAVA_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${FLUTTER_ROOT}/bin:${FLUTTER_ROOT}/bin/cache/dart-sdk/bin:${CARGO_HOME}/bin:${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}"


# ============================================================
# Stage: base
# ============================================================

FROM env AS base

# Essential + 32-bit libraries
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      curl wget unzip git xz-utils zip ca-certificates \
      build-essential pkg-config libglu1-mesa clang ninja-build \
      gnupg2 fonts-liberation \
      libc6:i386 libncurses6:i386 libstdc++6:i386 zlib1g:i386 \
      lib32z1 lib32ncurses6 lib32stdc++6 \
 && rm -rf /var/lib/apt/lists/*

# Java
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openjdk-${JAVA_VERSION}-jdk \
 && rm -rf /var/lib/apt/lists/*


RUN mkdir -p ${ANDROID_SDK_ROOT}


# ============================================================
# Stage: android
# ============================================================

FROM base AS android

# Retry helper
RUN printf '#!/bin/bash\nset -e\nfor i in 1 2 3; do "$@" && exit 0 || sleep $((i*10)); done; exit 1\n' \
 > /usr/local/bin/retry \
 && chmod +x /usr/local/bin/retry

# Install Android command-line tools (correct layout)
RUN set -eux; \
    cd /tmp; \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip" -O tools.zip; \
    unzip -q tools.zip -d cmdline-tools-temp; \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest; \
    # Move contents directly to 'latest'
    mv cmdline-tools-temp/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/; \
    chmod -R +x ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin; \
    rm -rf /tmp/* cmdline-tools-temp


# Accept licenses (cache optional, commits to image)
RUN yes | ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} --licenses


# Install essential SDK packages (split to avoid TLS/network failures)
RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} "platform-tools"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "platforms;android-${COMPILE_SDK_BACKUP}"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "platforms;android-${COMPILE_SDK}"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "build-tools;${BUILD_TOOLS_BACKUP}"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "build-tools;${BUILD_TOOLS}"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "ndk;${NDK_MAIN}"

RUN retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
    "cmake;${CMAKE_MAIN}"

# ============================================================
# Stage: flutter
# ============================================================

FROM android AS flutter


# Download Flutter SDK tarball
RUN set -eux; \
    cd /opt; \
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz; \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz; \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Make Flutter git repo safe for root (system-wide)
RUN git config --system --add safe.directory /opt/flutter

# Tell Flutter where Android SDK is
RUN flutter config --android-sdk ${ANDROID_SDK_ROOT} --no-analytics

# Switch to Jenkins UID before precache
USER 2000

# Pre-cache Flutter engine binaries
RUN flutter precache --android --force


# Hard guards (APK-relevant only) (fail fast if something is missing)
RUN test -d /opt/flutter/bin/cache/artifacts/engine/android-arm \
 && test -d /opt/flutter/bin/cache/artifacts/engine/android-arm64 \
 && test -d /opt/flutter/bin/cache/artifacts/engine/android-x64

 # Final sanity check
RUN flutter doctor -v

# ============================================================
# Stage: rust
# ============================================================

FROM base AS rust

# Sanity check
RUN echo "RUSTUP_HOME=$RUSTUP_HOME" && echo "CARGO_HOME=$CARGO_HOME"

# Install Rust and Cargo into /opt/rust
RUN mkdir -p /opt/rust && \
    curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain ${RUST_VERSION} && \
    $CARGO_HOME/bin/rustup target add \
        aarch64-linux-android \
        armv7-linux-androideabi \
        x86_64-linux-android \
        i686-linux-android && \
    $CARGO_HOME/bin/cargo install cargo-ndk

# ============================================================
# Stage: chrome
# ============================================================

FROM base AS chrome

RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
 | gpg --dearmor -o /usr/share/keyrings/google.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
 > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*



# ============================================================
# Stage: final
# ============================================================

FROM base AS final

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl unzip git xz-utils zip ca-certificates \
      openjdk-${JAVA_VERSION}-jre-headless libglu1-mesa \
      build-essential pkg-config clang cmake \
 && rm -rf /var/lib/apt/lists/*


# Copy from Android SDK stage to final image
# COPY --from=android ${ANDROID_SDK_ROOT} ${ANDROID_SDK_ROOT}

COPY --from=android ${ANDROID_SDK_ROOT}/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools
COPY --from=android ${ANDROID_SDK_ROOT}/platform-tools ${ANDROID_SDK_ROOT}/platform-tools
COPY --from=android ${ANDROID_SDK_ROOT}/platforms ${ANDROID_SDK_ROOT}/platforms
COPY --from=android ${ANDROID_SDK_ROOT}/build-tools ${ANDROID_SDK_ROOT}/build-tools
COPY --from=android ${ANDROID_SDK_ROOT}/ndk ${ANDROID_SDK_ROOT}/ndk
COPY --from=android ${ANDROID_SDK_ROOT}/cmake ${ANDROID_SDK_ROOT}/cmake
COPY --from=android ${ANDROID_SDK_ROOT}/licenses ${ANDROID_SDK_ROOT}/licenses

# Copy from Flutter stage to final image
COPY --from=flutter ${FLUTTER_ROOT} ${FLUTTER_ROOT}

# Copy from Chrome stage to final image
COPY --from=chrome ${CHROME_USER_HOME} ${CHROME_USER_HOME}
COPY --from=chrome ${GOOGLE_ROOT} ${GOOGLE_ROOT}

# Copy from Rust stage to final image (cargo and rustup)
COPY --from=rust ${RUST_HOME} ${RUST_HOME}

# Make Flutter git repo safe for root
RUN git config --system --add safe.directory /opt/flutter

# Final sanity check (no downloads)
RUN flutter doctor --verbose


# Jenkins user Ownership
RUN chown -R 2000:2000 ${FLUTTER_ROOT}
RUN chown -R 2000:2000 ${RUST_HOME}
RUN chown -R 2000:2000 ${ANDROID_ROOT}


# Create writable HOME for Jenkins user
RUN mkdir -p ${HOME} \
 && chown -R 2000:2000 ${HOME}


# Standard Jenkins User für Builds
USER 2000


# Final sanity checks
RUN echo "PATH=$PATH" \
 && echo "Checking binaries:" \
 && command -v java \
 && command -v flutter \
 && command -v cargo \
 && command -v rustup \
 && command -v sdkmanager

RUN echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" \
 && echo "FLUTTER_ROOT=$FLUTTER_ROOT" \
 && echo "CARGO_HOME=$CARGO_HOME" \
 && echo "RUSTUP_HOME=$RUSTUP_HOME" \
 && echo "JAVA_HOME=$JAVA_HOME" \
 && echo "ANDROID_NDK_HOME=$ANDROID_NDK_HOME"

WORKDIR /app
CMD ["/bin/bash"]
