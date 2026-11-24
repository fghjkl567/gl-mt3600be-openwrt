# Beryl 7 U-Boot and Recovery Research

This branch is for auditing and documenting the **existing GL.iNet Beryl 7 (GL-MT3600BE) boot chain and recovery path**.

It is not an attempt to replace the factory bootloader or introduce a new U-Boot build.

## Scope

1. Identify the exact factory U-Boot, BL2, ATF/FIP and board configuration used by the device.
2. Document the vendor-supported U-Boot web recovery procedure and the exact image format it accepts.
3. Inventory flash layout, NAND/NMBM configuration, environment variables and boot targets from verifiable sources.
4. Document non-destructive backup and recovery preparation.
5. Add validation scripts only where inputs and expected formats are known and testable.
6. Keep any alternative U-Boot build experiments isolated from the stock recovery path.

## Safety rules

- Do not write, replace, erase or upgrade BL2, FIP, U-Boot, bootloader environment, factory/calibration partitions or device-specific data as part of routine firmware work.
- Do not assume a sysupgrade image is accepted by U-Boot recovery.
- Do not publish flashing instructions until the exact Beryl 7 procedure and image format are verified against authoritative GL.iNet material or a reproducible device-side observation.
- Never infer partition offsets, sizes, erase geometry, UART pinout, baud rate or recovery button timing from another GL.iNet model.
- A successful compilation is not proof that an image is safe to flash.

## Planned layout

- `docs/BOOT-CHAIN.md` — verified boot-chain inventory and source references.
- `docs/RECOVERY.md` — vendor recovery procedure, prerequisites and limitations.
- `docs/FLASH-LAYOUT.md` — verified partition map; unknown values remain explicitly marked unknown.
- `docs/BACKUP.md` — read-only inventory and backup guidance.
- `scripts/` — validation/inventory helpers; no destructive flashing scripts.

## Current status

Branch scaffold only. No bootloader binaries, BL2/FIP images, partition writes or flashing scripts are included. Hardware-specific details remain unverified until checked against the exact GL-MT3600BE firmware and documentation.
