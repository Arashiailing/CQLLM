/**
 * @name Database Snapshot Metadata Summary
 * @description Generates a comprehensive summary of metadata information extracted from the database snapshot,
 *              including version details, build information, platform specifics, and code metrics.
 * @kind problem
 * @id py/database-snapshot-summary
 */

import python

// Define metadata identifiers and their corresponding extracted values
from string metricIdentifier, string metricData
where
  // Extractor version metadata: Retrieve version string from extractor flags
  metricIdentifier = "Extractor version" and py_flags_versioned("extractor.version", metricData, _)
  or
  // Snapshot creation timestamp: Convert build date to string representation
  metricIdentifier = "Snapshot build time" and
  exists(date snapshotCreationDate | snapshotDate(snapshotCreationDate) and metricData = snapshotCreationDate.toString())
  or
  // Python interpreter version details: Combine major and minor version numbers
  metricIdentifier = "Interpreter version" and
  exists(string primaryVersion, string secondaryVersion |
    py_flags_versioned("extractor_python_version.major", primaryVersion, _) and
    py_flags_versioned("extractor_python_version.minor", secondaryVersion, _) and
    metricData = primaryVersion + "." + secondaryVersion
  )
  or
  // Build platform identification: Map raw platform identifiers to user-friendly names
  metricIdentifier = "Build platform" and
  exists(string platformIdentifier | py_flags_versioned("sys.platform", platformIdentifier, _) |
    if platformIdentifier = "win32"
    then metricData = "Windows"
    else
      if platformIdentifier = "linux2"
      then metricData = "Linux"
      else
        if platformIdentifier = "darwin"
        then metricData = "OSX"
        else metricData = platformIdentifier
  )
  or
  // Source code root location: Extract the base path of the source code
  metricIdentifier = "Source location" and sourceLocationPrefix(metricData)
  or
  // Source code line count: Calculate total lines of code across all modules with relative paths
  metricIdentifier = "Lines of code (source)" and
  metricData =
    sum(ModuleMetrics moduleStatistics | exists(moduleStatistics.getFile().getRelativePath()) | moduleStatistics.getNumberOfLinesOfCode())
        .toString()
  or
  // Total line count: Calculate comprehensive line count including all modules
  metricIdentifier = "Lines of code (total)" and
  metricData = sum(ModuleMetrics moduleStatistics | any() | moduleStatistics.getNumberOfLinesOfCode()).toString()
select metricIdentifier, metricData