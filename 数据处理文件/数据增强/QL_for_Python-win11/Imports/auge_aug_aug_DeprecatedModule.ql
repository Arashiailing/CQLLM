/**
 * @name Import of deprecated module
 * @description Identifies imports of Python modules that have been deprecated
 *              in specific versions and recommends alternatives
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
 * Checks if a module was deprecated in a specific Python version
 * and provides its replacement recommendation
 *
 * @param moduleName The name of the module being checked
 * @param replacement Recommended replacement module or "no replacement"
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleName, string replacement, 
                          int majorVersion, int minorVersion) {
  // Define deprecated modules with their replacements and deprecation versions
  (
    moduleName = "posixfile" and replacement = "fcntl" and 
    majorVersion = 1 and minorVersion = 5
  ) or (
    moduleName = "gopherlib" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    moduleName = "rgbimgmodule" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    moduleName = "pre" and replacement = "re" and 
    majorVersion = 1 and minorVersion = 5
  ) or (
    moduleName = "whrandom" and replacement = "random" and 
    majorVersion = 2 and minorVersion = 1
  ) or (
    moduleName = "rfc822" and replacement = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "mimetools" and replacement = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "MimeWriter" and replacement = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "mimify" and replacement = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "rotor" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 4
  ) or (
    moduleName = "statcache" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 2
  ) or (
    moduleName = "mpz" and replacement = "a third party" and 
    majorVersion = 2 and minorVersion = 2
  ) or (
    moduleName = "xreadlines" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "multifile" and replacement = "email" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    moduleName = "sets" and replacement = "builtins" and 
    majorVersion = 2 and minorVersion = 6
  ) or (
    moduleName = "buildtools" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "cfmfile" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 4
  ) or (
    moduleName = "macfs" and replacement = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    moduleName = "md5" and replacement = "hashlib" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    moduleName = "sha" and replacement = "hashlib" and 
    majorVersion = 2 and minorVersion = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param moduleName The name of the deprecated module
 * @return Formatted string indicating deprecation version
 */
string deprecation_message(string moduleName) {
  // Generate version-specific deprecation notice
  exists(int majorVersion, int minorVersion | 
    deprecated_module(moduleName, _, majorVersion, minorVersion)
  |
    result = "The " + moduleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement recommendation message for a deprecated module
 *
 * @param moduleName The name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement exists
 */
string replacement_message(string moduleName) {
  // Provide replacement guidance when available
  exists(string replacement | 
    deprecated_module(moduleName, replacement, _, _)
  |
    result = " Use " + replacement + " module instead." 
    and not replacement = "no replacement"
    or
    result = "" and replacement = "no replacement"
  )
}

// Identify deprecated module imports without ImportError handling
from ImportExpr importExpr, string moduleName, string replacement
where
  // Extract imported module name
  moduleName = importExpr.getName()
  and
  // Verify module is deprecated
  deprecated_module(moduleName, replacement, _, _)
  and
  // Exclude imports wrapped in ImportError handling
  not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler()
    and exceptHandler.getType().pointsTo(ClassValue::importError())
    and exceptHandler.containsInScope(importExpr)
  )
select importExpr, 
       deprecation_message(moduleName) + replacement_message(moduleName)