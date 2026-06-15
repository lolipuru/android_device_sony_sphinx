/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xperia.settings.audio

import android.os.Bundle
import android.provider.Settings
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.SwitchPreference

import com.xperia.settings.audio.R
import com.xperia.settings.audio.SonyAudioEffectService

class AudioSettingsFragment : PreferenceFragmentCompat() {

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.audio_settings_preferences, rootKey)

        findPreference<SwitchPreference>("pref_clearaudio")?.setOnPreferenceChangeListener { _, newValue ->
            Settings.Secure.putInt(
                requireContext().contentResolver,
                SonyAudioEffectService.KEY_CLEARAUDIO,
                if (newValue as Boolean) 1 else 0
            )
            true
        }

        findPreference<SwitchPreference>("pref_sforce")?.setOnPreferenceChangeListener { _, newValue ->
            Settings.Secure.putInt(
                requireContext().contentResolver,
                SonyAudioEffectService.KEY_SFORCE,
                if (newValue as Boolean) 1 else 0
            )
            true
        }

        findPreference<SwitchPreference>("pref_xloud")?.setOnPreferenceChangeListener { _, newValue ->
            Settings.Secure.putInt(
                requireContext().contentResolver,
                SonyAudioEffectService.KEY_XLOUD,
                if (newValue as Boolean) 1 else 0
            )
            true
        }
    }
}