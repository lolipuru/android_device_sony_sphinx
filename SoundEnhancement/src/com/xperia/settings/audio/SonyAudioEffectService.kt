/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xperia.settings.audio

import android.app.Service
import android.content.Intent
import android.database.ContentObserver
import android.media.audiofx.AudioEffect
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemProperties
import android.provider.Settings
import android.util.Log
import java.lang.reflect.Method
import java.util.UUID

class SonyAudioEffectService : Service() {

    companion object {
        private const val TAG = "SonyAudioEffectService"
        
        private val EFFECT_TYPE_NULL = UUID.fromString("ec7178ec-e5e1-4432-a3f4-4657e6795210")
        private val EFFECT_TYPE_AUDIOEFFECT = UUID.fromString("50786e95-da76-4557-976b-7981bdf6feb9")
        private val EFFECT_TYPE_AUDIOEFFECT_PROXY = UUID.fromString("af8da7e0-2ca1-11e3-b71d-0002a5d5c51b")

        private const val PARAM_SFORCE_ON = 1
        private const val PARAM_XLOUD_ON = 9
        private const val PARAM_CLEAR_AUDIO_PLUS_ON = 10

        const val KEY_CLEARAUDIO = "sony_audio_clearaudio"
        const val KEY_SFORCE = "sony_audio_sforce"
        const val KEY_XLOUD = "sony_audio_xloud"
    }

    private var sonyBundleEffect: AudioEffect? = null
    private val handler = Handler(Looper.getMainLooper())

    private var setParameterShortMethod: Method? = null
    private var setParameterByteMethod: Method? = null

    private val settingsObserver = object : ContentObserver(handler) {
        override fun onChange(selfChange: Boolean) {
            updateEffectsFromSettings()
        }
    }

    override fun onCreate() {
        super.onCreate()
        initReflection()
        initAudioEffect()
        
        contentResolver.apply {
            registerContentObserver(Settings.Secure.getUriFor(KEY_CLEARAUDIO), false, settingsObserver)
            registerContentObserver(Settings.Secure.getUriFor(KEY_SFORCE), false, settingsObserver)
            registerContentObserver(Settings.Secure.getUriFor(KEY_XLOUD), false, settingsObserver)
        }

        updateEffectsFromSettings()
        Log.d(TAG, "Service started, Sony effects mapped to correct parameters.")
    }

    private fun initReflection() {
        try {
            setParameterShortMethod = AudioEffect::class.java.getMethod(
                "setParameter",
                Int::class.javaPrimitiveType,
                Short::class.javaPrimitiveType
            )
        } catch (e: NoSuchMethodException) {
            Log.w(TAG, "setParameter(int, short) unavailable, caching byte-array method fallback.")
            try {
                setParameterByteMethod = AudioEffect::class.java.getMethod(
                    "setParameter",
                    Int::class.javaPrimitiveType,
                    ByteArray::class.java
                )
            } catch (ex: Exception) {
                Log.e(TAG, "Fatal: Complete reflection failure on AudioEffect structure", ex)
            }
        }
    }

    private fun initAudioEffect() {
        if (sonyBundleEffect != null) return
        try {
            val useProxy = SystemProperties.getBoolean("audio.sony.effect.use.proxy", false)
            val effectUuid = if (useProxy) EFFECT_TYPE_AUDIOEFFECT_PROXY else EFFECT_TYPE_AUDIOEFFECT
            
            sonyBundleEffect = AudioEffect(EFFECT_TYPE_NULL, effectUuid, 0, 0).apply {
                enabled = true
            }
            Log.d(TAG, "AudioEffect successfully bound. Enabled state: ${sonyBundleEffect?.enabled}")
        } catch (e: Exception) {
            Log.e(TAG, "CRITICAL: Failed to instantiate Sony AudioEffect proxy!", e)
        }
    }

    private fun updateEffectsFromSettings() {
        val clearAudio = Settings.Secure.getInt(contentResolver, KEY_CLEARAUDIO, 0) == 1
        val sforce = Settings.Secure.getInt(contentResolver, KEY_SFORCE, 0) == 1
        val xloud = Settings.Secure.getInt(contentResolver, KEY_XLOUD, 0) == 1

        Log.d(TAG, "Applying Sound Profiles -> ClearAudio+: $clearAudio, S-Force: $sforce, xLOUD: $xloud")
        
        setSonyParameter(PARAM_CLEAR_AUDIO_PLUS_ON, clearAudio)
        setSonyParameter(PARAM_SFORCE_ON, sforce)
        setSonyParameter(PARAM_XLOUD_ON, xloud)
    }

    private fun setSonyParameter(paramId: Int, enabled: Boolean) {
        val effect = sonyBundleEffect ?: return
        val value = if (enabled) 1 else 0

        setParameterShortMethod?.let { method ->
            try {
                val status = method.invoke(effect, paramId, value.toShort()) as Int
                if (status == 0) {
                    Log.d(TAG, "Successfully pushed Param: $paramId -> Value: $value")
                } else {
                    Log.e(TAG, "Native AudioServer rejected paramId $paramId with status code: $status")
                }
                return
            } catch (e: Exception) {
                Log.e(TAG, "Error invoking cached short method for param $paramId", e)
            }
        }

        setParameterByteMethod?.let { method ->
            try {
                val targetBytes = byteArrayOf(value.toByte())
                val status = method.invoke(effect, paramId, targetBytes) as Int
                Log.d(TAG, "Byte-array fallback result for param $paramId: $status")
            } catch (e: Exception) {
                Log.e(TAG, "Error invoking cached byte method for param $paramId", e)
            }
        }
    }

    override fun onDestroy() {
        contentResolver.unregisterContentObserver(settingsObserver)
        sonyBundleEffect?.apply {
            enabled = false
            release()
        }
        sonyBundleEffect = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}