#include "starfield.hpp"
#include <cmath>
#include <random>

namespace cosmic {

NativeStarfield::NativeStarfield(float width, float height, int count)
    : width(width), height(height) {
    std::mt19937 rng(1337);
    std::uniform_real_distribution<float> distW(0.0f, width);
    std::uniform_real_distribution<float> distH(0.0f, height);
    std::uniform_real_distribution<float> distSpeed(10.0f, 60.0f);
    std::uniform_real_distribution<float> distTwinkle(1.0f, 4.0f);

    stars.reserve(count);
    for (int i = 0; i < count; ++i) {
        float sz = (distW(rng) / width < 0.7f) ? 1.0f : 2.0f;
        stars.push_back({
            distW(rng),
            distH(rng),
            distSpeed(rng),
            sz,
            0.8f,
            distTwinkle(rng)
        });
    }
}

void NativeStarfield::update(float dt, float gameTime) {
    for (auto& star : stars) {
        star.y += star.speed * dt;
        if (star.y > height) {
            star.y = 0.0f;
            star.x = std::fmod(star.x * 1.3f + 17.0f, width);
        }
        star.brightness = 0.5f + 0.5f * std::sin(gameTime * star.twinkleSpeed + star.x);
    }
}

auto NativeStarfield::getBuffer() const -> std::vector<float> {
    std::vector<float> buf;
    buf.reserve(stars.size() * 4);
    for (const auto& star : stars) {
        buf.push_back(star.x);
        buf.push_back(star.y);
        buf.push_back(star.size);
        buf.push_back(star.brightness);
    }
    return buf;
}

auto NativeStarfield::getRawBytes() const -> std::string {
    std::string bytes(stars.size() * 4 * sizeof(float), '\0');
    float* ptr = reinterpret_cast<float*>(bytes.data());
    std::size_t idx = 0;
    for (const auto& star : stars) {
        ptr[idx++] = star.x;
        ptr[idx++] = star.y;
        ptr[idx++] = star.size;
        ptr[idx++] = star.brightness;
    }
    return bytes;
}

auto NativeStarfield::getStarCount() const -> int {
    return static_cast<int>(stars.size());
}

} // namespace cosmic
