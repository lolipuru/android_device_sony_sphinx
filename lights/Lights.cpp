/*
 * Copyright (C) 2019 The Android Open Source Project
 * Copyright (C) 2023 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Lights.h"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <fcntl.h>

using ::android::base::WriteStringToFile;

namespace aidl {
namespace android {
namespace hardware {
namespace light {

#define LED_PATH(led) "/sys/class/leds/" led "/"
#define RGB_CTRL_PATH LED_PATH("rgb")

static const std::string led_paths[]{
        [RED] = LED_PATH("red"),
        [GREEN] = LED_PATH("green"),
        [BLUE] = LED_PATH("blue"),
};

#define AutoHwLight(light) \
    { .id = (int32_t)light, .type = light, .ordinal = 0 }

// List of supported lights
const static std::vector<HwLight> kAvailableLights = {AutoHwLight(LightType::BATTERY),
                                                      AutoHwLight(LightType::NOTIFICATIONS),
                                                      AutoHwLight(LightType::ATTENTION)};

Lights::Lights() {
    for (int i = 0; i < NUM_LIGHTS; i++) {
        uint32_t max_br = ReadIntFromFile(led_paths[i] + "max_brightness", 0xFF);
        mMaxSingleBrightness[i] = ReadIntFromFile(led_paths[i] + "max_single_brightness", max_br);
        mMaxMixBrightness[i] = ReadIntFromFile(led_paths[i] + "max_mix_brightness", max_br);
    }
}

// AIDL methods
ndk::ScopedAStatus Lights::setLightState(int32_t id, const HwLightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    LightType type = static_cast<LightType>(id);
    switch (type) {
        case LightType::BATTERY:
            mBattery = state;
            break;
        case LightType::NOTIFICATIONS:
            mNotification = state;
            break;
        case LightType::ATTENTION:
            mAttention = state;
            break;
        default:
            return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    // Notifications and attention take priority over Battery light
    if (IsLit(mNotification.color))
        setSpeakerLightLocked(mNotification);
    else if (IsLit(mAttention.color))
        setSpeakerLightLocked(mAttention);
    else if (IsLit(mBattery.color))
        setSpeakerLightLocked(mBattery);
    else
        setSpeakerLightLocked(mNotification);

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Lights::getLights(std::vector<HwLight>* lights) {
    for (auto& light : kAvailableLights) lights->push_back(light);

    return ndk::ScopedAStatus::ok();
}

// device methods
void Lights::setSpeakerLightLocked(const HwLightState& state) {
    uint32_t red, green, blue;

    // Extract brightness from RRGGBB
    red = (state.color >> 16) & 0xFF;
    green = (state.color >> 8) & 0xFF;
    blue = state.color & 0xFF;

    int active_colors = (red > 0) + (green > 0) + (blue > 0);
    bool isMixed = (active_colors >= 2);

    switch (state.flashMode) {
        case FlashMode::HARDWARE:
        case FlashMode::TIMED:
            if (active_colors == 0) {
                WriteToFile(RGB_CTRL_PATH "sync_state", 0);
                setLedBrightness(RED, 0, false);
                setLedBrightness(GREEN, 0, false);
                setLedBrightness(BLUE, 0, false);
            } else {
                WriteToFile(RGB_CTRL_PATH "sync_state", 1);  // CONFIGURE_TO_BLINK
                if (red > 0)
                    setLedBlink(RED, red, state.flashOnMs, state.flashOffMs, isMixed);
                if (green > 0)
                    setLedBlink(GREEN, green, state.flashOnMs, state.flashOffMs, isMixed);
                if (blue > 0)
                    setLedBlink(BLUE, blue, state.flashOnMs, state.flashOffMs, isMixed);
                WriteToFile(RGB_CTRL_PATH "start_blink", 1);
            }
            break;
        case FlashMode::NONE:
        default:
            WriteToFile(RGB_CTRL_PATH "sync_state", 0);  // NOT_BLINK
            setLedBrightness(RED, red, isMixed);
            setLedBrightness(GREEN, green, isMixed);
            setLedBrightness(BLUE, blue, isMixed);
            break;
    }

    return;
}

uint32_t Lights::getActualBrightness(led_type led, uint32_t value, bool isMixed) {
    uint32_t max_br = isMixed ? mMaxMixBrightness[led] : mMaxSingleBrightness[led];
    return value * max_br / 0xFF;
}

bool Lights::setLedBlink(led_type led, uint32_t value, uint32_t onMs, uint32_t offMs, bool isMixed) {
    bool ret = true;
    ret &= WriteStringToFile(std::to_string(getActualBrightness(led, value, isMixed)) + ",0",
                            led_paths[led] + "lut_pwm");
    ret &= WriteToFile(led_paths[led] + "step_duration", 0);
    ret &= WriteToFile(led_paths[led] + "pause_lo_multi", offMs);
    ret &= WriteToFile(led_paths[led] + "pause_hi_multi", onMs);
    return ret;
}

bool Lights::setLedBrightness(led_type led, uint32_t value, bool isMixed) {
    return WriteToFile(led_paths[led] + "brightness", getActualBrightness(led, value, isMixed));
}

// Utils
bool Lights::IsLit(uint32_t color) {
    return color & 0x00ffffff;
}

uint32_t Lights::ReadIntFromFile(const std::string& path, uint32_t defaultValue) {
    std::string buf;

    if (::android::base::ReadFileToString(path, &buf)) {
        return std::stoi(buf);
    }
    return defaultValue;
}

// Write value to path and close file.
bool Lights::WriteToFile(const std::string& path, uint32_t content) {
    return WriteStringToFile(std::to_string(content), path);
}

}  // namespace light
}  // namespace hardware
}  // namespace android
}  // namespace aidl
