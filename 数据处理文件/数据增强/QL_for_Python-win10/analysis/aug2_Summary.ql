/**
 * @name Snapshot Information Summary
 * @description Provides a comprehensive overview of snapshot metadata including
 *              extractor details, build information, interpreter version,
 *              platform details, source location, and code metrics.
 */

import python

// Define key-value pairs for snapshot summary data
from string infoKey, string infoValue
where
  // Extractor version identification
  infoKey = "Extractor version" and 
  py_flags_versioned("extractor.version", infoValue, _)
  or
  // Snapshot build timestamp information
  infoKey = "Snapshot build time" and
  exists(date buildDate | snapshotDate(buildDate) and infoValue = buildDate.toString())
  or
  // Python interpreter version in major.minor format
  infoKey = "Interpreter version" and
  exists(string majorVer, string minorVer |
    py_flags_versioned("extractor_python_version.major", majorVer, _) and
    py_flags_versioned("extractor_python_version.minor", minorVer, _) and
    infoValue = majorVer + "." + minorVer
  )
  or
  // Build platform with user-friendly naming
  infoKey = "Build platform" and
  exists(string platformRaw | py_flags_versioned("sys.platform", platformRaw, _) |
    if platformRaw = "win32"
    then infoValue = "Windows"
    else
      if platformRaw = "linux2"
      then infoValue = "Linux"
      else
        if platformRaw = "darwin"
        then infoValue = "OSX"
        else infoValue = platformRaw
  )
  or
  // Source code location prefix path
  infoKey = "Source location" and sourceLocationPrefix(infoValue)
  or
  // Total lines of source code (excluding generated code)
  infoKey = "Lines of code (source)" and
  infoValue =
    sum(ModuleMetrics metrics | exists(metrics.getFile().getRelativePath()) | 
        metrics.getNumberOfLinesOfCode()).toString()
  or
  // Total lines of code (including all generated code)
  infoKey = "Lines of code (total)" and
  infoValue = sum(ModuleMetrics metrics | any() | metrics.getNumberOfLinesOfCode()).toString()
select infoKey, infoValue