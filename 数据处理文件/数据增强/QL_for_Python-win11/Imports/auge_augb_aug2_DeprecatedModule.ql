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

// Core Python analysis library import
import python

/**
 * Identifies deprecated modules with version-specific information
 *
 * @param modName Name of the deprecated module
 * @param replacement Recommended replacement module or "no replacement"
 * @param majVer Major Python version where deprecation occurred
 * @param minVer Minor Python version where deprecation occurred
 * @return True if module was deprecated in specified version
 */
predicate module_deprecated(string modName, string replacement, int majVer, int minVer) {
  // Python 1.x deprecations
  (
    modName = "posixfile" and replacement = "fcntl" and majVer = 1 and minVer = 5
    or
    modName = "pre" and replacement = "re" and majVer = 1 and minVer = 5
  )
  or
  // Python 2.0-2.2 deprecations
  (
    modName = "whrandom" and replacement = "random" and majVer = 2 and minVer = 1
    or
    modName = "statcache" and replacement = "no replacement" and majVer = 2 and minVer = 2
    or
    modName = "mpz" and replacement = "a third party" and majVer = 2 and minVer = 2
  )
  or
  // Python 2.3-2.4 deprecations
  (
    modName = "rfc822" and replacement = "email" and majVer = 2 and minVer = 3
    or
    modName = "mimetools" and replacement = "email" and majVer = 2 and minVer = 3
    or
    modName = "MimeWriter" and replacement = "email" and majVer = 2 and minVer = 3
    or
    modName = "mimify" and replacement = "email" and majVer = 2 and minVer = 3
    or
    modName = "xreadlines" and replacement = "no replacement" and majVer = 2 and minVer = 3
    or
    modName = "rotor" and replacement = "no replacement" and majVer = 2 and minVer = 4
  )
  or
  // Python 2.5-2.6 deprecations
  (
    modName = "gopherlib" and replacement = "no replacement" and majVer = 2 and minVer = 5
    or
    modName = "rgbimgmodule" and replacement = "no replacement" and majVer = 2 and minVer = 5
    or
    modName = "multifile" and replacement = "email" and majVer = 2 and minVer = 5
    or
    modName = "sets" and replacement = "builtins" and majVer = 2 and minVer = 6
  )
  or
  // Additional deprecated modules
  (
    modName = "buildtools" and replacement = "no replacement" and majVer = 2 and minVer = 3
    or
    modName = "cfmfile" and replacement = "no replacement" and majVer = 2 and minVer = 4
    or
    modName = "macfs" and replacement = "no replacement" and majVer = 2 and minVer = 3
    or
    modName = "md5" and replacement = "hashlib" and majVer = 2 and minVer = 5
    or
    modName = "sha" and replacement = "hashlib" and majVer = 2 and minVer = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param modName Name of the deprecated module
 * @return Formatted warning message with deprecation version
 */
string deprecation_message(string modName) {
  exists(int majVer, int minVer | 
    module_deprecated(modName, _, majVer, minVer)
  |
    result =
      "The " + modName + " module was deprecated in Python " + 
      majVer.toString() + "." + minVer.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 *
 * @param modName Name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement
 */
string replacement_message(string modName) {
  exists(string replMod | 
    module_deprecated(modName, replMod, _, _)
  |
    (result = " Consider using " + replMod + " instead." and 
     not replMod = "no replacement")
    or
    (result = "" and replMod = "no replacement")
  )
}

/**
 * Checks if ImportError exception handling exists for import
 *
 * @param importExpr Import expression to evaluate
 * @return True if ImportError exception handling is present
 */
predicate has_import_error_handling(ImportExpr importExpr) {
  exists(Try tryBlock, ExceptStmt exceptClause | 
    exceptClause = tryBlock.getAHandler() and
    exceptClause.getType().pointsTo(ClassValue::importError()) and
    exceptClause.containsInScope(importExpr)
  )
}

// Main query: Find unhandled deprecated module imports
from ImportExpr importStmt, string moduleName, string replacementModule
where
  moduleName = importStmt.getName() and
  module_deprecated(moduleName, replacementModule, _, _) and
  not has_import_error_handling(importStmt)
select importStmt, deprecation_message(moduleName) + replacement_message(moduleName)