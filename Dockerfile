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


# ------------------------------------------------------------  
#  How to Use This Dockerfile
# ------------------------------------------------------------  

# ------------------------------------------------------------  
# Build the Docker image:
# ------------------------------------------------------------  

# ------------------------------------------------------------  
# Build the environment image once :
#
#         docker build -t flutter_rust_env .
# ------------------------------------------------------------  

# ------------------------------------------------------------      
# Run the container with your local project mounted:
# ------------------------------------------------------------
#         docker run --rm \
#           -v ${PWD}:/app \
#           -w /app \
#           flutter_rust_env \
#           bash -c "./scripts/build_all.sh release"
# ------------------------------------------------------------

# ------------------------------------------------------------
# Base image
# ------------------------------------------------------------
FROM ubuntu:22.04

# ------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_SDK_ROOT=/opt/android/sdk
ENV ANDROID_NDK_VERSION=25.2.9519653
ENV ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:/root/.cargo/bin:$PATH"
ENV RUST_BACKTRACE=1
WORKDIR /app

# ------------------------------------------------------------
# Install essential packages
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa build-essential \
    cmake ninja-build python3 python3-pip clang pkg-config openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install Flutter SDK
# ------------------------------------------------------------
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable \
    && flutter doctor


# -------------------------------
# Install Rust toolchain
# -------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"


# Add Android targets for cross-compilation
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android

# ------------------------------------------------------------
# Install Android SDK Command Line Tools
# ------------------------------------------------------------
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools \
    && mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm sdk-tools.zip

# Accept Android licenses
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses

# ------------------------------------------------------------
# Install Android NDK (required for Rust cross-compilation)
# ------------------------------------------------------------
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
    "ndk;$ANDROID_NDK_VERSION" --sdk_root=$ANDROID_SDK_ROOT

# ------------------------------------------------------------
# Install cargo-ndk
# ------------------------------------------------------------
RUN cargo install cargo-ndk

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
RUN apt-get update && apt-get install -y adb

# Default command: just print Flutter and Rust versions
CMD ["bash", "-c", "flutter --version && rustc --version"]