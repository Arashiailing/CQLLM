/**
 * Collect and present key metadata and metrics about the analyzed Python snapshot.
 * This query gathers essential information including extractor details, 
 * snapshot characteristics, and code statistics.
 */

import python

// Define key-value pairs for snapshot metadata and metrics
from string metadataKey, string metadataValue
where
  // Extractor version information
  metadataKey = "Extractor version" and py_flags_versioned("extractor.version", metadataValue, _)
  or
  // Snapshot build timestamp
  metadataKey = "Snapshot build time" and
  exists(date buildTimestamp | snapshotDate(buildTimestamp) and metadataValue = buildTimestamp.toString())
  or
  // Python interpreter version in major.minor format
  metadataKey = "Interpreter version" and
  exists(string majorVer, string minorVer |
    py_flags_versioned("extractor_python_version.major", majorVer, _) and
    py_flags_versioned("extractor_python_version.minor", minorVer, _) and
    metadataValue = majorVer + "." + minorVer
  )
  or
  // Build platform with user-friendly names
  metadataKey = "Build platform" and
  exists(string platformIdentifier | py_flags_versioned("sys.platform", platformIdentifier, _) |
    if platformIdentifier = "win32"
    then metadataValue = "Windows"
    else
      if platformIdentifier = "linux2"
      then metadataValue = "Linux"
      else
        if platformIdentifier = "darwin"
        then metadataValue = "OSX"
        else metadataValue = platformIdentifier
  )
  or
  // Source code location prefix
  metadataKey = "Source location" and sourceLocationPrefix(metadataValue)
  or
  // Total lines of source code (only counting files with relative paths)
  metadataKey = "Lines of code (source)" and
  metadataValue =
    sum(ModuleMetrics codeMetrics | exists(codeMetrics.getFile().getRelativePath()) | 
        codeMetrics.getNumberOfLinesOfCode()).toString()
  or
  // Total lines of code including all files
  metadataKey = "Lines of code (total)" and
  metadataValue = sum(ModuleMetrics codeMetrics | any() | codeMetrics.getNumberOfLinesOfCode()).toString()
select metadataKey, metadataValue