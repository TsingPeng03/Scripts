#!/bin/bash

pwd=/root/Desktop
OUT_DIR=${pwd}/out
KERNEL_SOURCE_DIR=${pwd}/msm-4.9/
CLANG=${pwd}/tools/ProtonClang
AK3=${pwd}/tools/AnyKernel3
Dtc=${pwd}/tools/dtc1.6.0
Ver="V2.4"
Number="B1350"
Core_Nmuber="$(nproc --all)"

print (){
case ${2} in
	"red")
	echo -e "\033[1;31m$1\033[0m";;

	"blue")
	echo -e "\033[1;34m$1\033[0m";;

	"green")
	echo -e "\033[1;32m$1\033[0m";;

	*)
	echo $1
	;;
	esac
}

mkzip () {
	cd ${AK3}
	cp -r ${OUT_DIR}/arch/arm64/boot/Image.gz-dtb Image.gz-dtb
	zipfile="Tsing-${i}-${Ver}-${Number}.zip"
	zip -r9 ${zipfile} -x@exclude.lst *
	cp ${zipfile} ${pwd}
}

for i in {dipper,equuleus}
	do
		print "Start compiling for ${i}\n" blue

		startTime=`date +%s`

		cd ${KERNEL_SOURCE_DIR}
		make -j${Core_Nmuber} mrproper
		make -j${Core_Nmuber} ARCH=arm64 O=${OUT_DIR} mrproper
		make ARCH=arm64 O=${OUT_DIR} Tsing-"$i"_defconfig

		make -j${Core_Nmuber} O=${OUT_DIR} \
			ARCH=arm64 SUBARCH=arm64 \
			DTC_EXT=${Dtc}/dtc \
			CC=${CLANG}/bin/clang \
			CROSS_COMPILE=${CLANG}/bin/aarch64-linux-gnu- \
			CROSS_COMPILE_ARM32=${CLANG}/bin/arm-linux-gnueabi- \
			AR=${CLANG}/bin/llvm-ar  \
			NM=${CLANG}/bin/llvm-nm \
			OBJCOPY=${CLANG}/bin/llvm-objcopy \
			OBJDUMP=${CLANG}/bin/llvm-objdump \
			STRIP=${CLANG}/bin/llvm-strip
 
		endTime=`date +%s`

		if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz-dtb" ]; then
			print "\nPackaging Flashable Zip for ${i}\n" green
			mkzip
		fi
		sumTime=$[ $endTime - $startTime ]
		print "\n${i} compilation is complete, Total: $sumTime seconds\n" green
	done

if [ "$i" == "equuleus" ]; then
	print "Compilation is complete, exiting...\n" green
else 
	print "Compile failed\n" red
fi
