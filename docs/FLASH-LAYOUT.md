# Beryl 7 flash layout — preliminary audit

## Status and evidence level

This document records what the repository's **Linux device tree** declares for
GL-MT3600BE. It is an OS-side partition description, **not yet proof of the
factory bootloader's own view of flash, NMBM mapping, erase geometry, or the
recovery image format**.

Primary source:
- `target/linux/mediatek/dts/mt7987a-glinet-gl-mt3600be.dts`
  (branch: `beryl7-u-boot`)

Do not use this table as instructions for raw NAND access or flashing.

## Storage controller and bad-block management

The DTS describes an SPI-NAND device on `&spi2`, with:
- `compatible = "spi-nand"`
- `mediatek,nmbm`
- `mediatek,bmt-max-ratio = <1>`
- `mediatek,bmt-max-reserved-blocks = <256>`

This establishes that the Linux device tree expects MediaTek NMBM. It does
not establish whether the factory U-Boot uses the same NMBM configuration or
whether its logical offsets map identically.

## Linux fixed-partition declarations

All values below are copied from the DTS `fixed-partitions` node. Offsets and
sizes are hexadecimal.

| Label | Offset | Size | DTS flags / notes |
| --- | ---: | ---: | --- |
| BL2 | 0x000000 | 0x100000 | read-only |
| u-boot-env | 0x100000 | 0x080000 | writable in DTS |
| Factory | 0x180000 | 0x400000 | read-only; contains NVMEM cells |
| FIP | 0x580000 | 0x200000 | read-only |
| log | 0x780000 | 0x040000 | read-only |
| CFG | 0x7c0000 | 0x040000 | read-only |
| ubi | 0x800000 | 0x1d800000 | compatible = "linux,ubi" |

The Factory NVMEM layout declared by the DTS includes:
- EEPROM cell at offset 0x0000, size 0x1e00.
- MAC base cell at offset 0x4000, length 6 bytes, with one cell argument.
- MAC base cell at offset 0x4006, length 6 bytes, with one cell argument.

These cells are device-specific calibration/identity data. Preserve them.
Never erase, rewrite, clone from another unit, or publish their contents.

## UART declaration

The same DTS declares:
- `chosen.stdout-path = "serial0:115200n8"`
- kernel bootargs include `console=ttyS0,115200n1`
- `serial0` aliases `&uart0`

The n8/n1 framing difference is a source-level discrepancy worth checking.
Neither line alone proves the factory U-Boot console configuration, connector
pinout, voltage, or safe electrical connection. Do not connect UART hardware
until the physical pinout and electrical levels are independently verified.

## Still unknown — do not infer

- Exact NAND part number, page/block geometry and total usable capacity.
- Whether the DTS partition offsets are directly comparable to U-Boot/NMBM
  logical offsets on the factory firmware.
- Factory U-Boot version, source commit, defconfig and board DTS.
- BL2/FIP binary versions and signing/packaging requirements.
- U-Boot environment format, redundancy and exact storage location.
- U-Boot recovery image format, accepted headers and validation rules.
- Recovery button timing, network address, protocol and web assets.
- UART header pinout, voltage and factory baud/framing.

## Next verification steps

1. Extract the exact GL-MT3600BE factory firmware and record its version and
   checksums without writing anything to the router.
2. Locate authoritative GL.iNet recovery instructions and the exact Beryl 7
   recovery package; record accepted file types and hashes.
3. On a running device, collect read-only outputs for `/proc/mtd`,
   `/proc/cmdline`, `dmesg` NMBM/MTD initialization and
   `/sys/class/mtd/mtd*/(name,size,erasesize)`.
4. Compare those observations with this DTS and with the factory image
   metadata. Keep discrepancies explicit.
5. Obtain U-Boot environment and boot logs only through a verified,
   non-destructive method. Do not issue saveenv, erase, write or update
   commands during inventory.

## Safety

No flashing, partition writes, environment changes, BL2/FIP updates or
bootloader replacement are part of this audit.
