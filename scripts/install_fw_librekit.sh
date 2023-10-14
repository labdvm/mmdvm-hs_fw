#!/bin/bash

#   Copyright (C) 2017,2018 by Andy Uribe CA6JAU

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Configure latest version
FW_VERSION="v1.6.1"

# Change USB-serial port name ONLY in macOS
MAC_DEV_USB_SER="/dev/cu.usbmodem14401"

# Firmware filename
FW_FILENAME="zumspot_libre_fw.bin"

# Download latest firmware
echo "Downloading firmware..."
curl -s -A "CA6JAU/G4KLX/W0CHP Modem FW Update Script" -OL https://wpsd-swd.w0chp.net/WPSD-SWD/MMDVM_HS-Firmware_Latest-Compiled/raw/tag/$FW_VERSION/$FW_FILENAME	

# Download STM32F10X_Lib (only for binary tools)
if [ ! -d "./STM32F10X_Lib/utils" ]; then
  env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="CA6JAU/G4KLX/W0CHP Modem FW Update Script" git clone https://wpsd-swd.w0chp.net/WPSD-SWD/STM32F10X_Lib.git &> /dev/null
fi

# Configure vars depending on OS
if [ $(uname -s) == "Linux" ]; then
	DEV_USB_SER="/dev/ttyACM0"
	if [ $(uname -m) == "x86_64" ]; then
		echo "Linux 64-bit detected"
		DFU_RST="./STM32F10X_Lib/utils/linux64/upload-reset"
		DFU_UTIL="./STM32F10X_Lib/utils/linux64/dfu-util"
		ST_FLASH="./STM32F10X_Lib/utils/linux64/st-flash"
		STM32FLASH="./STM32F10X_Lib/utils/linux64/stm32flash"
	elif [ $(uname -m) == "aarch64" ] ; then
		echo "Linux 64-bit ARM (aarch64) detected"
		DFU_RST="./STM32F10X_Lib/utils/rpi32/upload-reset"
		DFU_UTIL="./STM32F10X_Lib/utils/rpi32/dfu-util"
		ST_FLASH="./STM32F10X_Lib/utils/rpi32/st-flash"
		STM32FLASH="./STM32F10X_Lib/utils/rpi32/stm32flash"
	elif [ $(uname -m) == "armv7l" ]; then
		echo "Linux ARM (armv7l) detected"
		DFU_RST="./STM32F10X_Lib/utils/rpi32/upload-reset"
		DFU_UTIL="./STM32F10X_Lib/utils/rpi32/dfu-util"
		ST_FLASH="./STM32F10X_Lib/utils/rpi32/st-flash"
		STM32FLASH="./STM32F10X_Lib/utils/rpi32/stm32flash"
	elif [ $(uname -m) == "armv6l" ]; then
		echo "Linux ARM (armv6l) detected"
		DFU_RST="./STM32F10X_Lib/utils/rpi32/upload-reset"
		DFU_UTIL="./STM32F10X_Lib/utils/rpi32/dfu-util"
		ST_FLASH="./STM32F10X_Lib/utils/rpi32/st-flash"
		STM32FLASH="./STM32F10X_Lib/utils/rpi32/stm32flash"
	else
		echo "Linux 32-bit detected"
		DFU_RST="./STM32F10X_Lib/utils/linux/upload-reset"
		DFU_UTIL="./STM32F10X_Lib/utils/linux/dfu-util"
		ST_FLASH="./STM32F10X_Lib/utils/linux/st-flash"
		STM32FLASH="./STM32F10X_Lib/utils/linux/stm32flash"
	fi
fi

if [ $(uname -s) == "Darwin" ]; then
	echo "macOS detected"
	DEV_USB_SER=$MAC_DEV_USB_SER
	DFU_RST="./STM32F10X_Lib/utils/macosx/upload-reset"
	DFU_UTIL="./STM32F10X_Lib/utils/macosx/dfu-util"
	ST_FLASH="./STM32F10X_Lib/utils/macosx/st-flash"
	STM32FLASH="./STM32F10X_Lib/utils/macosx/stm32flash"
fi

# Stop MMDVMHost process to free serial port
sudo killall MMDVMHost >/dev/null 2>&1

# Reset ZUMspot to enter bootloader mode
eval sudo $DFU_RST $DEV_USB_SER 750

# Upload the firmware
eval sudo $DFU_UTIL -D $FW_FILENAME -d 1eaf:0003 -a 2 -R -R

echo
echo "Please RESET your ZUMspot Libre Kit !"
echo
