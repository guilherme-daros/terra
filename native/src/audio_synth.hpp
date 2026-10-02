#pragma once

#include <vector>
#include <string>
#include <cmath>

namespace cosmic {

class AudioSynth {
public:
    static auto generateLaser(float startFreq, float endFreq, float duration, int sampleRate = 44100) -> std::vector<float>;
    static auto generateNoise(float duration, int sampleRate = 44100) -> std::vector<float>;
    static auto generateTone(float startFreq, float endFreq, float duration, std::string waveType, int sampleRate = 44100) -> std::vector<float>;
    static auto generateArpeggio(std::vector<double> notes, float totalDuration, int sampleRate = 44100) -> std::vector<float>;
};

} // namespace cosmic
