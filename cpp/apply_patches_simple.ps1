# Apply patches to local dependencies
Write-Host "Applying patches to local dependencies..." -ForegroundColor Green

$dependenciesDir = "dependencies"
$thirdPartyDir = "third_party"

# Apply libpyin patch
Write-Host "Applying patch to libpyin..." -ForegroundColor Cyan
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
Write-Host "Applying patch to spline..." -ForegroundColor Cyan
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

# Apply world patch (partial)
Write-Host "Applying patch to world..." -ForegroundColor Cyan
$worldDir = "$dependenciesDir\world"

if (Test-Path $worldDir) {
    Push-Location $worldDir
    
    $d4cPath = "src/d4c.cpp"
    if (Test-Path $d4cPath) {
        $content = Get-Content $d4cPath -Raw
        $pattern = "GetSmoothedPowerSpectrum\(x, x_length, fs, current_f0, fft_size,`r?`n      current_position, forward_real_fft, smoothed_power_spectrum\);"
        $replacement = "GetSmoothedPowerSpectrum(x, x_length, fs, current_f0, fft_size,`n      current_position, forward_real_fft, smoothed_power_spectrum);`n  for (int i = 0; i < fft_size / 2 + 1; ++i) {`n    smoothed_power_spectrum[i] = MyMaxDouble(`n      world::kMySafeGuardMinimum, smoothed_power_spectrum[i]);`n  }"
        $content = $content -replace $pattern, $replacement
        Set-Content $d4cPath $content -NoNewline
        Write-Host "✓ world patch applied (partial)" -ForegroundColor Green
    }
    
    Pop-Location
}

Write-Host "`nPatch application completed!" -ForegroundColor Green 