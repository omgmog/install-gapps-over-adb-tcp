install-gapps-over-adb-tcp
==========================

A shell script to automatically install the Google Apps via adb over TCP on the Mele A2000.

## Requires:
- android device is running `adb` in tcp mode
- `adb` binary is available globally (in `$PATH`)
- url for gapps zip, default is `http://cmw.22aaf3.com/gapps/gapps-ics-20120317-signed.zip`

## Usage:
`$ ./install_gapps.sh [device ip] [url of gapps zip]`