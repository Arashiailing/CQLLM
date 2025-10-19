/**
 * @name Import of deprecated module
 * @description Detects imports of Python modules that have been deprecated in specific versions
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
 * 
 * @param moduleName The name of the deprecated module
 * @param replacementModule The recommended replacement module ("no replacement" if none)
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return True if the module was deprecated in the specified version
 */
predicate is_deprecated_module(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  // Define deprecated modules with their replacements and version information
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
 * Generates a deprecation warning message for a module
 * 
 * @param moduleName The name of the deprecated module
 * @return A string describing the deprecation version
 */
string get_deprecation_warning(string moduleName) {
  // Create version-specific deprecation message
  exists(int majorVersion, int minorVersion | 
    is_deprecated_module(moduleName, _, majorVersion, minorVersion) |
    result = "The " + moduleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates a replacement recommendation message
 * 
 * @param moduleName The name of the deprecated module
 * @return A string with replacement advice or empty if no replacement
 */
string get_replacement_advice(string moduleName) {
  // Provide replacement suggestion if available
  exists(string replacementModule | 
    is_deprecated_module(moduleName, replacementModule, _, _) |
    (result = " Use " + replacementModule + " module instead." and replacementModule != "no replacement")
    or
    (result = "" and replacementModule = "no replacement")
  )
}

// Identify deprecated module imports without ImportError handling
from ImportExpr importStatement, string moduleName, string replacementModule
where
  // Extract imported module name
  moduleName = importStatement.getName() and
  // Verify module is deprecated
  is_deprecated_module(moduleName, replacementModule, _, _) and
  // Ensure ImportError is not caught for this import
  not exists(Try tryBlock, ExceptStmt handler | 
    handler = tryBlock.getAHandler() and
    handler.getType().pointsTo(ClassValue::importError()) and
    handler.containsInScope(importStatement)
  )
select importStatement, 
       get_deprecation_warning(moduleName) + get_replacement_advice(moduleName)