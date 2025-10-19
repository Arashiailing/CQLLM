/**
 * @name Snapshot Metadata Overview
 * @description Generates a detailed summary of snapshot metadata, encompassing
 *              extractor information, build details, Python interpreter version,
 *              platform specifics, source location, and code statistics.
 */

import python

// Define key-value pairs for snapshot metadata
from string metadataKey, string metadataValue
where
  // Extractor version identification
  metadataKey = "Extractor version" and 
  py_flags_versioned("extractor.version", metadataValue, _)
  or
  // Snapshot build timestamp
  metadataKey = "Snapshot build time" and
  exists(date snapshotDate | snapshotDate(snapshotDate) and metadataValue = snapshotDate.toString())
  or
  // Python interpreter version in major.minor format
  metadataKey = "Interpreter version" and
  exists(string majorVersion, string minorVersion |
    py_flags_versioned("extractor_python_version.major", majorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", minorVersion, _) and
    metadataValue = majorVersion + "." + minorVersion
  )
  or
  // Build platform with user-friendly naming
  metadataKey = "Build platform" and
  exists(string rawPlatform | py_flags_versioned("sys.platform", rawPlatform, _) |
    if rawPlatform = "win32"
    then metadataValue = "Windows"
    else
      if rawPlatform = "linux2"
      then metadataValue = "Linux"
      else
        if rawPlatform = "darwin"
        then metadataValue = "OSX"
        else metadataValue = rawPlatform
  )
  or
  // Source code location prefix path
  metadataKey = "Source location" and sourceLocationPrefix(metadataValue)
  or
  // Total lines of source code (excluding generated code)
  metadataKey = "Lines of code (source)" and
  metadataValue =
    sum(ModuleMetrics moduleMetrics | exists(moduleMetrics.getFile().getRelativePath()) | 
        moduleMetrics.getNumberOfLinesOfCode()).toString()
  or
  // Total lines of code (including all generated code)
  metadataKey = "Lines of code (total)" and
  metadataValue = sum(ModuleMetrics moduleMetrics | any() | moduleMetrics.getNumberOfLinesOfCode()).toString()
select metadataKey, metadataValue