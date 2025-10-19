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

// Import Python analysis library for code processing
import python

/**
 * Determines if a module was deprecated in a specific Python version
 * and provides its replacement recommendation
 *
 * @param moduleToCheck The name of the module being checked
 * @param recommendedReplacement Recommended replacement module or "no replacement"
 * @param deprecatedMajorVersion Major version number where deprecation occurred
 * @param deprecatedMinorVersion Minor version number where deprecation occurred
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleToCheck, string recommendedReplacement, 
                          int deprecatedMajorVersion, int deprecatedMinorVersion) {
  // Define deprecated modules with their replacements and deprecation versions
  (
    moduleToCheck = "posixfile" and recommendedReplacement = "fcntl" and 
    deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "gopherlib" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "rgbimgmodule" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "pre" and recommendedReplacement = "re" and 
    deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "whrandom" and recommendedReplacement = "random" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 1
  ) or (
    moduleToCheck = "rfc822" and recommendedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "mimetools" and recommendedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "MimeWriter" and recommendedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "mimify" and recommendedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "rotor" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
  ) or (
    moduleToCheck = "statcache" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
  ) or (
    moduleToCheck = "mpz" and recommendedReplacement = "a third party" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
  ) or (
    moduleToCheck = "xreadlines" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "multifile" and recommendedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "sets" and recommendedReplacement = "builtins" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 6
  ) or (
    moduleToCheck = "buildtools" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "cfmfile" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
  ) or (
    moduleToCheck = "macfs" and recommendedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  ) or (
    moduleToCheck = "md5" and recommendedReplacement = "hashlib" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  ) or (
    moduleToCheck = "sha" and recommendedReplacement = "hashlib" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param moduleToCheck The name of the deprecated module
 * @return Formatted string indicating deprecation version
 */
string deprecation_message(string moduleToCheck) {
  // Generate version-specific deprecation notice
  exists(int deprecatedMajorVersion, int deprecatedMinorVersion | 
    deprecated_module(moduleToCheck, _, deprecatedMajorVersion, deprecatedMinorVersion)
  |
    result = "The " + moduleToCheck + " module was deprecated in version " + 
             deprecatedMajorVersion.toString() + "." + deprecatedMinorVersion.toString() + "."
  )
}

/**
 * Generates replacement recommendation message for a deprecated module
 *
 * @param moduleToCheck The name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement exists
 */
string replacement_message(string moduleToCheck) {
  // Provide replacement guidance when available
  exists(string recommendedReplacement | 
    deprecated_module(moduleToCheck, recommendedReplacement, _, _)
  |
    result = " Use " + recommendedReplacement + " module instead." 
    and not recommendedReplacement = "no replacement"
    or
    result = "" and recommendedReplacement = "no replacement"
  )
}

// Identify deprecated module imports without ImportError handling
from ImportExpr importNode, string moduleToCheck, string recommendedReplacement
where
  // Extract imported module name
  moduleToCheck = importNode.getName() and
  // Verify module is deprecated
  deprecated_module(moduleToCheck, recommendedReplacement, _, _) and
  // Exclude imports wrapped in ImportError handling
  not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importNode)
  )
select importNode, 
       deprecation_message(moduleToCheck) + replacement_message(moduleToCheck)