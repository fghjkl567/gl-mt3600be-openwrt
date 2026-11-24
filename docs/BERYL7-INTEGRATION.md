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

## 4PDA changes: implementation status

- **MT7990 TXWI:** added `package/kernel/mt76/patches/111-mt7990-always-build-host-txwi.patch`. It forces host TXWI generation only when `is_mt7990()` is true, leaving other MT799x variants unchanged. Source is pinned by `package/kernel/mt76/Makefile` to mt76 commit `0936617dc529ff9da0385221d3fa6de732231177`. This still requires a clean patch-application/build test and on-device IPv4 NAT throughput test.
- **WAN EEE:** added `ethtool` to the GL-MT3600BE image package list and an iface hotplug hook that disables EEE on WAN `eth0` after `ifup`/`ifupdate`. The board mapping in `02_network` confirms WAN=`eth0`, LAN=`eth1`. Runtime support must still be verified on the actual RTL8221B PHY.
- **Wi-Fi country:** added a board-specific uci-defaults script that sets RU only when a radio's country is empty or `00`. An explicit country is not overwritten. Set the country required by the jurisdiction where the router is operated; RU is the recipe's default, not a regulatory exemption.
- **Fan:** not yet integrated. The SoC DTSI defines `pwm-fan` plus three fan cooling maps (`cpu-active-high`, `cpu-active-low`, `cpu-passive`) and separate CPU cooling at 117 °C, hot at 120 °C and critical at 125 °C. FAN789's current `luci-app-h5000m-fancontrol` release is documented for Hiveton H5000M, not GL-MT3600BE; its fallback thermal thresholds are H5000M-specific. Do not remove Beryl 7 fan cooling maps or ship the app until its sensor discovery and 117/125 °C safety floors are adapted and tested for this board.
- **Open Wi-Fi:** deliberately not enabled. Release images must not ship an unauthenticated default AP.
- **LuCI/fancontrol:** add only after the Beryl-specific adaptation and package integration are complete. `ethtool` is already included for the WAN workaround.

## Release safety gates

- Build succeeds from a clean checkout with pinned source revisions.
- Record source commit, toolchain, kernel config, package manifest and SHA256.
- Validate FIT structure and confirm no BL2, FIP or Factory partition is part of the sysupgrade payload.
- Confirm sysupgrade metadata and supported device identifiers.
- Test boot, Ethernet WAN/LAN at 1G and 2.5G, Wi-Fi 2.4/5 GHz, DFS, WED recovery, fan curve, thermal throttling and upgrade/rollback on physical hardware.
- Never describe a build as hardware-validated until those tests have actually been performed.

## Current status

The fork and integration branch exist. CI infrastructure is present. Initial integration commits add the MT7990-scoped TXWI patch, WAN EEE workaround and first-boot country default. These changes have not yet passed a clean build or hardware validation. The fan-control app and Compatible profile remain pending.
