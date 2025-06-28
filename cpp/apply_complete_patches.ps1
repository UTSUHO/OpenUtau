# Complete patch application script
Write-Host "Applying complete patches to all dependencies..." -ForegroundColor Green

$dependenciesDir = "dependencies"
$thirdPartyDir = "third_party"

# Function to apply world patch completely
function Apply-WorldPatch {
    Write-Host "Applying complete world patch..." -ForegroundColor Cyan
    $worldDir = "$dependenciesDir\world"
    
    if (!(Test-Path $worldDir)) {
        Write-Host "World directory not found: $worldDir" -ForegroundColor Red
        return $false
    }
    
    Push-Location $worldDir
    
    # Apply d4c.cpp patch
    $d4cPath = "src/d4c.cpp"
    if (Test-Path $d4cPath) {
        $content = Get-Content $d4cPath -Raw
        $pattern = "GetSmoothedPowerSpectrum\(x, x_length, fs, current_f0, fft_size,`r?`n      current_position, forward_real_fft, smoothed_power_spectrum\);"
        $replacement = "GetSmoothedPowerSpectrum(x, x_length, fs, current_f0, fft_size,`n      current_position, forward_real_fft, smoothed_power_spectrum);`n  for (int i = 0; i < fft_size / 2 + 1; ++i) {`n    smoothed_power_spectrum[i] = MyMaxDouble(`n      world::kMySafeGuardMinimum, smoothed_power_spectrum[i]);`n  }"
        $content = $content -replace $pattern, $replacement
        Set-Content $d4cPath $content -NoNewline
        Write-Host "Applied d4c.cpp patch" -ForegroundColor Green
    }
    
    # Apply synthesis.h patch
    $synthesisHPath = "src/world/synthesis.h"
    if (Test-Path $synthesisHPath) {
        $content = Get-Content $synthesisHPath -Raw
        # Add new parameters to comments
        $content = $content -replace "//   fs                   : Sampling frequency", "//   fs                   : Sampling frequency`n//   tension              : Tension, 1 = unmodified`n//   breathiness          : Breathiness, 1 = unmodified`n//   voicing              : Voicing, 1 = unmodified"
        # Update function declaration
        $content = $content -replace "void Synthesis\(const double \*f0, int f0_length,`r?`n    const double \* const \*spectrogram, const double \* const \*aperiodicity,`r?`n    int fft_size, double frame_period, int fs, int y_length, double \*y\);", "void Synthesis(const double *f0, int f0_length,`n    const double * const *spectrogram, const double * const *aperiodicity,`n    int fft_size, double frame_period, int fs,`n    double** const tension, double* const breathiness, double* const voicing,`n    int y_length, double *y);"
        Set-Content $synthesisHPath $content -NoNewline
        Write-Host "Applied synthesis.h patch" -ForegroundColor Green
    }
    
    # Apply synthesis.cpp patch
    $synthesisCPath = "src/synthesis.cpp"
    if (Test-Path $synthesisCPath) {
        $content = Get-Content $synthesisCPath -Raw
        
        # Update GetPeriodicResponse function signature
        $content = $content -replace "static void GetPeriodicResponse\(int fft_size, const double \*spectrum,`r?`n    const double \*aperiodic_ratio, double current_vuv,`r?`n    const InverseRealFFT \*inverse_real_fft,`r?`n    const MinimumPhaseAnalysis \*minimum_phase, const double \*dc_remover,`r?`n    double fractional_time_shift, int fs, double \*periodic_response\)", "static void GetPeriodicResponse(int fft_size, const double *spectrum,`n    const double *aperiodic_ratio, double current_vuv,`n    const InverseRealFFT *inverse_real_fft,`n    const MinimumPhaseAnalysis *minimum_phase, const double *dc_remover,`n    double fractional_time_shift, int fs,`n    const double* tension, double *periodic_response)"
        
        # Update GetPeriodicResponse function body
        $content = $content -replace "minimum_phase->log_spectrum\[i\] =`r?`n      log\(spectrum\[i\] \* \(1\.0 - aperiodic_ratio\[i\]\) \+`r?`n      world::kMySafeGuardMinimum\) / 2\.0;", "minimum_phase->log_spectrum[i] =`n      log(spectrum[i] * (1.0 - aperiodic_ratio[i]) * tension[i] +`n      world::kMySafeGuardMinimum) / 2.0;"
        
        # Update GetOneFrameSegment function signature
        $content = $content -replace "static void GetOneFrameSegment\(double current_vuv, int noise_size,`r?`n    const double \* const \*spectrogram, int fft_size,`r?`n    const double \* const \*aperiodicity, int f0_length, double frame_period,`r?`n    double \*pulse_locations, double \*pulse_locations_time_shift, int fs,`r?`n    const ForwardRealFFT \*forward_real_fft,`r?`n    const InverseRealFFT \*inverse_real_fft,`r?`n    const MinimumPhaseAnalysis \*minimum_phase, const double \*dc_remover,`r?`n    double \*response\)", "static void GetOneFrameSegment(double current_vuv, int noise_size,`n    const double * const *spectrogram, int fft_size,`n    const double * const *aperiodicity, int f0_length, double frame_period,`n    double *pulse_locations, double *pulse_locations_time_shift, int fs,`n    const ForwardRealFFT *forward_real_fft,`n    const InverseRealFFT *inverse_real_fft,`n    const MinimumPhaseAnalysis *minimum_phase, const double *dc_remover,`n    double* const tension, double breathiness, double voicing,`n    double *response)"
        
        # Update GetOneFrameSegment function call
        $content = $content -replace "GetPeriodicResponse\(fft_size, spectral_envelope, aperiodic_ratio,`r?`n      current_vuv, inverse_real_fft, minimum_phase, dc_remover,`r?`n      fractional_time_shift, fs, periodic_response\);", "GetPeriodicResponse(fft_size, spectral_envelope, aperiodic_ratio,`n      current_vuv, inverse_real_fft, minimum_phase, dc_remover,`n      fractional_time_shift, fs, tension, periodic_response);"
        
        # Update response calculation
        $content = $content -replace "response\[i\] =`r?`n      \(periodic_response\[i\] \* sqrt_noise_size \+ aperiodic_response\[i\]\) /`r?`n      fft_size;", "response[i] = (periodic_response[i] * voicing * sqrt_noise_size +`n                   aperiodic_response[i] * breathiness) /`n                  fft_size;"
        
        # Update Synthesis function signature
        $content = $content -replace "void Synthesis\(const double \*f0, int f0_length,`r?`n    const double \* const \*spectrogram, const double \* const \*aperiodicity,`r?`n    int fft_size, double frame_period, int fs, int y_length, double \*y\)", "void Synthesis(const double *f0, int f0_length,`n    const double * const *spectrogram, const double * const *aperiodicity,`n    int fft_size, double frame_period, int fs,`n    double** const tension, double* const breathiness, double* const voicing,`n    int y_length, double *y)"
        
        # Update Synthesis function body
        $content = $content -replace "noise_size = pulse_locations_index\[MyMinInt\(number_of_pulses - 1, i \+ 1\)\] -`r?`n      pulse_locations_index\[i\];", "noise_size = pulse_locations_index[MyMinInt(number_of_pulses - 1, i + 1)] -`n      pulse_locations_index[i];`n    int frame_index = (int)(1.0 * pulse_locations_index[i] / fs / frame_period);"
        
        $content = $content -replace "GetOneFrameSegment\(interpolated_vuv\[pulse_locations_index\[i\]\], noise_size,`r?`n        spectrogram, fft_size, aperiodicity, f0_length, frame_period,`r?`n        pulse_locations\[i\], pulse_locations_time_shift\[i\], fs,`r?`n        &forward_real_fft, &inverse_real_fft, &minimum_phase, dc_remover,`r?`n        impulse_response\);", "GetOneFrameSegment(interpolated_vuv[pulse_locations_index[i]], noise_size,`n        spectrogram, fft_size, aperiodicity, f0_length, frame_period,`n        pulse_locations[i], pulse_locations_time_shift[i], fs,`n        &forward_real_fft, &inverse_real_fft, &minimum_phase, dc_remover,`n        tension[frame_index], breathiness[frame_index], voicing[frame_index], impulse_response);"
        
        Set-Content $synthesisCPath $content -NoNewline
        Write-Host "Applied synthesis.cpp patch" -ForegroundColor Green
    }
    
    Pop-Location
    return $true
}

