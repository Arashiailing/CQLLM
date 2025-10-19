/**
 * Provides metadata summary of the analyzed Python snapshot.
 * Collects technical metrics and system information as key-value pairs
 * to offer insights about the codebase characteristics.
 */

import python

// Gather metadata key-value pairs for Python snapshot analysis
from string metaKey, string metaValue
where
  // Extractor version information
  metaKey = "Extractor version" and py_flags_versioned("extractor.version", metaValue, _)
  or
  // Snapshot creation timestamp
  metaKey = "Snapshot build time" and
  exists(date buildDate | 
    snapshotDate(buildDate) and 
    metaValue = buildDate.toString()
  )
  or
  // Python interpreter version in standard format
  metaKey = "Interpreter version" and
  exists(string pyMajorVer, string pyMinorVer |
    py_flags_versioned("extractor_python_version.major", pyMajorVer, _) and
    py_flags_versioned("extractor_python_version.minor", pyMinorVer, _) and
    metaValue = pyMajorVer + "." + pyMinorVer
  )
  or
  // Build platform with friendly naming
  metaKey = "Build platform" and
  exists(string platformId | 
    py_flags_versioned("sys.platform", platformId, _) |
    (
      platformId = "win32" and metaValue = "Windows"
    ) or (
      platformId = "linux2" and metaValue = "Linux"
    ) or (
      platformId = "darwin" and metaValue = "OSX"
    ) or (
      not (platformId = "win32" or platformId = "linux2" or platformId = "darwin") and
      metaValue = platformId
    )
  )
  or
  // Source code root directory
  metaKey = "Source location" and sourceLocationPrefix(metaValue)
  or
  // Source code line count (relative path files only)
  metaKey = "Lines of code (source)" and
  metaValue = sum(ModuleMetrics moduleStats | 
    exists(moduleStats.getFile().getRelativePath()) | 
    moduleStats.getNumberOfLinesOfCode()
  ).toString()
  or
  // Total code line count (all files)
  metaKey = "Lines of code (total)" and
  metaValue = sum(ModuleMetrics moduleStats | any() | 
    moduleStats.getNumberOfLinesOfCode()
  ).toString()
select metaKey, metaValue