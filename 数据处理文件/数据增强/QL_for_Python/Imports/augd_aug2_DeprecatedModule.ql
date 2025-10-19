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
 * @param modName The name of the deprecated module
 * @param replModule The recommended replacement module or "no replacement"
 * @param majorVer The major version number of Python where the module was deprecated
 * @param minorVer The minor version number of Python where the module was deprecated
 * @return True if the module was deprecated in the specified version
 */
predicate deprecated_module(string modName, string replModule, int majorVer, int minorVer) {
  // Python 1.x deprecated modules
  (
    modName = "posixfile" and replModule = "fcntl" and majorVer = 1 and minorVer = 5
    or
    modName = "pre" and replModule = "re" and majorVer = 1 and minorVer = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    modName = "whrandom" and replModule = "random" and majorVer = 2 and minorVer = 1
    or
    modName = "statcache" and replModule = "no replacement" and majorVer = 2 and minorVer = 2
    or
    modName = "mpz" and replModule = "a third party" and majorVer = 2 and minorVer = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    modName = "rfc822" and replModule = "email" and majorVer = 2 and minorVer = 3
    or
    modName = "mimetools" and replModule = "email" and majorVer = 2 and minorVer = 3
    or
    modName = "MimeWriter" and replModule = "email" and majorVer = 2 and minorVer = 3
    or
    modName = "mimify" and replModule = "email" and majorVer = 2 and minorVer = 3
    or
    modName = "xreadlines" and replModule = "no replacement" and majorVer = 2 and minorVer = 3
    or
    modName = "rotor" and replModule = "no replacement" and majorVer = 2 and minorVer = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    modName = "gopherlib" and replModule = "no replacement" and majorVer = 2 and minorVer = 5
    or
    modName = "rgbimgmodule" and replModule = "no replacement" and majorVer = 2 and minorVer = 5
    or
    modName = "multifile" and replModule = "email" and majorVer = 2 and minorVer = 5
    or
    modName = "sets" and replModule = "builtins" and majorVer = 2 and minorVer = 6
  )
  or
  // Additional deprecated modules
  (
    modName = "buildtools" and replModule = "no replacement" and majorVer = 2 and minorVer = 3
    or
    modName = "cfmfile" and replModule = "no replacement" and majorVer = 2 and minorVer = 4
    or
    modName = "macfs" and replModule = "no replacement" and majorVer = 2 and minorVer = 3
    or
    modName = "md5" and replModule = "hashlib" and majorVer = 2 and minorVer = 5
    or
    modName = "sha" and replModule = "hashlib" and majorVer = 2 and minorVer = 5
  )
}

/**
 * Constructs a deprecation warning message for a module
 *
 * @param deprecatedModName The name of the deprecated module
 * @return A string describing when the module was deprecated
 */
string deprecation_message(string deprecatedModName) {
  // Find deprecation version and format warning message
  exists(int majorVer, int minorVer | 
    deprecated_module(deprecatedModName, _, majorVer, minorVer)
  |
    result =
      "The " + deprecatedModName + " module was deprecated in version " + 
      majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Constructs a replacement suggestion message for a deprecated module
 *
 * @param deprecatedModName The name of the deprecated module
 * @return A string with replacement suggestion or empty string if no replacement
 */
string replacement_message(string deprecatedModName) {
  // Generate replacement suggestion based on available alternatives
  exists(string replModule | 
    deprecated_module(deprecatedModName, replModule, _, _)
  |
    (result = " Use " + replModule + " module instead." and 
     not replModule = "no replacement")
    or
    (result = "" and replModule = "no replacement")
  )
}

// Main query to detect imports of deprecated modules
from ImportExpr impExpr, string modName, string replModule
where
  // Extract imported module name
  modName = impExpr.getName()
  // Verify module is deprecated
  and deprecated_module(modName, replModule, _, _)
  // Exclude properly handled imports with ImportError exception
  and not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler()
    and exceptHandler.getType().pointsTo(ClassValue::importError())
    and exceptHandler.containsInScope(impExpr)
  )
select impExpr, deprecation_message(modName) + replacement_message(modName)