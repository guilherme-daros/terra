#include "spatial_grid.hpp"
#include <unordered_map>

namespace cosmic {

auto SpatialGrid::checkCollisions() -> std::vector<int> {
    std::vector<int> pairs;
    std::unordered_map<long long, std::vector<std::size_t>> grid;

    auto getKey = [this](float x, float y) -> long long {
        long long cx = static_cast<long long>(std::floor(x / cellSize));
        long long cy = static_cast<long long>(std::floor(y / cellSize));
        return (cx << 32) ^ (cy & 0xFFFFFFFFLL);
    };

    for (std::size_t i = 0; i < entities.size(); ++i) {
        const auto& e = entities[i];
        long long key = getKey(e.x, e.y);
        grid[key].push_back(i);
    }

    for (std::size_t i = 0; i < entities.size(); ++i) {
        const auto& a = entities[i];
        int cx = static_cast<int>(std::floor(a.x / cellSize));
        int cy = static_cast<int>(std::floor(a.y / cellSize));

        for (int dx = -1; dx <= 1; ++dx) {
            for (int dy = -1; dy <= 1; ++dy) {
                long long key = (static_cast<long long>(cx + dx) << 32) ^ (static_cast<long long>(cy + dy) & 0xFFFFFFFFLL);
                auto it = grid.find(key);
                if (it != grid.end()) {
                    for (std::size_t j : it->second) {
                        if (i >= j) continue;
                        const auto& b = entities[j];
                        if (a.team == b.team) continue;

                        float distSq = (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
                        float rSum = a.radius + b.radius;
                        if (distSq < rSum * rSum) {
                            pairs.push_back(a.id);
                            pairs.push_back(b.id);
                        }
                    }
                }
            }
        }
    }

    return pairs;
}

} // namespace cosmic
