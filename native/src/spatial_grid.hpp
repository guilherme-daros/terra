#pragma once

#include <vector>
#include <unordered_map>
#include <cmath>

namespace cosmic {

struct CircleEntity {
    int id;
    float x;
    float y;
    float radius;
    int team;
};

class SpatialGrid {
private:
    float cellSize;
    std::vector<CircleEntity> entities;

public:
    explicit SpatialGrid(float cellSize = 64.0f) : cellSize(cellSize) {}

    void clear() {
        entities.clear();
    }

    void addEntity(int id, float x, float y, float radius, int team) {
        entities.push_back({id, x, y, radius, team});
    }

    auto checkCollisions() -> std::vector<int>;
};

} // namespace cosmic
