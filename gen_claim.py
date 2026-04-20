#!/usr/bin/env python3
"""Generate Xcode project for Claim app."""

import os

PROJECT_DIR = "/data/.openclaw/workspace/Claim"

IDS = {
    "BF1": "F10000000000000000000001", "BF2": "F10000000000000000000002",
    "BF3": "F10000000000000000000003", "BF4": "F10000000000000000000004",
    "BF5": "F10000000000000000000005", "BF6": "F10000000000000000000006",
    "BF7": "F10000000000000000000007", "BF8": "F10000000000000000000008",
    "BF9": "F10000000000000000000009", "BF10": "F10000000000000000000010",
    "FF1": "F20000000000000000000001", "FF2": "F20000000000000000000002",
    "FF3": "F20000000000000000000003", "FF4": "F20000000000000000000004",
    "FF5": "F20000000000000000000005", "FF6": "F20000000000000000000006",
    "FF7": "F20000000000000000000007", "FF8": "F20000000000000000000008",
    "FF9": "F20000000000000000000009", "FF10": "F20000000000000000000010",
    "FF11": "F20000000000000000000011",
    "GM": "F30000000000000000000001", "GA": "F30000000000000000000002",
    "GR": "F30000000000000000000003", "GP": "F30000000000000000000004",
    "TGT": "F30000000000000000000005", "PROJ": "F30000000000000000000006",
    "FW": "F30000000000000000000007", "RS": "F30000000000000000000008",
    "SS": "F30000000000000000000009",
    "DC": "F40000000000000000000001", "RC": "F40000000000000000000002",
    "TD": "F40000000000000000000003", "TR": "F40000000000000000000004",
    "PC": "F40000000000000000000005", "TC": "F40000000000000000000006",
}

def u(k): return IDS[k]

SOURCES = [
    ("FF1", "BF1", "Sources/ClaimApp.swift"),
    ("FF2", "BF2", "Sources/ContentView.swift"),
    ("FF3", "BF3", "Sources/ClaimItem.swift"),
    ("FF4", "BF4", "Sources/ClaimRow.swift"),
    ("FF5", "BF5", "Sources/AddClaimView.swift"),
    ("FF6", "BF6", "Sources/ClaimDetailView.swift"),
    ("FF7", "BF7", "Sources/ReceiptScanner.swift"),
    ("FF8", "BF8", "Sources/NotificationManager.swift"),
]
RESOURCES = [
    ("FF9", "BF9", "Resources/Info.plist"),
    ("FF10", "BF10", "Resources/Assets.xcassets"),
]

DS = "ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ANALYZER_NONLOCALIZED = YES; CLANG_CXX_LANGUAGE_STANDARD = gnu++20; CLANG_ENABLE_MODULES = YES; CLANG_ENABLE_OBJC_ARC = YES; CODE_SIGN_STYLE = Automatic; COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = dwarf; ENABLE_TESTABILITY = YES; GCC_C_LANGUAGE_STANDARD = gnu17; GCC_NO_COMMON_BLOCKS = YES; IPHONEOS_DEPLOYMENT_TARGET = 17.0; MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE; ONLY_ACTIVE_ARCH = YES; SDKROOT = iphoneos; SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG; SWIFT_OPTIMIZATION_LEVEL = -Onone;"
RS = "ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ANALYZER_NONLOCALIZED = YES; CLANG_CXX_LANGUAGE_STANDARD = gnu++20; CLANG_ENABLE_MODULES = YES; CLANG_ENABLE_OBJC_ARC = YES; CODE_SIGN_STYLE = Automatic; COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = dwarf-with-dsym; ENABLE_NS_ASSERTIONS = NO; GCC_C_LANGUAGE_STANDARD = gnu17; GCC_NO_COMMON_BLOCKS = YES; IPHONEOS_DEPLOYMENT_TARGET = 17.0; MTL_ENABLE_DEBUG_INFO = NO; SDKROOT = iphoneos; SWIFT_COMPILATION_MODE = wholemodule; SWIFT_OPTIMIZATION_LEVEL = -O; VALIDATE_PRODUCT = YES;"
TS = "ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor; GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = Resources/Info.plist; MARKETING_VERSION = 1.0.0; CURRENT_PROJECT_VERSION = 1; PRODUCT_BUNDLE_IDENTIFIER = com.skilachi.claim; PRODUCT_NAME = $(TARGET_NAME); SKIP_INSTALL = YES; SWIFT_EMIT_LOC_STRINGS = YES; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = 1; CODE_SIGN_IDENTITY = -; CODE_SIGNING_REQUIRED = NO; CODE_SIGNING_ALLOWED = NO;"

lines = []
def add(s): lines.append(s)

add("// !$*UTF8*$!")
add("{")
add("\tarchiveVersion = 1;")
add("\tclasses = {")
add("\t};")
add("\tobjectVersion = 56;")
add("\tobjects = {")
add("")
add("/* Begin PBXBuildFile section */")
for ff, bf, p in SOURCES:
    name = p.split("/")[-1]
    add(f"\t\t{u(bf)} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {u(ff)}; }};")
