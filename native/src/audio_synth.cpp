#include "audio_synth.hpp"
#include <algorithm>
#include <random>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace cosmic {

auto AudioSynth::generateLaser(float startFreq, float endFreq, float duration, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    for (int i = 0; i < samples; ++i) {
        float progress = static_cast<float>(i) / samples;
        float freq = startFreq + (endFreq - startFreq) * progress;
        float phase = static_cast<float>(2.0 * M_PI * freq * (static_cast<double>(i) / sampleRate));
        buffer[i] = std::sin(phase) * (1.0f - progress) * 0.4f;
    }
    return buffer;
}

auto AudioSynth::generateNoise(float duration, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    std::mt19937 rng(42);
    std::uniform_real_distribution<float> dist(-1.0f, 1.0f);

    for (int i = 0; i < samples; ++i) {
        float progress = static_cast<float>(i) / samples;
        float envelope = (1.0f - progress) * (1.0f - progress);
        buffer[i] = dist(rng) * envelope * 0.4f;
    }
    return buffer;
}

auto AudioSynth::generateTone(float startFreq, float endFreq, float duration, std::string waveType, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    for (int i = 0; i < samples; ++i) {
        float progress = static_cast<float>(i) / samples;
        float currentFreq = startFreq + (endFreq - startFreq) * progress;
        double t = static_cast<double>(i) / sampleRate;
        float val = 0.0f;
        if (waveType == "square") {
            val = (std::sin(2.0 * M_PI * currentFreq * t) >= 0.0) ? 0.3f : -0.3f;
        } else if (waveType == "saw") {
            val = static_cast<float>(2.0 * (t * currentFreq - std::floor(0.5 + t * currentFreq))) * 0.3f;
        } else {
            val = static_cast<float>(std::sin(2.0 * M_PI * currentFreq * t)) * 0.3f;
        }
        buffer[i] = val * (1.0f - progress);
    }
    return buffer;
}

auto AudioSynth::generateArpeggio(std::vector<double> notes, float totalDuration, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * totalDuration);
    std::vector<float> buffer(samples);
    if (notes.empty()) return buffer;

    float noteDuration = totalDuration / static_cast<float>(notes.size());
    for (int i = 0; i < samples; ++i) {
        double t = static_cast<double>(i) / sampleRate;
        std::size_t noteIdx = std::min(notes.size() - 1, static_cast<std::size_t>(t / noteDuration));
        double freq = notes[noteIdx];
        float progress = static_cast<float>(i) / samples;
        buffer[i] = static_cast<float>(std::sin(2.0 * M_PI * freq * t)) * (1.0f - progress) * 0.3f;
    }
    return buffer;
}

} // namespace cosmic
