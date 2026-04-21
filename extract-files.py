#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.file import File
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/sony/sphinx',
    'hardware/qcom-caf/sm8150',
    'hardware/qcom-caf/wlan',
    'hardware/sony',
    'vendor/qcom/opensource/commonsys/display',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/qcom/opensource/dataservices',
    'vendor/qcom/opensource/display',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'com.qualcomm.qti.ant',
        'vendor.somc.hardware.miscta@1.0',
        'com.qualcomm.qti.dpm.api@1.0',
        'vendor.qti.hardware.tui_comm@1.0',
        'com.qualcomm.qti.imscmservice@1.0',
        'com.qualcomm.qti.imscmservice@2.0',
        'com.qualcomm.qti.imscmservice@2.1',
        'com.qualcomm.qti.imscmservice@2.2',
        'com.qualcomm.qti.uceservice@2.0',
        'com.qualcomm.qti.uceservice@2.1',
        'com.qualcomm.qti.uceservice@2.2',
        'vendor.qti.hardware.data.cne.internal.api@1.0',
        'vendor.qti.hardware.data.cne.internal.constants@1.0',
        'vendor.qti.hardware.data.cne.internal.server@1.0',
        'vendor.qti.hardware.data.connection@1.0',
        'vendor.qti.hardware.data.connection@1.1',
        'vendor.qti.hardware.data.dynamicdds@1.0',
        'vendor.qti.hardware.data.iwlan@1.0',
        'vendor.qti.hardware.data.qmi@1.0',
        'vendor.qti.hardware.qseecom@1.0',
        'vendor.qti.ims.callinfo@1.0',
        'vendor.qti.ims.rcsconfig@1.0',
        'vendor.qti.ims.rcsconfig@1.1',
        'vendor.qti.imsrtpservice@3.0',
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    (
        'system/lib/com.qualcomm.qti.ant@1.0.so',
        'system/lib/com.qualcomm.qti.dpm.api@1.0.so',
        'system/lib/vendor.qti.hardware.tui_comm@1.0.so',
        'system/lib64/com.qualcomm.qti.ant@1.0.so',
        'system/lib64/com.qualcomm.qti.dpm.api@1.0.so',
        'system/lib64/vendor.qti.hardware.tui_comm@1.0.so',
        'vendor/bin/dpmQmiMgr',
        'vendor/bin/hw/vendor.display.color@1.0-service',
        'vendor/bin/hw/vendor.semc.hardware.charger@1.0-service',
        'vendor/bin/hw/vendor.semc.hardware.secd@1.0-service',
        'vendor/bin/hw/vendor.somc.hardware.miscta@1.0-service',
        'vendor/bin/vppservice',
        'vendor/lib/com.qualcomm.qti.dpm.api@1.0.so',
        'vendor/lib/vendor.qti.hardware.fm@1.0.so',
        'vendor/lib/vendor.qti.hardware.soter@1.0.so',
        'vendor/lib/vendor.qti.hardware.tui_comm@1.0.so',
        'vendor/lib/vendor.qti.hardware.vpp@1.1.so',
        'vendor/lib/vendor.qti.hardware.vpp@1.2.so',
        'vendor/lib/vendor.semc.hardware.light@1.0.so',
        'vendor/lib/vendor.somc.hardware.camera.cacao@1.0.so',
        'vendor/lib/vendor.somc.hardware.camera.cacao@2.0.so',
        'vendor/lib/vendor.somc.hardware.camera.cacao@3.0.so',
        'vendor/lib/vendor.somc.hardware.camera.cacao@3.1.so',
        'vendor/lib/vendor.somc.hardware.camera.cacao@3.2.so',
        'vendor/lib/vendor.somc.hardware.camera.device@1.0.so',
        'vendor/lib/vendor.somc.hardware.miscta@1.0.so',
        'vendor/lib/vendor.somc.hardware.security.secd@1.0.so',
        'vendor/lib/vendor.somc.hardware.swiqi@1.0.so',
        'vendor/lib64/com.qualcomm.qti.dpm.api@1.0.so',
        'vendor/lib64/vendor.display.color@1.0.so',
        'vendor/lib64/vendor.display.color@1.1.so',
        'vendor/lib64/vendor.display.color@1.2.so',
        'vendor/lib64/vendor.display.postproc@1.0.so',
        'vendor/lib64/vendor.qti.gnss@1.0.so',
        'vendor/lib64/vendor.qti.gnss@1.1.so',
        'vendor/lib64/vendor.qti.gnss@1.2.so',
        'vendor/lib64/vendor.qti.gnss@2.0.so',
        'vendor/lib64/vendor.qti.gnss@2.1.so',
        'vendor/lib64/vendor.qti.hardware.cvp@1.0.so',
        'vendor/lib64/vendor.qti.hardware.fm@1.0.so',
        'vendor/lib64/vendor.qti.hardware.sensorscalibrate@1.0.so',
        'vendor/lib64/vendor.qti.hardware.soter@1.0.so',
        'vendor/lib64/vendor.qti.hardware.tui_comm@1.0.so',
        'vendor/lib64/vendor.qti.hardware.vpp@1.1.so',
        'vendor/lib64/vendor.qti.hardware.vpp@1.2.so',
        'vendor/lib64/vendor.semc.hardware.light@1.0.so',
        'vendor/lib64/vendor.semc.hardware.thermal@1.0.so',
        'vendor/lib64/vendor.somc.hardware.miscta@1.0.so',
        'vendor/lib64/vendor.somc.hardware.modemswitcher@1.0.so',
        'vendor/lib64/vendor.somc.hardware.security.secd@1.0.so',
        'vendor/lib64/vendor.somc.hardware.swiqi@1.0.so',
        'vendor/lib64/vendor.qti.hardware.iop@1.0.so',
        'vendor/lib64/vendor.qti.hardware.iop@2.0.so',
        'vendor/lib/com.qualcomm.qti.ant@1.0.so',
        'vendor/lib64/com.qualcomm.qti.ant@1.0.so',
        'vendor/lib/vendor.qti.power.pasrmanager@1.0.so',
        'vendor/lib64/vendor.qti.power.pasrmanager@1.0.so',
    ): blob_fixup()
        .replace_needed('libhidlbase.so', 'libhidlbase-v32.so'),
    (
        'vendor/bin/thermal-engine',
        'vendor/bin/keyprovd',
    ): blob_fixup()
        .add_needed('libhidlbase-v32.so'),
    (
        'vendor/lib/libgps.utils.so',
        'vendor/lib64/libgps.utils.so',
    ): blob_fixup()
        .add_needed('libprocessgroup.so'),
    (
        'vendor/etc/public.libraries.txt'
    ): blob_fixup()
        .regex_replace('libqti-perfd-client.so\n', ''),
    'vendor/etc/init/vendor.semc.hardware.charger@1.0-service.rc': blob_fixup()
        .regex_replace('user vendor', 'user system')
        .regex_replace('group vendor', 'group system'),
    'system/lib64/lib-imsvideocodec.so': blob_fixup()
        .add_needed('libgui_shim.so'),
	(
        'vendor/lib64/libdpps.so',
    ): blob_fixup()
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    'vendor/bin/hw/vendor.semc.hardware.secd@1.0-service': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v33.so')
}

module = ExtractUtilsModule(
    'sphinx',
    'sony',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()