
# TODO: Checkout Protobufs library
# TODO: Add some basic level of error handling
# TODO: Add support for custom Protobuf-Lite-only CMakeLists.txt and install.cmake files
# TODO: Auto-detect cmake?

# For each architecture, repeat the custom toolchain build
for target_arch in armeabi armeabi-v7a arm64-v8a x86 x86_64; do
    
    # Cleanup any previous builds
    if [ -d "$target_arch" ]; then rm -r $target_arch; fi
    mkdir $target_arch && cd $target_arch

/Users/$USER/Library/Android/sdk/cmake/3.6.4111459/bin/cmake \
    -Dprotobuf_BUILD_SHARED_LIBS=ON \               # Build shared (.so), instead of defaulted static libs (.a)
    -Dprotobuf_BUILD_TESTS=OFF \                    # Remove tests to speed up builds
    -Dprotobuf_BUILD_EXAMPLES=OFF \                 # Remove examples to speed up builds
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=/Users/$USER/Library/Android/sdk/cmake/3.6.4111459/android.toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX=./dist \                 # Location of 'make install' libs and includes
    -DANDROID_NDK=/Users/$USER/Library/Android/sdk/ndk-bundle \
    -DANDROID_TOOLCHAIN=gcc \                       # Need to use gcc instead of clang because we're using gnustl
    -DANDROID_ABI=$target_arch \
    -DANDROID_NATIVE_API_LEVEL=21 \
    -DANDROID_STL=gnustl_shared \                   # TODO: Why did libc++ fail out due to lack of TR1 support? PB is picking up the wrong clang version
    -DANDROID_LINKER_FLAGS="-landroid -llog" \      # Adding linker flags to support __android_log_write - supports libandroid and liblog
    -DANDROID_CPP_FEATURES="rtti exceptions" \      # TODO: Needed for Protobuf Lite?
    ..

    # Run the makefile
    make
    # Export includes and libs to dist
    make install

    # Leave this directory
    cd ..

done 
