/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xperia.settings.audio

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d("XperiaAudioBoot", "Starting Sony Audio Effect service...")
            val serviceIntent = Intent(context, SonyAudioEffectService::class.java)
            context.startService(serviceIntent)
        }
    }
}
