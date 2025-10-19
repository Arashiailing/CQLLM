/**
 * @name Import of deprecated module
 * @description Import of a deprecated module
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

// Import the Python library for handling Python code queries
import python

/**
 * Determines if a module `moduleName` is deprecated in the specified Python version `majorVersion`.`minorVersion`,
 * and should be replaced with module `replacementModule` (or `replacementModule = "no replacement"`)
 *
 * @param moduleName The name of the module
 * @param replacementModule The name of the replacement module, or "no replacement" if none exists
 * @param majorVersion The major version number
 * @param minorVersion The minor version number
 * @return true if the module is deprecated in the specified version and has a replacement module
 */
predicate deprecated_module(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  // Check if the module is deprecated in a specific version and if there's a replacement module
  moduleName = "posixfile" and replacementModule = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "gopherlib" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "rgbimgmodule" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "pre" and replacementModule = "re" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "whrandom" and replacementModule = "random" and majorVersion = 2 and minorVersion = 1
  or
  moduleName = "rfc822" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimetools" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "MimeWriter" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimify" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "rotor" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "statcache" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "mpz" and replacementModule = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "xreadlines" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "multifile" and replacementModule = "email" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sets" and replacementModule = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  moduleName = "buildtools" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "cfmfile" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "macfs" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "md5" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sha" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates a deprecation information message for a module
 *
 * @param moduleName The name of the module
 * @return A string message containing the deprecation version information
 */
string get_deprecation_info(string moduleName) {
  // If the module is deprecated in any version, generate the appropriate message
  exists(int majorVersion, int minorVersion | deprecated_module(moduleName, _, majorVersion, minorVersion) |
    result =
      "The " + moduleName + " module was deprecated in version " + majorVersion.toString() + "." +
        minorVersion.toString() + "."
  )
}

/**
 * Generates a replacement suggestion message for a deprecated module
 *
 * @param moduleName The name of the module
 * @return A string message containing the replacement suggestion, or an empty string if no replacement exists
 */
string get_replacement_suggestion(string moduleName) {
  // If there's a replacement module, generate the appropriate suggestion message
  exists(string replacementModule | deprecated_module(moduleName, replacementModule, _, _) |
    result = " Use " + replacementModule + " module instead." and not replacementModule = "no replacement"
    or
    result = "" and replacementModule = "no replacement"
  )
}

// Select deprecated modules from import expressions and generate warning messages
from ImportExpr importExpr, string moduleName, string replacementModule
where
  // Get the name of the imported module
  moduleName = importExpr.getName() and
  // Check if the module is deprecated
  deprecated_module(moduleName, replacementModule, _, _) and
  // Ensure the import statement is not caught by a try-except block handling ImportError
  not exists(Try tryStmt, ExceptStmt exceptHandler |
    exceptHandler = tryStmt.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpr)
  )
select importExpr, get_deprecation_info(moduleName) + get_replacement_suggestion(moduleName)