# Apply libpyin patch
Write-Host "Applying libpyin patch..." -ForegroundColor Cyan
$libpyinDir = "$dependenciesDir\libpyin"

if (Test-Path $libpyinDir) {
    Push-Location $libpyinDir
    
    # Apply common.h patch
    $commonHPath = "common.h"
    if (Test-Path $commonHPath) {
        $content = Get-Content $commonHPath -Raw
        $content = $content -replace "#include <unistd\.h>", "#if !defined(_WIN32)`n#include <unistd.h>`n#endif"
        $content = $content -replace "#ifdef max`r?`n#undef max`r?`n#endif`r?`n#ifdef min`r?`n#undef min`r?`n#endif`r?`n#define max\(a, b\) \(\(a\) > \(b\) \? \(a\) : \(b\)\)`r?`n#define min\(a, b\) \(\(a\) < \(b\) \? \(a\) : \(b\)\)", ""
        Set-Content $commonHPath $content -NoNewline
        Write-Host "Applied common.h patch" -ForegroundColor Green
    }
    
    # Apply pyin.c patch
    $pyinCPath = "pyin.c"
    if (Test-Path $pyinCPath) {
        $content = Get-Content $pyinCPath -Raw
        $content = $content -replace "#include <libgvps/gvps\.h>", "#include `"libgvps/gvps.h`""
        $content = $content -replace "#include `"math-funcs\.h`"`r?`n#include `"pyin\.h`"", "#include `"math-funcs.h`"`n#include `"pyin.h`"`n`n#if !defined(_WIN32)`nstatic int min(int a, int b) { return a < b ? a : b; }`n#endif"
        Set-Content $pyinCPath $content -NoNewline
        Write-Host "Applied pyin.c patch" -ForegroundColor Green
    }
    
    Pop-Location
    Write-Host "✓ libpyin patch applied" -ForegroundColor Green
}

