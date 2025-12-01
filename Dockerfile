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
# or as delta build : docker build . -t sudoku:latest

# start an existing container interactively:
#   docker start -ai flutter_rust_env
# enter the docker container interactively:
#   docker run -it --name flutter_rust_env ubuntu:22.04 /bin/bash

# Run the container with your local project mounted:
#   docker run --rm \
# -v ${PWD}:/app \
# -w /app \
#   flutter_rust_env \
#   bash -c "./scripts/build_all.sh release"
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


# ------------------------------------------------------------
# Base image
# ------------------------------------------------------------
FROM ubuntu:22.04


ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_SDK_ROOT=/opt/android/sdk
ENV ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk
ENV RUST_BACKTRACE=1
ENV DOCKER_ENV=1


# ------------------------------------------------------------
# Locked versions (reproducible)
# ------------------------------------------------------------
ARG NDK_MAIN=28.0.13004108
ARG NDK_LEGACY=26.1.10909125
ARG CMAKE_MAIN=3.22.1
ARG CMAKE_LEGACY=3.22.1

ENV FLUTTER_VERSION=3.35.7
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_DART_VERSION=3.9.2
ENV ANDROID_SDK_TOOLS_VERSION=9477386
ENV ANDROID_NDK_VERSION=${NDK_MAIN}
ENV ANDROID_NDK_LEGACY=${NDK_LEGACY}
ENV GRADLE_VERSION=8.9
ENV CMAKE_VERSION=${CMAKE_MAIN}
ENV CMAKE_VERSION_LEGACY=${CMAKE_LEGACY}
ENV RUST_VERSION=1.91.1

# PATH (updated again after Rust install)
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

WORKDIR /app

# ------------------------------------------------------------
# Essential packages
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa build-essential \
    cmake ninja-build python3 python3-pip clang pkg-config \
    openjdk-17-jdk wget gnupg2 ca-certificates xvfb adb \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Headless Chrome (optional)
# ------------------------------------------------------------
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Create non-root user
# ------------------------------------------------------------
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID flutteruser \
    && useradd -m -u $USER_ID -g $GROUP_ID -s /bin/bash flutteruser
ENV HOME=/home/flutteruser

# ------------------------------------------------------------
# Install Flutter (system-wide)
# ------------------------------------------------------------
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable \
    && git config --system --add safe.directory $FLUTTER_HOME \
    && chown -R flutteruser:flutteruser $FLUTTER_HOME


# ------------------------------------------------------------
# Install Android commandline-tools (robust version)
# ------------------------------------------------------------
RUN set -e \
 && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
 \
 # Download commandline-tools (known stable version)
 && curl -L -o /tmp/commandlinetools.zip \
      https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
 \
 # Check ZIP is valid
 && unzip -t /tmp/commandlinetools.zip > /dev/null \
 \
 # Extract
 && unzip /tmp/commandlinetools.zip -d $ANDROID_SDK_ROOT/cmdline-tools \
 && rm /tmp/commandlinetools.zip \
 \
 # Google sometimes uses cmdline-tools/ or tools/ — normalize it
 && if [ -d "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" ]; then \
        mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" \
           "$ANDROID_SDK_ROOT/cmdline-tools/latest"; \
    elif [ -d "$ANDROID_SDK_ROOT/cmdline-tools/tools" ]; then \
        mv "$ANDROID_SDK_ROOT/cmdline-tools/tools" \
           "$ANDROID_SDK_ROOT/cmdline-tools/latest"; \
    else \
        echo "❌ ERROR: commandline-tools folder not found after unzip"; \
        ls -R $ANDROID_SDK_ROOT/cmdline-tools; \
        exit 1; \
    fi \
 \
 # Ensure sdkmanager exists
 && if [ ! -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then \
        echo '❌ ERROR: sdkmanager not found — installation failed'; \
        exit 1; \
    fi \
 \
 # Install Android SDK components
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses \
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platforms;android-34" \
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "build-tools;34.0.0" \
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" \
 \
 # Install requested CMake
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "cmake;${CMAKE_MAIN}" \
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "cmake;${CMAKE_LEGACY}" \
 \
 # Install NDK
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "ndk;${NDK_MAIN}" \
 && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "ndk;${NDK_LEGACY}" \
 \
 && chown -R flutteruser:flutteruser $ANDROID_SDK_ROOT


# ------------------------------------------------------------
# Install SYSTEM-WIDE Gradle 8.7 (BEFORE changing user)
# ------------------------------------------------------------
RUN wget https://services.gradle.org/distributions/gradle-8.7-all.zip -O /tmp/gradle-8.7-all.zip \
    && mkdir -p /opt/gradle \
    && unzip /tmp/gradle-8.7-all.zip -d /opt/gradle \
    && rm /tmp/gradle-8.7-all.zip
ENV PATH="/opt/gradle/gradle-8.7/bin:$PATH"

# ------------------------------------------------------------
# Install Rust + cargo-ndk (as root)
# ------------------------------------------------------------
ENV CARGO_HOME=/opt/cargo
ENV RUSTUP_HOME=/opt/rustup
ENV PATH=$CARGO_HOME/bin:$PATH

RUN mkdir -p $CARGO_HOME $RUSTUP_HOME \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y \
    && rustup default ${RUST_VERSION} \
    && rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android \
    && cargo install cargo-ndk \
    && chmod -R a+w $CARGO_HOME $RUSTUP_HOME

# ------------------------------------------------------------
# Switch to non-root user
# ------------------------------------------------------------
USER flutteruser
WORKDIR /app

# Add Rust PATH for non-root
ENV PATH=$CARGO_HOME/bin:$PATH

# ------------------------------------------------------------
# Copy project into container
# ------------------------------------------------------------
COPY . /app

# ------------------------------------------------------------
# Pre-warm Flutter
# ------------------------------------------------------------
RUN flutter --version

# ------------------------------------------------------------
# Permissions fixes
# ------------------------------------------------------------
RUN chmod -R a+w $HOME/.gradle || true
RUN chmod -R a+w $FLUTTER_HOME/bin/cache $ANDROID_SDK_ROOT

# ------------------------------------------------------------
# Pre-download Gradle Wrapper (8.7)
# ------------------------------------------------------------
WORKDIR /app/android
RUN ./gradlew --version || true

# Back to project
WORKDIR /app

# ------------------------------------------------------------
# Default command
# ------------------------------------------------------------
CMD ["bash", "-c", "java -version && flutter --version && cd android && ./gradlew --version"]
