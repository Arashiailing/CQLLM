/**
 * @name Import of deprecated module
 * @description Identifies imports of Python modules that have been deprecated in specific versions
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

// Import Python library for analyzing Python source code
import python

/**
 * Determines if a module was deprecated in a specific Python version
 * and provides the recommended replacement module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @param recommendedReplacement The recommended replacement module or "no replacement"
 * @param deprecatedMajor The major version number of Python where the module was deprecated
 * @param deprecatedMinor The minor version number of Python where the module was deprecated
 * @return True if the module was deprecated in the specified version
 */
predicate is_module_deprecated(string deprecatedModuleName, string recommendedReplacement, int deprecatedMajor, int deprecatedMinor) {
  // Modules deprecated in Python 1.x
  (
    deprecatedModuleName = "posixfile" and recommendedReplacement = "fcntl" and deprecatedMajor = 1 and deprecatedMinor = 5
    or
    deprecatedModuleName = "pre" and recommendedReplacement = "re" and deprecatedMajor = 1 and deprecatedMinor = 5
  )
  or
  // Modules deprecated in Python 2.0-2.2
  (
    deprecatedModuleName = "whrandom" and recommendedReplacement = "random" and deprecatedMajor = 2 and deprecatedMinor = 1
    or
    deprecatedModuleName = "statcache" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 2
    or
    deprecatedModuleName = "mpz" and recommendedReplacement = "a third party" and deprecatedMajor = 2 and deprecatedMinor = 2
  )
  or
  // Modules deprecated in Python 2.3-2.4
  (
    deprecatedModuleName = "rfc822" and recommendedReplacement = "email" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "mimetools" and recommendedReplacement = "email" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "MimeWriter" and recommendedReplacement = "email" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "mimify" and recommendedReplacement = "email" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "xreadlines" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "rotor" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 4
  )
  or
  // Modules deprecated in Python 2.5-2.6
  (
    deprecatedModuleName = "gopherlib" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "rgbimgmodule" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "multifile" and recommendedReplacement = "email" and deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "sets" and recommendedReplacement = "builtins" and deprecatedMajor = 2 and deprecatedMinor = 6
  )
  or
  // Additional deprecated modules with various deprecation versions
  (
    deprecatedModuleName = "buildtools" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "cfmfile" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 4
    or
    deprecatedModuleName = "macfs" and recommendedReplacement = "no replacement" and deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "md5" and recommendedReplacement = "hashlib" and deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "sha" and recommendedReplacement = "hashlib" and deprecatedMajor = 2 and deprecatedMinor = 5
  )
}

/**
 * Constructs a deprecation warning message for a module
 *
 * @param moduleName The name of the deprecated module
 * @return A string describing when the module was deprecated
 */
string get_deprecation_message(string moduleName) {
  // Retrieve deprecation version and format warning message
  exists(int majorVersion, int minorVersion | 
    is_module_deprecated(moduleName, _, majorVersion, minorVersion)
  |
    result =
      "The " + moduleName + " module was deprecated in version " + 
      majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Constructs a replacement suggestion message for a deprecated module
 *
 * @param moduleName The name of the deprecated module
 * @return A string with replacement suggestion or empty string if no replacement
 */
string get_replacement_message(string moduleName) {
  // Check for replacement module and format suggestion accordingly
  exists(string replacement | 
    is_module_deprecated(moduleName, replacement, _, _)
  |
    (result = " Use " + replacement + " module instead." and 
     not replacement = "no replacement")
    or
    (result = "" and replacement = "no replacement")
  )
}

// Main query to identify imports of deprecated modules
from ImportExpr importStmt, string moduleName, string replacementModule
where
  // Extract the imported module name
  moduleName = importStmt.getName() and
  // Verify the module is deprecated
  is_module_deprecated(moduleName, replacementModule, _, _) and
  // Exclude imports properly handled with ImportError exception handling
  not exists(Try tryBlock, ExceptStmt exceptClause | 
    exceptClause = tryBlock.getAHandler() and
    exceptClause.getType().pointsTo(ClassValue::importError()) and
    exceptClause.containsInScope(importStmt)
  )
select importStmt, get_deprecation_message(moduleName) + get_replacement_message(moduleName)