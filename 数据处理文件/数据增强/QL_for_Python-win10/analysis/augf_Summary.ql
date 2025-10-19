/**
 * Generate a comprehensive summary of metrics from a Python code snapshot
 */

import python

// Define metric key-value pairs for snapshot analysis
from string metricKey, string metricValue
where
  // Extractor version information
  (
    metricKey = "Extractor version" and 
    py_flags_versioned("extractor.version", metricValue, _)
  )
  or
  // Snapshot build timestamp
  (
    metricKey = "Snapshot build time" and
    exists(date d | snapshotDate(d) and metricValue = d.toString())
  )
  or
  // Python interpreter version details
  (
    metricKey = "Interpreter version" and
    exists(string majorVersion, string minorVersion |
      py_flags_versioned("extractor_python_version.major", majorVersion, _) and
      py_flags_versioned("extractor_python_version.minor", minorVersion, _) and
      metricValue = majorVersion + "." + minorVersion
    )
  )
  or
  // Build platform identification with user-friendly names
  (
    metricKey = "Build platform" and
    exists(string rawPlatform | py_flags_versioned("sys.platform", rawPlatform, _) |
      if rawPlatform = "win32"
      then metricValue = "Windows"
      else
        if rawPlatform = "linux2"
        then metricValue = "Linux"
        else
          if rawPlatform = "darwin"
          then metricValue = "OSX"
          else metricValue = rawPlatform
    )
  )
  or
  // Source code location prefix
  (
    metricKey = "Source location" and sourceLocationPrefix(metricValue)
  )
  or
  // Source code lines count (excluding generated files)
  (
    metricKey = "Lines of code (source)" and
    metricValue =
      sum(ModuleMetrics m | exists(m.getFile().getRelativePath()) | m.getNumberOfLinesOfCode())
          .toString()
  )
  or
  // Total lines of code count (including all files)
  (
    metricKey = "Lines of code (total)" and
    metricValue = sum(ModuleMetrics m | any() | m.getNumberOfLinesOfCode()).toString()
  )
select metricKey, metricValue