for ff, bf, p in RESOURCES:
    name = p.split("/")[-1]
    add(f"\t\t{u(bf)} /* {name} */ = {{isa = PBXBuildFile; fileRef = {u(ff)}; }};")
add("/* End PBXBuildFile section */")
add("")
add("/* Begin PBXFileReference section */")
for ff, _, p in SOURCES:
    name = p.split("/")[-1]
    add(f"\t\t{u(ff)} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};")
for ff, _, p in RESOURCES:
    name = p.split("/")[-1]
    lkft = "text.plist" if p.endswith(".plist") else "folder"
    add(f"\t\t{u(ff)} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {lkft}; path = {name}; sourceTree = \"<group>\"; }};")
add(f"\t\t{u('FF11')} /* Claim.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Claim.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
add("/* End PBXFileReference section */")
add("")
add("/* Begin PBXFrameworksBuildPhase section */")
add(f"\t\t{u('FW')} = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};")
add("/* End PBXFrameworksBuildPhase section */")
add("")
add("/* Begin PBXGroup section */")
src_refs = " ".join(u(ff) for ff, _, _ in SOURCES)
res_refs = " ".join(u(ff) for ff, _, _ in RESOURCES)
add(f"\t\t{u('GM')} = {{isa = PBXGroup; children = ({u('GA')}, {u('GR')}, {u('GP')}); sourceTree = \"<group>\"; }};")
add(f"\t\t{u('GA')} = {{isa = PBXGroup; children = ({src_refs}); sourceTree = \"<group>\"; }};")
add(f"\t\t{u('GR')} = {{isa = PBXGroup; children = ({res_refs}); sourceTree = \"<group>\"; }};")
add(f"\t\t{u('GP')} = {{isa = PBXGroup; children = ({u('FF11')}); name = Products; sourceTree = \"<group>\"; }};")
add("/* End PBXGroup section */")
add("")
add("/* Begin PBXNativeTarget section */")
add(f"\t\t{u('TGT')} = {{isa = PBXNativeTarget; buildConfigurationList = {u('TC')}; buildPhases = ({u('SS')}, {u('FW')}, {u('RS')}); buildRules = (); dependencies = (); name = Claim; productName = Claim; productReference = {u('FF11')}; productType = \"com.apple.product-type.application\"; }};")
add("/* End PBXNativeTarget section */")
add("")
add("/* Begin PBXProject section */")
add(f"\t\t{u('PROJ')} = {{isa = PBXProject; buildConfigurationList = {u('PC')}; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base); mainGroup = {u('GM')}; productRefGroup = {u('GP')}; projectDirPath = \"\"; projectRoot = \"\"; targets = ({u('TGT')}); }};")
add("/* End PBXProject section */")
add("")

src_files_list = " ".join(u(bf) for _, bf, _ in SOURCES)
res_files_list = " ".join(u(bf) for _, bf, _ in RESOURCES)

add("/* Begin PBXResourcesBuildPhase section */")
add(f"\t\t{u('RS')} = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({res_files_list}); runOnlyForDeploymentPostprocessing = 0; }};")
add("/* End PBXResourcesBuildPhase section */")
add("")
add("/* Begin PBXSourcesBuildPhase section */")
add(f"\t\t{u('SS')} = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({src_files_list}); runOnlyForDeploymentPostprocessing = 0; }};")
add("/* End PBXSourcesBuildPhase section */")
add("")
add("/* Begin XCBuildConfiguration section */")
add(f"\t\t{u('DC')} = {{isa = XCBuildConfiguration; buildSettings = {{{DS}}}; name = Debug; }};")
add(f"\t\t{u('RC')} = {{isa = XCBuildConfiguration; buildSettings = {{{RS}}}; name = Release; }};")
add(f"\t\t{u('TD')} = {{isa = XCBuildConfiguration; buildSettings = {{{TS}}}; name = Debug; }};")
add(f"\t\t{u('TR')} = {{isa = XCBuildConfiguration; buildSettings = {{{TS}}}; name = Release; }};")
add("/* End XCBuildConfiguration section */")
add("")
add("/* Begin XCConfigurationList section */")
add(f"\t\t{u('PC')} = {{isa = XCConfigurationList; buildConfigurations = ({u('DC')}, {u('RC')}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
add(f"\t\t{u('TC')} = {{isa = XCConfigurationList; buildConfigurations = ({u('TD')}, {u('TR')}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
add("/* End XCConfigurationList section */")
add("")
add("\t};")
add("\trootObject = " + u('PROJ') + ";")
add("}")

os.makedirs(os.path.join(PROJECT_DIR, "Claim.xcodeproj"), exist_ok=True)
out_path = os.path.join(PROJECT_DIR, "Claim.xcodeproj", "project.pbxproj")
with open(out_path, "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Written: {out_path}")
print(f"Lines: {len(lines)}")
