#include "audio_synth.hpp"
#include "spatial_grid.hpp"
#include "starfield.hpp"

#include <luakit/library.hpp>
#include <luakit/class.hpp>

namespace core = luakit::core;

namespace cosmic {

auto createSpatialGrid(float cellSize) -> SpatialGrid {
    return SpatialGrid(cellSize);
}

auto createStarfield(float width, float height, int count) -> NativeStarfield {
    return NativeStarfield(width, height, count);
}

} // namespace cosmic

template <>
struct luakit::Metatable<cosmic::SpatialGrid> {
    static constexpr const char *k_name = "cosmic.SpatialGrid";
};

template <>
struct luakit::Metatable<cosmic::NativeStarfield> {
    static constexpr const char *k_name = "cosmic.NativeStarfield";
};

extern "C" auto luaopen_cosmic_native(core::State *L) -> int {
    using namespace cosmic;

    // Register SpatialGrid metatable & class
    luakit::Class<SpatialGrid>(L, "SpatialGrid")
        .method<&SpatialGrid::clear>("clear")
        .method<&SpatialGrid::addEntity>("add_entity")
        .method<&SpatialGrid::checkCollisions>("check_collisions")
        .ctor<float>("new")
        .build_module();

    // Register NativeStarfield metatable & class
    luakit::Class<NativeStarfield>(L, "NativeStarfield")
        .method<&NativeStarfield::update>("update")
        .method<&NativeStarfield::getBuffer>("get_buffer")
        .ctor<float, float, int>("new")
        .build_module();

    // Register Library functions & factories for cosmic_native
    return luakit::Library(L, "cosmic_native")
        .fn<AudioSynth::generateLaser>("generate_laser")
        .fn<AudioSynth::generateNoise>("generate_noise")
        .fn<AudioSynth::generateTone>("generate_tone")
        .fn<AudioSynth::generateArpeggio>("generate_arpeggio")
        .fn<AudioSynth::generateLaserBytes>("generate_laser_bytes")
        .fn<AudioSynth::generateNoiseBytes>("generate_noise_bytes")
        .fn<AudioSynth::generateToneBytes>("generate_tone_bytes")
        .fn<AudioSynth::generateArpeggioBytes>("generate_arpeggio_bytes")
        .fn<createSpatialGrid>("create_spatial_grid")
        .fn<createStarfield>("create_starfield")
        .build_module();
}
