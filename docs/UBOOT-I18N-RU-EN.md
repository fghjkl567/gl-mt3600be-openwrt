# U-Boot language support: Russian and English

## Goal

Provide Russian and English wording for the parts of the Beryl 7 recovery experience that we can safely modify, without making recovery depend on a particular terminal or browser locale.

## Important distinction

There are two separate interfaces:

1. **U-Boot serial console / boot menu.** This is firmware-side text emitted by U-Boot. Upstream U-Boot is not generally a gettext-style localized application; language selection and translated message catalogs would be custom work.
2. **U-Boot recovery Web UI.** This is a browser page served during recovery. It can be localized independently with HTML/JavaScript/CSS resources, if the exact Beryl 7 page assets and build path are available to us.

Do not assume the recovery page is the same UI as the normal GL.iNet administration panel. The latter has its own language selector, but that does not prove the bootloader recovery page shares its translation system.

## Proposed implementation order

1. Identify which strings are actually produced by U-Boot and which belong to the recovery web page.
2. Preserve English as the fallback/default language.
3. Add a small translation dictionary for Russian and English for the recovery page, with a visible language selector only if the page architecture supports it.
4. For serial output, first test whether the exact U-Boot build, UART path and terminal reliably pass/display UTF-8 Cyrillic. If not, keep serial diagnostics in English and provide a Russian recovery guide rather than emitting garbled text.
5. Keep command names, environment variable names, partition labels, protocol identifiers, error codes and machine-parsed output unchanged.
6. Add checks for missing translation keys and ensure the English fallback is always available.

## Safety and compatibility

- No changes to boot flow, flash layout, recovery image validation or flashing logic are required for translation.
- No bootloader write or firmware flash is part of localization development.
- Do not add Cyrillic strings to the bootloader binary until UTF-8 handling and available font/terminal behavior have been verified on the actual device.
- If the recovery page assets are not present in the public source tree, document that limitation; do not claim the page has been localized by changing the normal OpenWrt/GL.iNet web interface.

## Initial status

Planning only. The exact Beryl 7 U-Boot source, recovery page implementation and build integration still need to be identified.
