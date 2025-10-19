/**
 * Aggregates diverse metadata and metrics from the analyzed Python snapshot,
 * presenting them as structured key-value pairs for comprehensive analysis.
 */

import python

// Collect snapshot metadata as key-value pairs
from string metricKey, string metricValue
where
  // Extractor version identification
  metricKey = "Extractor version" and py_flags_versioned("extractor.version", metricValue, _)
  or
  // Snapshot creation timestamp
  metricKey = "Snapshot build time" and
  exists(date snapshotTimestamp | 
    snapshotDate(snapshotTimestamp) and 
    metricValue = snapshotTimestamp.toString()
  )
  or
  // Python interpreter version in major.minor format
  metricKey = "Interpreter version" and
  exists(string pythonMajorVersion, string pythonMinorVersion |
    py_flags_versioned("extractor_python_version.major", pythonMajorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", pythonMinorVersion, _) and
    metricValue = pythonMajorVersion + "." + pythonMinorVersion
  )
  or
  // Build platform with user-friendly naming
  metricKey = "Build platform" and
  exists(string platformIdentifier | 
    py_flags_versioned("sys.platform", platformIdentifier, _) |
    if platformIdentifier = "win32"
    then metricValue = "Windows"
    else
      if platformIdentifier = "linux2"
      then metricValue = "Linux"
      else
        if platformIdentifier = "darwin"
        then metricValue = "OSX"
        else metricValue = platformIdentifier
  )
  or
  // Source code root directory location
  metricKey = "Source location" and sourceLocationPrefix(metricValue)
  or
  // Source code lines count (files with relative paths only)
  metricKey = "Lines of code (source)" and
  metricValue =
    sum(ModuleMetrics moduleStatistics | 
        exists(moduleStatistics.getFile().getRelativePath()) | 
        moduleStatistics.getNumberOfLinesOfCode()
    ).toString()
  or
  // Total lines of code across all files
  metricKey = "Lines of code (total)" and
  metricValue = 
    sum(ModuleMetrics moduleStatistics | 
        any() | 
        moduleStatistics.getNumberOfLinesOfCode()
    ).toString()
select metricKey, metricValue