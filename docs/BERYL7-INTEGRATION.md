# Beryl 7 integration: design and safety gates

Target: GL.iNet GL-MT3600BE (MediaTek MT7987A / MT7990).

## Profiles

### Performance (current source base)

Uses this repository's MediaTek/Linux patch stack (README currently documents 115 patches and the target Makefile selects Linux 6.18). This is the path for RSS, PPE/WED 3.1 and the associated Ethernet/mt76 fixes.

- Kernel and kernel modules are built together from this source tree.
- Do not install kernel modules from the official OpenWrt repository unless their package ABI and build identity have been independently established.
- The first CI workflow builds this profile only; it does not publish a flashable release.

### Compatible (separate work item)

Must be based on the exact official OpenWrt 25.12.6 source/ImageBuilder and SDK artifacts. The 4PDA recipe's central constraint is to preserve the official kernel binary while changing the FIT DTB and selected userspace settings.

- Verify the official kernel payload hash against the upstream 25.12.6 image.
- Build the mt76 packages against the exact official SDK and record package metadata/hashes.
- Treat any change to kernel code, kernel config, vermagic, symbol CRCs or module ABI as a compatibility break.
- Do not mix the Performance kernel patches into this profile.

## 4PDA changes to integrate and validate

1. mt76 TXWI fix described in 4PDA and linked to mt76 issue #1043. Check whether the fix is already present in this branch before applying it; avoid duplicate or conflicting patches.
2. Fan: inspect the GL-MT3600BE DTS thermal/pwm-fan nodes and the FAN789 fancontrol implementation. Only remove automatic fan operating points after confirming the userspace daemon has safe startup, sensor discovery and failure behavior.
3. WAN EEE: inspect the actual RTL8221B WAN interface mapping and apply EEE-off idempotently. Do not assume eth0 without verifying board configuration.
4. Wi-Fi country: set RU only as a first-boot default where country is unset/00; never overwrite an explicit user country on sysupgrade. Regulatory configuration must remain subject to local law and device calibration.
5. Open Wi-Fi: do not enable an unauthenticated AP in release images. Require credentials or keep radios disabled until initial setup is complete.
6. Include LuCI, fancontrol and ethtool only after package source, license, dependencies and service behavior are reviewed.

## Release safety gates

- Build succeeds from a clean checkout with pinned source revisions.
- Record source commit, toolchain, kernel config, package manifest and SHA256.
- Validate FIT structure and confirm no BL2, FIP or Factory partition is part of the sysupgrade payload.
- Confirm sysupgrade metadata and supported device identifiers.
- Test boot, Ethernet WAN/LAN at 1G and 2.5G, Wi-Fi 2.4/5 GHz, DFS, WED recovery, fan curve, thermal throttling and upgrade/rollback on physical hardware.
- Never describe a build as hardware-validated until those tests have actually been performed.

## Current status

The repository fork and integration branch exist. This document records the intended split and release gates. The first CI job is a reproducible build check for the existing Performance source base; the Compatible profile and 4PDA patch integration are not yet implemented.