# Apply spline patch
Write-Host "Applying spline patch..." -ForegroundColor Cyan
$splineDir = "$dependenciesDir\spline"

if (Test-Path $splineDir) {
    Push-Location $splineDir
    
    $splineHPath = "src/spline.h"
    if (Test-Path $splineHPath) {
        $content = Get-Content $splineHPath -Raw
        $content = $content -replace "#pragma GCC diagnostic push`r?`n#pragma GCC diagnostic ignored `"-Wunused-function`"", "// #pragma GCC diagnostic push`n// #pragma GCC diagnostic ignored `"-Wunused-function`""
        $content = $content -replace "namespace tk`r?`n{", "namespace tk`n{`n`nconstexpr double pi = 3.14159265358979323846;`n"
        $content = $content -replace "z\[1\] = sq \* cos\(ac-2\.0\*M_PI/3\.0\);`r?`n        z\[2\] = sq \* cos\(ac-4\.0\*M_PI/3\.0\);", "z[1] = sq * cos(ac-2.0*pi/3.0);`n        z[2] = sq * cos(ac-4.0*pi/3.0);"
        Set-Content $splineHPath $content -NoNewline
        Write-Host "✓ spline patch applied" -ForegroundColor Green
    }
    
    Pop-Location
}

# Apply world patch completely
Apply-WorldPatch

Write-Host "`nAll patches applied successfully!" -ForegroundColor Green 