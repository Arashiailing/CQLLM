/**
 * Generates a comprehensive metadata summary of the analyzed Python snapshot.
 * This query collects various technical metrics and system information into
 * key-value pairs to provide insights about the analyzed codebase.
 */

import python

// Collect metadata key-value pairs for the Python snapshot analysis
from string metadataKey, string metadataValue
where
  // Extractor version identification
  metadataKey = "Extractor version" and py_flags_versioned("extractor.version", metadataValue, _)
  or
  // Snapshot creation timestamp
  metadataKey = "Snapshot build time" and
  exists(date snapshotCreationDate | 
    snapshotDate(snapshotCreationDate) and 
    metadataValue = snapshotCreationDate.toString()
  )
  or
  // Python interpreter version in standardized format
  metadataKey = "Interpreter version" and
  exists(string pythonMajorVersion, string pythonMinorVersion |
    py_flags_versioned("extractor_python_version.major", pythonMajorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", pythonMinorVersion, _) and
    metadataValue = pythonMajorVersion + "." + pythonMinorVersion
  )
  or
  // Build platform with user-friendly naming convention
  metadataKey = "Build platform" and
  exists(string platformIdentifier | 
    py_flags_versioned("sys.platform", platformIdentifier, _) |
    (
      platformIdentifier = "win32" and metadataValue = "Windows"
    ) or (
      platformIdentifier = "linux2" and metadataValue = "Linux"
    ) or (
      platformIdentifier = "darwin" and metadataValue = "OSX"
    ) or (
      not (platformIdentifier = "win32" or platformIdentifier = "linux2" or platformIdentifier = "darwin") and
      metadataValue = platformIdentifier
    )
  )
  or
  // Source code root location
  metadataKey = "Source location" and sourceLocationPrefix(metadataValue)
  or
  // Source code line count (relative path files only)
  metadataKey = "Lines of code (source)" and
  metadataValue = sum(ModuleMetrics codeModuleMetric | 
    exists(codeModuleMetric.getFile().getRelativePath()) | 
    codeModuleMetric.getNumberOfLinesOfCode()
  ).toString()
  or
  // Total code line count (all files included)
  metadataKey = "Lines of code (total)" and
  metadataValue = sum(ModuleMetrics codeModuleMetric | any() | 
    codeModuleMetric.getNumberOfLinesOfCode()
  ).toString()
select metadataKey, metadataValue