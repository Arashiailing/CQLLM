/**
 * @name Snapshot Metadata Overview
 * @description Generates a detailed summary of snapshot metadata including extractor
 *              details, build information, Python interpreter version, platform details,
 *              source location, and comprehensive code metrics.
 */

import python

// Define metadata key-value pairs for snapshot information
from string metadataKey, string metadataValue
where
  // Extractor information
  metadataKey = "Extractor version" and py_flags_versioned("extractor.version", metadataValue, _)
  or
  // Build information
  metadataKey = "Snapshot build time" and
  exists(date snapshotDate | snapshotDate(snapshotDate) and metadataValue = snapshotDate.toString())
  or
  // Python interpreter details
  metadataKey = "Interpreter version" and
  exists(string majorVersion, string minorVersion |
    py_flags_versioned("extractor_python_version.major", majorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", minorVersion, _) and
    metadataValue = majorVersion + "." + minorVersion
  )
  or
  // Platform information
  metadataKey = "Build platform" and
  exists(string platformIdentifier | py_flags_versioned("sys.platform", platformIdentifier, _) |
    platformIdentifier = "win32" and metadataValue = "Windows"
    or
    platformIdentifier = "linux2" and metadataValue = "Linux"
    or
    platformIdentifier = "darwin" and metadataValue = "OSX"
    or
    metadataValue = platformIdentifier
  )
  or
  // Source code information
  metadataKey = "Source location" and sourceLocationPrefix(metadataValue)
  or
  // Code metrics - source lines only
  metadataKey = "Lines of code (source)" and
  metadataValue = 
    sum(ModuleMetrics codeMetrics | 
        exists(codeMetrics.getFile().getRelativePath()) | 
        codeMetrics.getNumberOfLinesOfCode()
    ).toString()
  or
  // Code metrics - total lines including generated code
  metadataKey = "Lines of code (total)" and
  metadataValue = 
    sum(ModuleMetrics codeMetrics | 
        any() | 
        codeMetrics.getNumberOfLinesOfCode()
    ).toString()
select metadataKey, metadataValue