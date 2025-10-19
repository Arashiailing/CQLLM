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
 * @param importedModuleName The name of the module being checked
 * @param recommendedReplacement Recommended replacement module or "no replacement"
 * @param deprecationMajorVersion Major version number where deprecation occurred
 * @param deprecationMinorVersion Minor version number where deprecation occurred
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string importedModuleName, string recommendedReplacement, 
                          int deprecationMajorVersion, int deprecationMinorVersion) {
  // Define deprecated modules with their replacements and deprecation versions
  (
    importedModuleName = "posixfile" and recommendedReplacement = "fcntl" and 
    deprecationMajorVersion = 1 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "pre" and recommendedReplacement = "re" and 
    deprecationMajorVersion = 1 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "whrandom" and recommendedReplacement = "random" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 1
  ) or (
    importedModuleName = "statcache" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 2
  ) or (
    importedModuleName = "mpz" and recommendedReplacement = "a third party" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 2
  ) or (
    importedModuleName = "rfc822" and recommendedReplacement = "email" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "mimetools" and recommendedReplacement = "email" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "MimeWriter" and recommendedReplacement = "email" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "mimify" and recommendedReplacement = "email" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "xreadlines" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "buildtools" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "macfs" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 3
  ) or (
    importedModuleName = "rotor" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 4
  ) or (
    importedModuleName = "cfmfile" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 4
  ) or (
    importedModuleName = "md5" and recommendedReplacement = "hashlib" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "sha" and recommendedReplacement = "hashlib" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "gopherlib" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "rgbimgmodule" and recommendedReplacement = "no replacement" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "multifile" and recommendedReplacement = "email" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 5
  ) or (
    importedModuleName = "sets" and recommendedReplacement = "builtins" and 
    deprecationMajorVersion = 2 and deprecationMinorVersion = 6
  )
}

/**
 * Creates a deprecation warning message for a module
 *
 * @param importedModuleName The name of the deprecated module
 * @return Formatted string indicating deprecation version
 */
string deprecation_message(string importedModuleName) {
  // Generate version-specific deprecation notice
  exists(int deprecationMajorVersion, int deprecationMinorVersion | 
    deprecated_module(importedModuleName, _, deprecationMajorVersion, deprecationMinorVersion)
  |
    result = "The " + importedModuleName + " module was deprecated in version " + 
             deprecationMajorVersion.toString() + "." + deprecationMinorVersion.toString() + "."
  )
}

/**
 * Creates a replacement recommendation message for a deprecated module
 *
 * @param importedModuleName The name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement exists
 */
string replacement_message(string importedModuleName) {
  // Provide replacement guidance when available
  exists(string recommendedReplacement | 
    deprecated_module(importedModuleName, recommendedReplacement, _, _)
  |
    if recommendedReplacement = "no replacement"
    then result = ""
    else result = " Use " + recommendedReplacement + " module instead."
  )
}

// Identify deprecated module imports without ImportError handling
from ImportExpr importStatement, string importedModuleName, string recommendedReplacement
where
  // Extract imported module name
  importedModuleName = importStatement.getName()
  and
  // Verify module is deprecated
  deprecated_module(importedModuleName, recommendedReplacement, _, _)
  and
  // Exclude imports wrapped in ImportError handling
  not exists(Try tryStatement, ExceptStmt exceptionHandler | 
    exceptionHandler = tryStatement.getAHandler()
    and exceptionHandler.getType().pointsTo(ClassValue::importError())
    and exceptionHandler.containsInScope(importStatement)
  )
select importStatement, 
       deprecation_message(importedModuleName) + replacement_message(importedModuleName)