# Setup BUILD files for local dependencies
Write-Host "Setting up BUILD files for local dependencies..." -ForegroundColor Green

$dependenciesDir = "dependencies"
$thirdPartyDir = "third_party"

# Copy BUILD files to local dependencies
$buildFiles = @(
    @{Source="$thirdPartyDir\world.BUILD"; Target="$dependenciesDir\world\BUILD.bazel"},
    @{Source="$thirdPartyDir\libgvps.BUILD"; Target="$dependenciesDir\libgvps\BUILD.bazel"},
    @{Source="$thirdPartyDir\libnpy.BUILD"; Target="$dependenciesDir\libnpy\BUILD.bazel"},
    @{Source="$thirdPartyDir\libpyin.BUILD"; Target="$dependenciesDir\libpyin\BUILD.bazel"},
    @{Source="$thirdPartyDir\spline.BUILD"; Target="$dependenciesDir\spline\BUILD.bazel"},
    @{Source="$thirdPartyDir\miniaudio.BUILD"; Target="$dependenciesDir\miniaudio\BUILD.bazel"}
)

foreach ($buildFile in $buildFiles) {
    if (Test-Path $buildFile.Source) {
        Copy-Item $buildFile.Source $buildFile.Target -Force
        Write-Host "Copied BUILD file: $($buildFile.Source) -> $($buildFile.Target)" -ForegroundColor Green
    } else {
        Write-Host "Source BUILD file not found: $($buildFile.Source)" -ForegroundColor Red
    }
}

# Create BUILD files for abseil-cpp, googletest, and xxhash
# These are standard libraries that should have their own BUILD files

# Create abseil-cpp BUILD file
$abseilBuild = @"
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "absl",
    srcs = glob([
        "absl/**/*.cc",
        "absl/**/*.h",
    ]),
    hdrs = glob([
        "absl/**/*.h",
    ]),
    includes = ["."],
)
"@

Set-Content "$dependenciesDir\abseil-cpp\BUILD.bazel" $abseilBuild
Write-Host "Created BUILD file for abseil-cpp" -ForegroundColor Green

# Create googletest BUILD file
$gtestBuild = @"
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "gtest",
    srcs = glob([
        "googletest/src/*.cc",
        "googlemock/src/*.cc",
    ]),
    hdrs = glob([
        "googletest/include/gtest/*.h",
        "googlemock/include/gmock/*.h",
    ]),
    includes = [
        "googletest/include",
        "googlemock/include",
    ],
)

cc_library(
    name = "gtest_main",
    srcs = ["googletest/src/gtest_main.cc"],
    deps = [":gtest"],
)
"@

Set-Content "$dependenciesDir\googletest\BUILD.bazel" $gtestBuild
Write-Host "Created BUILD file for googletest" -ForegroundColor Green

# Create xxhash BUILD file
$xxhashBuild = @"
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "xxhash",
    srcs = [
        "xxhash.c",
    ],
    hdrs = [
        "xxhash.h",
    ],
    includes = ["."],
)
"@

Set-Content "$dependenciesDir\xxhash\BUILD.bazel" $xxhashBuild
Write-Host "Created BUILD file for xxhash" -ForegroundColor Green

Write-Host "`nBUILD files setup completed!" -ForegroundColor Green 