#pragma once

#include <vector>

namespace cosmic {

struct StarData {
    float x;
    float y;
    float speed;
    float size;
    float brightness;
    float twinkleSpeed;
};

class NativeStarfield {
private:
    float width;
    float height;
    std::vector<StarData> stars;

public:
    NativeStarfield(float width, float height, int count);
    void update(float dt, float gameTime);
    auto getBuffer() const -> std::vector<float>;
};

} // namespace cosmic
