/**
 * @name Python Snapshot Metrics Summary
 * @description Generates a comprehensive summary of metrics from a Python code snapshot,
 *              including extractor information, build details, and code statistics.
 */

import python

// Define metric key-value pairs for snapshot analysis
from string metricDescriptor, string metricData
where
  // Extractor version information - identifies the version of the CodeQL Python extractor used
  (
    metricDescriptor = "Extractor version" and 
    py_flags_versioned("extractor.version", metricData, _)
  )
  or
  // Snapshot creation timestamp - when the code snapshot was built
  (
    metricDescriptor = "Snapshot build time" and
    exists(date buildDate | snapshotDate(buildDate) and metricData = buildDate.toString())
  )
  or
  // Python interpreter version details - major and minor version of the Python interpreter
  (
    metricDescriptor = "Interpreter version" and
    exists(string majorVer, string minorVer |
      py_flags_versioned("extractor_python_version.major", majorVer, _) and
      py_flags_versioned("extractor_python_version.minor", minorVer, _) and
      metricData = majorVer + "." + minorVer
    )
  )
  or
  // Build platform identification with user-friendly names - converts system platform identifiers
  (
    metricDescriptor = "Build platform" and
    exists(string platformId | py_flags_versioned("sys.platform", platformId, _) |
      if platformId = "win32"
      then metricData = "Windows"
      else
        if platformId = "linux2"
        then metricData = "Linux"
        else
          if platformId = "darwin"
          then metricData = "OSX"
          else metricData = platformId
    )
  )
  or
  // Source code location prefix - the root directory of the analyzed source code
  (
    metricDescriptor = "Source location" and sourceLocationPrefix(metricData)
  )
  or
  // Source code lines count (excluding generated files) - counts only actual source code
  (
    metricDescriptor = "Lines of code (source)" and
    metricData =
      sum(ModuleMetrics modMetrics | exists(modMetrics.getFile().getRelativePath()) | 
          modMetrics.getNumberOfLinesOfCode()).toString()
  )
  or
  // Total lines of code count (including all files) - counts all files in the snapshot
  (
    metricDescriptor = "Lines of code (total)" and
    metricData = sum(ModuleMetrics modMetrics | any() | modMetrics.getNumberOfLinesOfCode()).toString()
  )
select metricDescriptor, metricData