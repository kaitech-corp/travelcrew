#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


variant_for_slice()
{
  case "$1" in
  "FirebaseFirestore.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "FirebaseFirestore.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseFirestore.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "FirebaseFirestore.xcframework/ios-arm64")
    echo ""
    ;;
  "FirebaseFirestore.xcframework/tvos-arm64")
    echo ""
    ;;
  "FirebaseFirestore.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "gRPC-Core.xcframework/tvos-arm64")
    echo ""
    ;;
  "gRPC-Core.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "gRPC-Core.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "gRPC-Core.xcframework/ios-arm64")
    echo ""
    ;;
  "gRPC-Core.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "gRPC-Core.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "Libuv-gRPC.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "Libuv-gRPC.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "Libuv-gRPC.xcframework/tvos-arm64")
    echo ""
    ;;
  "Libuv-gRPC.xcframework/ios-arm64")
    echo ""
    ;;
  "Libuv-gRPC.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "Libuv-gRPC.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "FirebaseCoreExtension.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "FirebaseCoreExtension.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "FirebaseCoreExtension.xcframework/tvos-arm64")
    echo ""
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64")
    echo ""
    ;;
  "gRPC-C++.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "gRPC-C++.xcframework/ios-arm64")
    echo ""
    ;;
  "gRPC-C++.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "gRPC-C++.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "gRPC-C++.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "gRPC-C++.xcframework/tvos-arm64")
    echo ""
    ;;
  "BoringSSL-GRPC.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "BoringSSL-GRPC.xcframework/tvos-arm64")
    echo ""
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64")
    echo ""
    ;;
  "BoringSSL-GRPC.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseSharedSwift.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "FirebaseSharedSwift.xcframework/tvos-arm64")
    echo ""
    ;;
  "FirebaseSharedSwift.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64")
    echo ""
    ;;
  "abseil.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "abseil.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "abseil.xcframework/tvos-arm64")
    echo ""
    ;;
  "abseil.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "abseil.xcframework/ios-arm64")
    echo ""
    ;;
  "abseil.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "leveldb-library.xcframework/tvos-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "leveldb-library.xcframework/tvos-arm64")
    echo ""
    ;;
  "leveldb-library.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "leveldb-library.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "leveldb-library.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "leveldb-library.xcframework/ios-arm64")
    echo ""
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "FirebaseFirestore.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "FirebaseFirestore.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseFirestore.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "FirebaseFirestore.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "FirebaseFirestore.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "FirebaseFirestore.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "gRPC-Core.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "gRPC-Core.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "gRPC-Core.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "gRPC-Core.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "gRPC-Core.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "gRPC-Core.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "Libuv-gRPC.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "Libuv-gRPC.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "Libuv-gRPC.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "Libuv-gRPC.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "Libuv-gRPC.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "Libuv-gRPC.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "FirebaseCoreExtension.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "FirebaseCoreExtension.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "FirebaseCoreExtension.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseCoreExtension.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "gRPC-C++.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "gRPC-C++.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "gRPC-C++.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "gRPC-C++.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "gRPC-C++.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "gRPC-C++.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "BoringSSL-GRPC.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "BoringSSL-GRPC.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "BoringSSL-GRPC.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "BoringSSL-GRPC.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseSharedSwift.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "FirebaseSharedSwift.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "FirebaseSharedSwift.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FirebaseSharedSwift.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "abseil.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "abseil.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "abseil.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "abseil.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "abseil.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "abseil.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "leveldb-library.xcframework/tvos-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "leveldb-library.xcframework/tvos-arm64")
    echo "arm64"
    ;;
  "leveldb-library.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "leveldb-library.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "leveldb-library.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "leveldb-library.xcframework/ios-arm64")
    echo "arm64"
    ;;
  esac
}

copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
        matched_all_archs="0"
        break
      fi

      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/FirebaseFirestore.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-simulator" "ios-arm64_x86_64-maccatalyst" "ios-arm64"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/gRPC-Core.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64" "ios-arm64_x86_64-simulator" "ios-arm64_x86_64-maccatalyst"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/Libuv-gRPC.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-simulator" "ios-arm64" "ios-arm64_x86_64-maccatalyst"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/FirebaseCoreExtension.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator" "ios-arm64"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/gRPC-C++.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-simulator" "ios-arm64" "ios-arm64_x86_64-maccatalyst"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/BoringSSL-GRPC.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/FirebaseSharedSwift.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-simulator" "ios-arm64_x86_64-maccatalyst" "ios-arm64"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/abseil.xcframework" "FirebaseFirestore/Base" "framework" "ios-arm64_x86_64-maccatalyst" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/FirebaseFirestore/FirebaseFirestore/leveldb-library.xcframework" "FirebaseFirestore/WithLeveldb" "framework" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator" "ios-arm64"

