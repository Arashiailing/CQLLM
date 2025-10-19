/**
 * @description Generates a detailed summary of the analyzed Python snapshot.
 * This query gathers diverse metadata and metrics, presenting them as key-value pairs
 * to provide a comprehensive overview of the codebase.
 */

import python

// Collect metadata key-value pairs for the Python snapshot analysis
from string metadataKey, string metadataValue
where
  // Extractor version information
  metadataKey = "Extractor version" and py_flags_versioned("extractor.version", metadataValue, _)
  
  or
  
  // Snapshot build timestamp
  metadataKey = "Snapshot build time" and
  exists(date snapshotBuildDate | 
    snapshotDate(snapshotBuildDate) and 
    metadataValue = snapshotBuildDate.toString()
  )
  
  or
  
  // Python interpreter version in major.minor format
  metadataKey = "Interpreter version" and
  exists(string pythonMajorVersion, string pythonMinorVersion |
    py_flags_versioned("extractor_python_version.major", pythonMajorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", pythonMinorVersion, _) and
    metadataValue = pythonMajorVersion + "." + pythonMinorVersion
  )
  
  or
  
  // Build platform with user-friendly names
  metadataKey = "Build platform" and
  exists(string rawPlatformValue | 
    py_flags_versioned("sys.platform", rawPlatformValue, _) |
    if rawPlatformValue = "win32"
    then metadataValue = "Windows"
    else
      if rawPlatformValue = "linux2"
      then metadataValue = "Linux"
      else
        if rawPlatformValue = "darwin"
        then metadataValue = "OSX"
        else metadataValue = rawPlatformValue
  )
  
  or
  
  // Source code location prefix
  metadataKey = "Source location" and sourceLocationPrefix(metadataValue)
  
  or
  
  // Total lines of source code (only counting files with relative paths)
  metadataKey = "Lines of code (source)" and
  metadataValue =
    sum(ModuleMetrics codeMetrics | 
        exists(codeMetrics.getFile().getRelativePath()) | 
        codeMetrics.getNumberOfLinesOfCode()
    ).toString()
  
  or
  
  // Total lines of code including all files
  metadataKey = "Lines of code (total)" and
  metadataValue = sum(ModuleMetrics codeMetrics | 
      any() | 
      codeMetrics.getNumberOfLinesOfCode()
  ).toString()

select metadataKey, metadataValue