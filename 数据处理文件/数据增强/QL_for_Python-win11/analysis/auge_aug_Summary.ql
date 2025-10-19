/**
 * @name Snapshot Summary
 * @description Generates a detailed summary of the analyzed Python code snapshot,
 *              providing information about extractor version, build timestamp,
 *              Python interpreter version, build platform, source location,
 *              and comprehensive lines of code metrics.
 */

import python

// Define key-value pairs for different snapshot attributes
from string attrKey, string attrValue
where
  // Extractor version information
  attrKey = "Extractor version" and 
  py_flags_versioned("extractor.version", attrValue, _)
  
  or
  
  // Snapshot build timestamp
  attrKey = "Snapshot build time" and
  exists(date creationDate | 
    snapshotDate(creationDate) and 
    attrValue = creationDate.toString()
  )
  
  or
  
  // Python interpreter version (major.minor format)
  attrKey = "Interpreter version" and
  exists(string majorVersion, string minorVersion |
    py_flags_versioned("extractor_python_version.major", majorVersion, _) and
    py_flags_versioned("extractor_python_version.minor", minorVersion, _) and
    attrValue = majorVersion + "." + minorVersion
  )
  
  or
  
  // Build platform with friendly names
  attrKey = "Build platform" and
  exists(string platformIdentifier | 
    py_flags_versioned("sys.platform", platformIdentifier, _) |
    if platformIdentifier = "win32"
    then attrValue = "Windows"
    else
      if platformIdentifier = "linux2"
      then attrValue = "Linux"
      else
        if platformIdentifier = "darwin"
        then attrValue = "OSX"
        else attrValue = platformIdentifier
  )
  
  or
  
  // Source location prefix
  attrKey = "Source location" and 
  sourceLocationPrefix(attrValue)
  
  or
  
  // Total lines of source code (only for files with relative paths)
  attrKey = "Lines of code (source)" and
  attrValue = sum(ModuleMetrics moduleMetrics | 
    exists(moduleMetrics.getFile().getRelativePath()) | 
    moduleMetrics.getNumberOfLinesOfCode()
  ).toString()
  
  or
  
  // Total lines of code (all files)
  attrKey = "Lines of code (total)" and
  attrValue = sum(ModuleMetrics moduleMetrics | 
    any() | 
    moduleMetrics.getNumberOfLinesOfCode()
  ).toString()

select attrKey, attrValue