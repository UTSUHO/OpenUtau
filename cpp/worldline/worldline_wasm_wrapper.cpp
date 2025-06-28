#include "worldline.h"
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#include <vector>
#include <memory>
#include <cstring>

using namespace emscripten;

// C-style wrapper functions for JavaScript interop
extern "C" {

EMSCRIPTEN_KEEPALIVE
int worldline_get_version() {
    return 1; // Version number
}

EMSCRIPTEN_KEEPALIVE
const char* worldline_get_version_string() {
    return "OpenUtau Worldline WASM 1.0";
}

EMSCRIPTEN_KEEPALIVE
PhraseSynth* worldline_phrase_synth_new() {
    return PhraseSynthNew();
}

EMSCRIPTEN_KEEPALIVE
void worldline_phrase_synth_delete(PhraseSynth* phrase_synth) {
    PhraseSynthDelete(phrase_synth);
}

EMSCRIPTEN_KEEPALIVE
int worldline_f0_estimation(float* samples, int length, int fs, double frame_period, int method, double** f0) {
    return F0(samples, length, fs, frame_period, method, f0);
}

EMSCRIPTEN_KEEPALIVE
int worldline_world_synthesis(
    double* f0, int f0_length,
    double* mgc_or_sp, int is_mgc, int mgc_size,
    double* bap_or_ap, int is_bap, int fft_size,
    double frame_period, int fs, double** y,
    double* gender, double* tension, double* breathiness, double* voicing
) {
    return WorldSynthesis(f0, f0_length, mgc_or_sp, is_mgc != 0, mgc_size,
                         bap_or_ap, is_bap != 0, fft_size, frame_period, fs, y,
                         gender, tension, breathiness, voicing);
}

// Simplified synthesis function for easier JavaScript usage
EMSCRIPTEN_KEEPALIVE
int worldline_simple_synthesis(
    double* f0_data, int f0_length,
    double* mgc_data, int mgc_size,
    double frame_period, int fs,
    float** output_buffer, int* output_length
) {
    try {
        double* y = nullptr;
        
        // Create default parameters
        std::vector<double> gender(f0_length, 0.5);
        std::vector<double> tension(f0_length, 0.5);
        std::vector<double> breathiness(f0_length, 0.5);
        std::vector<double> voicing(f0_length, 1.0);
        
        // Create default aperiodicity (all zeros for now)
        int fft_size = 2048;
        std::vector<double> bap(f0_length * (fft_size / 2 + 1), 0.0);
        
        int result = WorldSynthesis(
            f0_data, f0_length,
            mgc_data, true, mgc_size,
            bap.data(), true, fft_size,
            frame_period, fs, &y,
            gender.data(), tension.data(), breathiness.data(), voicing.data()
        );
        
        if (result <= 0 || y == nullptr) {
            *output_length = 0;
            return -1;
        }
        
        // Convert double to float and copy to output buffer
        *output_length = result;
        *output_buffer = (float*)malloc(result * sizeof(float));
        if (*output_buffer == nullptr) {
            free(y);
            return -1;
        }
        
        for (int i = 0; i < result; i++) {
            (*output_buffer)[i] = (float)y[i];
        }
        
        free(y);
        return 0;
        
    } catch (const std::exception& e) {
        *output_length = 0;
        return -1;
    }
}

} // extern "C"

// Emscripten bindings for C++ classes
EMSCRIPTEN_BINDINGS(worldline_module) {
    // Export basic functions
    function("getVersion", &worldline_get_version);
    function("getVersionString", &worldline_get_version_string);
    function("phraseSynthNew", &worldline_phrase_synth_new, allow_raw_pointers());
    function("phraseSynthDelete", &worldline_phrase_synth_delete, allow_raw_pointers());
    function("f0Estimation", &worldline_f0_estimation, allow_raw_pointers());
    function("worldSynthesis", &worldline_world_synthesis, allow_raw_pointers());
    function("simpleSynthesis", &worldline_simple_synthesis, allow_raw_pointers());
    
    // Export PhraseSynth class
    class_<PhraseSynth>("PhraseSynth");
} 