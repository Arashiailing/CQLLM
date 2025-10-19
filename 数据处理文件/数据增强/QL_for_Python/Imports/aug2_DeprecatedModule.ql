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
 * @param moduleName The name of the deprecated module
 * @param replacementModule The recommended replacement module or "no replacement"
 * @param major The major version number of Python where the module was deprecated
 * @param minor The minor version number of Python where the module was deprecated
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleName, string replacementModule, int major, int minor) {
  // Modules deprecated in Python 1.x
  (
    moduleName = "posixfile" and replacementModule = "fcntl" and major = 1 and minor = 5
    or
    moduleName = "pre" and replacementModule = "re" and major = 1 and minor = 5
  )
  or
  // Modules deprecated in Python 2.0-2.2
  (
    moduleName = "whrandom" and replacementModule = "random" and major = 2 and minor = 1
    or
    moduleName = "statcache" and replacementModule = "no replacement" and major = 2 and minor = 2
    or
    moduleName = "mpz" and replacementModule = "a third party" and major = 2 and minor = 2
  )
  or
  // Modules deprecated in Python 2.3-2.4
  (
    moduleName = "rfc822" and replacementModule = "email" and major = 2 and minor = 3
    or
    moduleName = "mimetools" and replacementModule = "email" and major = 2 and minor = 3
    or
    moduleName = "MimeWriter" and replacementModule = "email" and major = 2 and minor = 3
    or
    moduleName = "mimify" and replacementModule = "email" and major = 2 and minor = 3
    or
    moduleName = "xreadlines" and replacementModule = "no replacement" and major = 2 and minor = 3
    or
    moduleName = "rotor" and replacementModule = "no replacement" and major = 2 and minor = 4
  )
  or
  // Modules deprecated in Python 2.5-2.6
  (
    moduleName = "gopherlib" and replacementModule = "no replacement" and major = 2 and minor = 5
    or
    moduleName = "rgbimgmodule" and replacementModule = "no replacement" and major = 2 and minor = 5
    or
    moduleName = "multifile" and replacementModule = "email" and major = 2 and minor = 5
    or
    moduleName = "sets" and replacementModule = "builtins" and major = 2 and minor = 6
  )
  or
  // Other deprecated modules
  (
    moduleName = "buildtools" and replacementModule = "no replacement" and major = 2 and minor = 3
    or
    moduleName = "cfmfile" and replacementModule = "no replacement" and major = 2 and minor = 4
    or
    moduleName = "macfs" and replacementModule = "no replacement" and major = 2 and minor = 3
    or
    moduleName = "md5" and replacementModule = "hashlib" and major = 2 and minor = 5
    or
    moduleName = "sha" and replacementModule = "hashlib" and major = 2 and minor = 5
  )
}

/**
 * Constructs a deprecation warning message for a module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return A string describing when the module was deprecated
 */
string deprecation_message(string deprecatedModuleName) {
  // Find the version where the module was deprecated and format the message
  exists(int majorVersion, int minorVersion | 
    deprecated_module(deprecatedModuleName, _, majorVersion, minorVersion)
  |
    result =
      "The " + deprecatedModuleName + " module was deprecated in version " + 
      majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Constructs a replacement suggestion message for a deprecated module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return A string with replacement suggestion or empty string if no replacement
 */
string replacement_message(string deprecatedModuleName) {
  // Check if there's a replacement module and format the message accordingly
  exists(string replacementModule | 
    deprecated_module(deprecatedModuleName, replacementModule, _, _)
  |
    (result = " Use " + replacementModule + " module instead." and 
     not replacementModule = "no replacement")
    or
    (result = "" and replacementModule = "no replacement")
  )
}

// Main query to find imports of deprecated modules
from ImportExpr importExpr, string moduleName, string replacementModule
where
  // Get the name of the imported module
  moduleName = importExpr.getName() and
  // Verify the module is deprecated
  deprecated_module(moduleName, replacementModule, _, _) and
  // Exclude imports that are properly handled with ImportError exception handling
  not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpr)
  )
select importExpr, deprecation_message(moduleName) + replacement_message(moduleName)