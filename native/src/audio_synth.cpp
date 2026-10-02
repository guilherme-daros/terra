#include "audio_synth.hpp"
#include <algorithm>
#include <random>

#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__)
#include <emmintrin.h>
#include <xmmintrin.h>
#define HAS_SSE2 1
#endif

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace cosmic {

auto AudioSynth::generateLaser(float startFreq, float endFreq, float duration, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    float invSamples = 1.0f / samples;
    float invSampleRate = 1.0f / sampleRate;
    float twoPi = static_cast<float>(2.0 * M_PI);

    int i = 0;
#if defined(HAS_SSE2)
    // 4-wide SSE2 SIMD vectorization loop
    __m128 v_start   = _mm_set1_ps(startFreq);
    __m128 v_diff    = _mm_set1_ps(endFreq - startFreq);
    __m128 v_invSamp = _mm_set1_ps(invSamples);
    __m128 v_invRate = _mm_set1_ps(invSampleRate);
    __m128 v_twoPi   = _mm_set1_ps(twoPi);

    for (; i <= samples - 4; i += 4) {
        __m128 v_idx = _mm_set_ps(i + 3, i + 2, i + 1, i);
        __m128 v_prog = _mm_mul_ps(v_idx, v_invSamp);
        __m128 v_freq = _mm_add_ps(v_start, _mm_mul_ps(v_diff, v_prog));
        __m128 v_t    = _mm_mul_ps(v_idx, v_invRate);
        __m128 v_phase = _mm_mul_ps(_mm_mul_ps(v_twoPi, v_freq), v_t);

        alignas(16) float p[4];
        alignas(16) float prog[4];
        _mm_store_ps(p, v_phase);
        _mm_store_ps(prog, v_prog);

        alignas(16) float res[4];
        for (int k = 0; k < 4; ++k) {
            res[k] = std::sin(p[k]) * (1.0f - prog[k]) * 0.4f;
        }

        _mm_storeu_ps(&buffer[i], _mm_load_ps(res));
    }
#endif

    // Remainder loop
    for (; i < samples; ++i) {
        float progress = static_cast<float>(i) * invSamples;
        float freq = startFreq + (endFreq - startFreq) * progress;
        float phase = twoPi * freq * (static_cast<float>(i) * invSampleRate);
        buffer[i] = std::sin(phase) * (1.0f - progress) * 0.4f;
    }
    return buffer;
}

auto AudioSynth::generateNoise(float duration, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    std::mt19937 rng(42);
    std::uniform_real_distribution<float> dist(-1.0f, 1.0f);

    float invSamples = 1.0f / samples;
    int i = 0;

#if defined(HAS_SSE2)
    __m128 v_invSamp = _mm_set1_ps(invSamples);
    __m128 v_one     = _mm_set1_ps(1.0f);
    __m128 v_gain    = _mm_set1_ps(0.4f);

    for (; i <= samples - 4; i += 4) {
        __m128 v_idx = _mm_set_ps(i + 3, i + 2, i + 1, i);
        __m128 v_prog = _mm_mul_ps(v_idx, v_invSamp);
        __m128 v_env  = _mm_sub_ps(v_one, v_prog);
        v_env = _mm_mul_ps(v_env, v_env); // envelope^2

        alignas(16) float randVals[4];
        for (int k = 0; k < 4; ++k) {
            randVals[k] = dist(rng);
        }
        __m128 v_rand = _mm_load_ps(randVals);
        __m128 v_res  = _mm_mul_ps(_mm_mul_ps(v_rand, v_env), v_gain);
        _mm_storeu_ps(&buffer[i], v_res);
    }
#endif

    for (; i < samples; ++i) {
        float progress = static_cast<float>(i) * invSamples;
        float envelope = (1.0f - progress) * (1.0f - progress);
        buffer[i] = dist(rng) * envelope * 0.4f;
    }
    return buffer;
}

auto AudioSynth::generateTone(float startFreq, float endFreq, float duration, std::string waveType, int sampleRate) -> std::vector<float> {
    int samples = static_cast<int>(sampleRate * duration);
    std::vector<float> buffer(samples);
    float invSamples = 1.0f / samples;
    float invSampleRate = 1.0f / sampleRate;

    for (int i = 0; i < samples; ++i) {
        float progress = static_cast<float>(i) * invSamples;
        float currentFreq = startFreq + (endFreq - startFreq) * progress;
        double t = static_cast<double>(i) * invSampleRate;
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
    float invSamples = 1.0f / samples;
    float invSampleRate = 1.0f / sampleRate;

    for (int i = 0; i < samples; ++i) {
        double t = static_cast<double>(i) * invSampleRate;
        std::size_t noteIdx = std::min(notes.size() - 1, static_cast<std::size_t>(t / noteDuration));
        double freq = notes[noteIdx];
        float progress = static_cast<float>(i) * invSamples;
        buffer[i] = static_cast<float>(std::sin(2.0 * M_PI * freq * t)) * (1.0f - progress) * 0.3f;
    }
    return buffer;
}

} // namespace cosmic
