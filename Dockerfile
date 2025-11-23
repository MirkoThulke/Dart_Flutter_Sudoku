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
# docker build -t flutter_rust_env .
# or as delta build : docker build . -t sudoku:latest

# Run the container with your local project mounted:
# docker run --rm \
# -v ${PWD}:/app \
# -w /app \
# flutter_rust_env \
# bash -c "./scripts/build_all.sh release"
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



FROM ubuntu:22.04

# ------------------------------------------------------------
# Basic environment
# ------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_SDK_ROOT=/opt/android/sdk
ENV ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk
ENV RUST_BACKTRACE=1
ENV DOCKER_ENV=1

# ------------------------------------------------------------
# Locked versions (reproducible)
# ------------------------------------------------------------
ENV FLUTTER_VERSION=3.35.7
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_DART_VERSION=3.9.2
ENV ANDROID_SDK_TOOLS_VERSION=9477386
ENV ANDROID_NDK_VERSION=29.0.14206865
ENV GRADLE_VERSION=8.7
ENV CMAKE_VERSION=3.30.0
ENV RUST_VERSION=1.91.1

# PATH (updated again after Rust install)
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

WORKDIR /app

# ------------------------------------------------------------
# Essential packages
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa build-essential \
    cmake ninja-build python3 python3-pip clang pkg-config openjdk-17-jdk \
    wget gnupg2 ca-certificates xvfb adb \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install headless Chrome
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
# Install Flutter
# ------------------------------------------------------------
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable \
    && git config --system --add safe.directory $FLUTTER_HOME \
    && chown -R flutteruser:flutteruser $FLUTTER_HOME

# ------------------------------------------------------------
# Install Android SDK + fixed NDK
# ------------------------------------------------------------
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools \
    && mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm sdk-tools.zip \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses \
    && rm -rf $ANDROID_SDK_ROOT/ndk/* \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platforms;android-34" \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "build-tools;34.0.0" \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "cmake;${CMAKE_VERSION}" \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "ndk;${ANDROID_NDK_VERSION}" \
    && chown -R flutteruser:flutteruser $ANDROID_SDK_ROOT

# ------------------------------------------------------------
# Switch to non-root user
# ------------------------------------------------------------
USER flutteruser
WORKDIR /app

# Add Rust PATH
ENV PATH="$HOME/.cargo/bin:$PATH"

# ------------------------------------------------------------
# Pre-warm Flutter (creates cache)
# ------------------------------------------------------------
RUN flutter --version

# ------------------------------------------------------------
# Install Rust + cargo-ndk
# ------------------------------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup default ${RUST_VERSION} \
    && rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android \
    && cargo install cargo-ndk

# ------------------------------------------------------------
# Permissions fix
# ------------------------------------------------------------
RUN chmod -R a+w $FLUTTER_HOME/bin/cache $ANDROID_SDK_ROOT

# ------------------------------------------------------------
# Default command
# ------------------------------------------------------------
CMD ["bash", "-c", "flutter --version && rustc --version"]
