/**
 * @name Python Snapshot Metadata and Metrics
 * @description This query collects and presents comprehensive metadata and metrics
 *              about the analyzed Python snapshot. It provides insights into the
 *              extraction process, runtime environment, and codebase characteristics.
 * @kind problem
 * @id python/snapshot-metadata
 */

import python

// Define key-value pairs for snapshot metadata and metrics
from string infoKey, string infoValue
where
  // Extractor version information
  (
    infoKey = "Extractor version" and 
    py_flags_versioned("extractor.version", infoValue, _)
  )
  or
  // Snapshot build timestamp
  (
    infoKey = "Snapshot build time" and
    exists(date snapshotBuildTime | 
      snapshotDate(snapshotBuildTime) and 
      infoValue = snapshotBuildTime.toString()
    )
  )
  or
  // Python interpreter version in major.minor format
  (
    infoKey = "Interpreter version" and
    exists(string pythonMajorVersion, string pythonMinorVersion |
      py_flags_versioned("extractor_python_version.major", pythonMajorVersion, _) and
      py_flags_versioned("extractor_python_version.minor", pythonMinorVersion, _) and
      infoValue = pythonMajorVersion + "." + pythonMinorVersion
    )
  )
  or
  // Build platform with user-friendly names
  (
    infoKey = "Build platform" and
    exists(string platformCode | 
      py_flags_versioned("sys.platform", platformCode, _) |
      if platformCode = "win32"
      then infoValue = "Windows"
      else
        if platformCode = "linux2"
        then infoValue = "Linux"
        else
          if platformCode = "darwin"
          then infoValue = "OSX"
          else infoValue = platformCode
    )
  )
  or
  // Source code location prefix
  (
    infoKey = "Source location" and 
    sourceLocationPrefix(infoValue)
  )
  or
  // Total lines of source code (only counting files with relative paths)
  (
    infoKey = "Lines of code (source)" and
    infoValue =
      sum(ModuleMetrics moduleStats | 
        exists(moduleStats.getFile().getRelativePath()) | 
        moduleStats.getNumberOfLinesOfCode()
      ).toString()
  )
  or
  // Total lines of code including all files
  (
    infoKey = "Lines of code (total)" and
    infoValue = 
      sum(ModuleMetrics moduleStats | any() | 
        moduleStats.getNumberOfLinesOfCode()
      ).toString()
  )
select infoKey, infoValue