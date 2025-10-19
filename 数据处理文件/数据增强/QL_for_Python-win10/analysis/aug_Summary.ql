/**
 * @name Snapshot Summary
 * @description Provides a comprehensive summary of the analyzed Python code snapshot,
 *              including extractor version, build time, interpreter version,
 *              build platform, source location, and lines of code metrics.
 */

import python

// Select key-value pairs summarizing different aspects of the snapshot
from string summaryKey, string summaryValue
where
  // Extractor version information
  summaryKey = "Extractor version" and 
  py_flags_versioned("extractor.version", summaryValue, _)
  
  or
  
  // Snapshot build timestamp
  summaryKey = "Snapshot build time" and
  exists(date buildDate | 
    snapshotDate(buildDate) and 
    summaryValue = buildDate.toString()
  )
  
  or
  
  // Python interpreter version (major.minor format)
  summaryKey = "Interpreter version" and
  exists(string majorVer, string minorVer |
    py_flags_versioned("extractor_python_version.major", majorVer, _) and
    py_flags_versioned("extractor_python_version.minor", minorVer, _) and
    summaryValue = majorVer + "." + minorVer
  )
  
  or
  
  // Build platform with friendly names
  summaryKey = "Build platform" and
  exists(string platformRaw | 
    py_flags_versioned("sys.platform", platformRaw, _) |
    if platformRaw = "win32"
    then summaryValue = "Windows"
    else
      if platformRaw = "linux2"
      then summaryValue = "Linux"
      else
        if platformRaw = "darwin"
        then summaryValue = "OSX"
        else summaryValue = platformRaw
  )
  
  or
  
  // Source location prefix
  summaryKey = "Source location" and 
  sourceLocationPrefix(summaryValue)
  
  or
  
  // Total lines of source code (only for files with relative paths)
  summaryKey = "Lines of code (source)" and
  summaryValue = sum(ModuleMetrics moduleMetrics | 
    exists(moduleMetrics.getFile().getRelativePath()) | 
    moduleMetrics.getNumberOfLinesOfCode()
  ).toString()
  
  or
  
  // Total lines of code (all files)
  summaryKey = "Lines of code (total)" and
  summaryValue = sum(ModuleMetrics moduleMetrics | 
    any() | 
    moduleMetrics.getNumberOfLinesOfCode()
  ).toString()

select summaryKey, summaryValue