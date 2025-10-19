/**
 * Generate a comprehensive summary of the analyzed Python snapshot
 * by collecting various metadata and metrics into key-value pairs.
 */

import python

// Retrieve snapshot information as key-value pairs
from string infoKey, string infoValue
where
  // Extractor version information
  infoKey = "Extractor version" and py_flags_versioned("extractor.version", infoValue, _)
  or
  // Snapshot build timestamp
  infoKey = "Snapshot build time" and
  exists(date buildDate | snapshotDate(buildDate) and infoValue = buildDate.toString())
  or
  // Python interpreter version in major.minor format
  infoKey = "Interpreter version" and
  exists(string majorVersion, string minorVersion |
    py_flags_versioned("extractor_python_version.major", majorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", minorVersion, _) and
    infoValue = majorVersion + "." + minorVersion
  )
  or
  // Build platform with user-friendly names
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
  // Source code location prefix
  infoKey = "Source location" and sourceLocationPrefix(infoValue)
  or
  // Total lines of source code (only counting files with relative paths)
  infoKey = "Lines of code (source)" and
  infoValue =
    sum(ModuleMetrics moduleMetric | exists(moduleMetric.getFile().getRelativePath()) | 
        moduleMetric.getNumberOfLinesOfCode()).toString()
  or
  // Total lines of code including all files
  infoKey = "Lines of code (total)" and
  infoValue = sum(ModuleMetrics moduleMetric | any() | moduleMetric.getNumberOfLinesOfCode()).toString()
select infoKey, infoValue