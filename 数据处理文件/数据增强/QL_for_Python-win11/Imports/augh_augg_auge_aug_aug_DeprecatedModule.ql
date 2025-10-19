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
 * Determines if a module was deprecated in a specific Python version
 * and provides its recommended replacement
 *
 * @param deprecatedModuleName The name of the module being checked
 * @param replacementModule Recommended replacement module or "no replacement"
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string deprecatedModuleName, string replacementModule, 
                          int majorVersion, int minorVersion) {
  // Define deprecated modules with their replacements and deprecation versions
  (
    deprecatedModuleName = "posixfile" and replacementModule = "fcntl" and 
    majorVersion = 1 and minorVersion = 5
  ) or (
    deprecatedModuleName = "pre" and replacementModule = "re" and 
    majorVersion = 1 and minorVersion = 5
  ) or (
    deprecatedModuleName = "whrandom" and replacementModule = "random" and 
    majorVersion = 2 and minorVersion = 1
  ) or (
    deprecatedModuleName = "statcache" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 2
  ) or (
    deprecatedModuleName = "mpz" and replacementModule = "a third party" and 
    majorVersion = 2 and minorVersion = 2
  ) or (
    deprecatedModuleName = "rfc822" and replacementModule = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "mimetools" and replacementModule = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "MimeWriter" and replacementModule = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "mimify" and replacementModule = "email" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "xreadlines" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "buildtools" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "macfs" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 3
  ) or (
    deprecatedModuleName = "rotor" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 4
  ) or (
    deprecatedModuleName = "cfmfile" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 4
  ) or (
    deprecatedModuleName = "md5" and replacementModule = "hashlib" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    deprecatedModuleName = "sha" and replacementModule = "hashlib" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    deprecatedModuleName = "gopherlib" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    deprecatedModuleName = "rgbimgmodule" and replacementModule = "no replacement" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    deprecatedModuleName = "multifile" and replacementModule = "email" and 
    majorVersion = 2 and minorVersion = 5
  ) or (
    deprecatedModuleName = "sets" and replacementModule = "builtins" and 
    majorVersion = 2 and minorVersion = 6
  )
}

/**
 * Creates a deprecation warning message for a module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return Formatted string indicating deprecation version
 */
string deprecation_message(string deprecatedModuleName) {
  // Generate version-specific deprecation notice
  exists(int majorVersion, int minorVersion | 
    deprecated_module(deprecatedModuleName, _, majorVersion, minorVersion)
  |
    result = "The " + deprecatedModuleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Creates a replacement recommendation message for a deprecated module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement exists
 */
string replacement_message(string deprecatedModuleName) {
  // Provide replacement guidance when available
  exists(string replacementModule | 
    deprecated_module(deprecatedModuleName, replacementModule, _, _)
  |
    if replacementModule = "no replacement"
    then result = ""
    else result = " Use " + replacementModule + " module instead."
  )
}

// Identify deprecated module imports without ImportError handling
from ImportExpr importNode, string deprecatedModuleName, string replacementModule
where
  // Extract imported module name
  deprecatedModuleName = importNode.getName()
  and
  // Verify module is deprecated
  deprecated_module(deprecatedModuleName, replacementModule, _, _)
  and
  // Exclude imports wrapped in ImportError handling
  not exists(Try tryBlock, ExceptStmt exceptBlock | 
    exceptBlock = tryBlock.getAHandler()
    and exceptBlock.getType().pointsTo(ClassValue::importError())
    and exceptBlock.containsInScope(importNode)
  )
select importNode, 
       deprecation_message(deprecatedModuleName) + replacement_message(deprecatedModuleName)