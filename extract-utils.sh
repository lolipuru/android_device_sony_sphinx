#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE_COMMON=sphinx
VENDOR=sony

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    vendor/bin/iddd)
        patchelf --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
    ;;
    system/lib/com.qualcomm.qti.ant@1.0.so|\
    system/lib/com.qualcomm.qti.dpm.api@1.0.so|\
    system/lib/vendor.qti.hardware.tui_comm@1.0.so|\
    system/lib64/com.qualcomm.qti.ant@1.0.so|\
    system/lib64/com.qualcomm.qti.dpm.api@1.0.so|\
    system/lib64/com.qualcomm.qti.imscmservice@1.0.so|\
    system/lib64/com.qualcomm.qti.imscmservice@2.0.so|\
    system/lib64/com.qualcomm.qti.imscmservice@2.1.so|\
    system/lib64/com.qualcomm.qti.uceservice@2.0.so|\
    system/lib64/com.quicinc.cne.server@1.0.so|\
    system/lib64/vendor.qti.hardware.tui_comm@1.0.so|\
    system/lib64/vendor.qti.ims.callinfo@1.0.so|\
    system/lib64/vendor.qti.ims.rcsconfig@1.0.so|\
    vendor/bin/cnd|\
    vendor/bin/dpmQmiMgr|\
    vendor/bin/hw/vendor.display.color@1.0-service|\
    vendor/bin/hw/vendor.semc.hardware.charger@1.0-service|\
    vendor/bin/hw/vendor.semc.hardware.secd@1.0-service|\
    vendor/bin/hw/vendor.somc.hardware.miscta@1.0-service|\
    vendor/bin/ims_rtp_daemon|\
    vendor/bin/vppservice|\
    vendor/lib/com.qualcomm.qti.dpm.api@1.0.so|\
    vendor/lib/com.quicinc.cne.api@1.0.so|\
    vendor/lib/com.quicinc.cne.api@1.1.so|\
    vendor/lib/com.quicinc.cne.server@2.0.so|\
    vendor/lib/com.quicinc.cne.server@2.1.so|\
    vendor/lib/com.quicinc.cne.server@2.2.so|\
    vendor/lib/com.quicinc.cne.server@2.3.so|\
    vendor/lib/vendor.qti.data.factory@1.0.so|\
    vendor/lib/vendor.qti.data.factory@1.1.so|\
    vendor/lib/vendor.qti.hardware.data.connection@1.0.so|\
    vendor/lib/vendor.qti.hardware.data.dynamicdds@1.0.so|\
    vendor/lib/vendor.qti.hardware.data.latency@1.0.so|\
    vendor/lib/vendor.qti.hardware.data.qmi@1.0.so|\
    vendor/lib/vendor.qti.hardware.fm@1.0.so|\
    vendor/lib/vendor.qti.hardware.qteeconnector@1.0.so|\
    vendor/lib/vendor.qti.hardware.soter@1.0.so|\
    vendor/lib/vendor.qti.hardware.tui_comm@1.0.so|\
    vendor/lib/vendor.qti.hardware.vpp@1.1.so|\
    vendor/lib/vendor.qti.hardware.vpp@1.2.so|\
    vendor/lib/vendor.qti.ims.rcsconfig@1.0.so|\
    vendor/lib/vendor.qti.latency@2.0.so|\
    vendor/lib/vendor.semc.hardware.light@1.0.so|\
    vendor/lib/vendor.somc.hardware.camera.cacao@1.0.so|\
    vendor/lib/vendor.somc.hardware.camera.cacao@2.0.so|\
    vendor/lib/vendor.somc.hardware.camera.cacao@3.0.so|\
    vendor/lib/vendor.somc.hardware.camera.cacao@3.1.so|\
    vendor/lib/vendor.somc.hardware.camera.cacao@3.2.so|\
    vendor/lib/vendor.somc.hardware.camera.device@1.0.so|\
    vendor/lib/vendor.somc.hardware.camera.provider@1.0.so|\
    vendor/bin/hw/vendor.qti.hardware.iop@2.0-service|\
    vendor/lib/vendor.somc.hardware.miscta@1.0.so|\
    vendor/lib/vendor.somc.hardware.security.secd@1.0.so|\
    vendor/lib/vendor.somc.hardware.swiqi@1.0.so|\
    vendor/lib64/com.qualcomm.qti.dpm.api@1.0.so|\
    vendor/lib64/com.qualcomm.qti.imscmservice@1.0.so|\
    vendor/lib64/com.qualcomm.qti.imscmservice@2.0.so|\
    vendor/lib64/com.qualcomm.qti.imscmservice@2.1.so|\
    vendor/lib64/com.qualcomm.qti.uceservice@2.0.so|\
    vendor/lib64/com.quicinc.cne.api@1.0.so|\
    vendor/lib64/com.quicinc.cne.api@1.1.so|\
    vendor/lib64/com.quicinc.cne.server@2.0.so|\
    vendor/lib64/com.quicinc.cne.server@2.1.so|\
    vendor/lib64/com.quicinc.cne.server@2.2.so|\
    vendor/lib64/com.quicinc.cne.server@2.3.so|\
    vendor/lib64/vendor.display.color@1.0.so|\
    vendor/lib64/vendor.display.color@1.1.so|\
    vendor/lib64/vendor.display.color@1.2.so|\
    vendor/lib64/vendor.display.postproc@1.0.so|\
    vendor/lib64/vendor.qti.data.factory@1.0.so|\
    vendor/lib64/vendor.qti.data.factory@1.1.so|\
    vendor/lib64/vendor.qti.gnss@1.0.so|\
    vendor/lib64/vendor.qti.gnss@1.1.so|\
    vendor/lib64/vendor.qti.gnss@1.2.so|\
    vendor/lib64/vendor.qti.gnss@2.0.so|\
    vendor/lib64/vendor.qti.gnss@2.1.so|\
    vendor/lib64/vendor.qti.hardware.cvp@1.0.so|\
    vendor/lib64/vendor.qti.hardware.data.connection@1.0.so|\
    vendor/lib64/vendor.qti.hardware.data.dynamicdds@1.0.so|\
    vendor/lib64/vendor.qti.hardware.data.latency@1.0.so|\
    vendor/lib64/vendor.qti.hardware.data.qmi@1.0.so|\
    vendor/lib64/vendor.qti.hardware.fm@1.0.so|\
    vendor/lib64/vendor.qti.hardware.qteeconnector@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.am@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.1.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.2.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.3.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.4.so|\
    vendor/lib64/vendor.qti.hardware.radio.ims@1.5.so|\
    vendor/lib64/vendor.qti.hardware.radio.lpa@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.qcrilhook@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.qtiradio@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.qtiradio@2.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.qtiradio@2.1.so|\
    vendor/lib64/vendor.qti.hardware.radio.uim_remote_client@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.uim_remote_server@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.uim@1.0.so|\
    vendor/lib64/vendor.qti.hardware.radio.uim@1.1.so|\
    vendor/lib64/vendor.qti.hardware.sensorscalibrate@1.0.so|\
    vendor/lib64/vendor.qti.hardware.soter@1.0.so|\
    vendor/lib64/vendor.qti.hardware.tui_comm@1.0.so|\
    vendor/lib64/vendor.qti.hardware.vpp@1.1.so|\
    vendor/lib64/vendor.qti.hardware.vpp@1.2.so|\
    vendor/lib64/vendor.qti.ims.callinfo@1.0.so|\
    vendor/lib64/vendor.qti.ims.rcsconfig@1.0.so|\
    vendor/lib64/vendor.qti.imsrtpservice@1.0.so|\
    vendor/lib64/vendor.qti.latency@2.0.so|\
    vendor/lib64/vendor.semc.hardware.display@1.0.so|\
    vendor/lib64/vendor.semc.hardware.light@1.0.so|\
    vendor/lib64/vendor.semc.hardware.thermal@1.0.so|\
    vendor/lib64/vendor.somc.hardware.miscta@1.0.so|\
    vendor/lib64/vendor.somc.hardware.modemswitcher@1.0.so|\
    vendor/lib64/vendor.somc.hardware.radio@1.0.so|\
    vendor/lib64/vendor.somc.hardware.security.secd@1.0.so|\
    vendor/lib64/vendor.somc.hardware.swiqi@1.0.so|\
    vendor/lib/com.qualcomm.qti.ant@1.0.so|\
    vendor/lib64/com.qualcomm.qti.ant@1.0.so)
        patchelf --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
    ;;
    vendor/bin/loc_launcher|\
    vendor/lib64/libgps.utils.so)
        patchelf --add-needed "libprocessgroup.so" "${2}"
    ;;
    system/lib/libdpmframework.so|\
    system/lib64/libdpmframework.so)
        "${PATCHELF}" --replace-needed "libhidltransport.so" "libcutils-v29.so" "${2}"
    ;;
    esac
}

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"