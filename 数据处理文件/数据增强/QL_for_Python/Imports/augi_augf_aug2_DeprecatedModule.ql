/**
 * @name Import of deprecated module
 * @description Identifies imports of Python modules that have been deprecated in specific versions.
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

import python

/**
 * Identifies deprecated Python modules with version information and replacement suggestions.
 * 
 * @param moduleName Name of the deprecated module
 * @param replacementModule Recommended replacement or "no replacement"
 * @param majorVersion Major Python version where module was deprecated
 * @param minorVersion Minor Python version where module was deprecated
 */
predicate deprecated_module(string moduleName, string replacementModule, 
                           int majorVersion, int minorVersion) {
  // Python 1.x deprecations
  (moduleName = "posixfile" and replacementModule = "fcntl" and 
   majorVersion = 1 and minorVersion = 5)
  or
  (moduleName = "pre" and replacementModule = "re" and 
   majorVersion = 1 and minorVersion = 5)
  or
  // Python 2.0-2.2 deprecations
  (moduleName = "whrandom" and replacementModule = "random" and 
   majorVersion = 2 and minorVersion = 1)
  or
  (moduleName = "statcache" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 2)
  or
  (moduleName = "mpz" and replacementModule = "a third party" and 
   majorVersion = 2 and minorVersion = 2)
  or
  // Python 2.3-2.4 deprecations
  (moduleName = "rfc822" and replacementModule = "email" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "mimetools" and replacementModule = "email" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "MimeWriter" and replacementModule = "email" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "mimify" and replacementModule = "email" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "xreadlines" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "rotor" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 4)
  or
  // Python 2.5-2.6 deprecations
  (moduleName = "gopherlib" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 5)
  or
  (moduleName = "rgbimgmodule" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 5)
  or
  (moduleName = "multifile" and replacementModule = "email" and 
   majorVersion = 2 and minorVersion = 5)
  or
  (moduleName = "sets" and replacementModule = "builtins" and 
   majorVersion = 2 and minorVersion = 6)
  or
  // Additional deprecated modules
  (moduleName = "buildtools" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "cfmfile" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 4)
  or
  (moduleName = "macfs" and replacementModule = "no replacement" and 
   majorVersion = 2 and minorVersion = 3)
  or
  (moduleName = "md5" and replacementModule = "hashlib" and 
   majorVersion = 2 and minorVersion = 5)
  or
  (moduleName = "sha" and replacementModule = "hashlib" and 
   majorVersion = 2 and minorVersion = 5)
}

/**
 * Generates deprecation warning message for a module.
 * 
 * @param moduleName Name of the deprecated module
 * @return String describing deprecation version
 */
string deprecation_message(string moduleName) {
  exists(int majorVer, int minorVer | 
    deprecated_module(moduleName, _, majorVer, minorVer)
  |
    result = "Module '" + moduleName + "' was deprecated in Python " + 
             majorVer.toString() + "." + minorVer.toString()
  )
}

/**
 * Generates replacement suggestion message for a deprecated module.
 * 
 * @param moduleName Name of the deprecated module
 * @return Replacement suggestion or empty string
 */
string replacement_message(string moduleName) {
  exists(string replacement | 
    deprecated_module(moduleName, replacement, _, _)
  |
    if replacement = "no replacement"
    then result = ""
    else result = ". Replace with '" + replacement + "' module"
  )
}

// Main query: Detects imports of deprecated modules without exception handling
from ImportExpr importStatement, string moduleName, string replacementModule
where
  moduleName = importStatement.getName() and
  deprecated_module(moduleName, replacementModule, _, _) and
  // Exclude properly handled imports with ImportError exception
  not exists(Try tryBlock, ExceptStmt handler | 
    handler = tryBlock.getAHandler() and
    handler.getType().pointsTo(ClassValue::importError()) and
    handler.containsInScope(importStatement)
  )
select importStatement, 
       deprecation_message(moduleName) + replacement_message(moduleName)