/**
 * @name Import of deprecated module
 * @description Detects Python imports of modules deprecated in specific versions
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
 * Identifies modules deprecated in specific Python versions
 * with recommended replacement information
 *
 * @param deprecatedModName The deprecated module name
 * @param suggestedReplacement Recommended replacement or "no replacement"
 * @param majorVersion Major version where module was deprecated
 * @param minorVersion Minor version where module was deprecated
 * @return True if module was deprecated in specified version
 */
predicate module_deprecation_info(string deprecatedModName, string suggestedReplacement, int majorVersion, int minorVersion) {
  // Python 1.x deprecated modules
  (
    deprecatedModName = "posixfile" and suggestedReplacement = "fcntl" and majorVersion = 1 and minorVersion = 5
    or
    deprecatedModName = "pre" and suggestedReplacement = "re" and majorVersion = 1 and minorVersion = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModName = "whrandom" and suggestedReplacement = "random" and majorVersion = 2 and minorVersion = 1
    or
    deprecatedModName = "statcache" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 2
    or
    deprecatedModName = "mpz" and suggestedReplacement = "a third party" and majorVersion = 2 and minorVersion = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModName = "rfc822" and suggestedReplacement = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "mimetools" and suggestedReplacement = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "MimeWriter" and suggestedReplacement = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "mimify" and suggestedReplacement = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "xreadlines" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "rotor" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModName = "gopherlib" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModName = "rgbimgmodule" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModName = "multifile" and suggestedReplacement = "email" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModName = "sets" and suggestedReplacement = "builtins" and majorVersion = 2 and minorVersion = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModName = "buildtools" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "cfmfile" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 4
    or
    deprecatedModName = "macfs" and suggestedReplacement = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModName = "md5" and suggestedReplacement = "hashlib" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModName = "sha" and suggestedReplacement = "hashlib" and majorVersion = 2 and minorVersion = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param deprecatedModName The deprecated module name
 * @return Formatted deprecation warning string
 */
string deprecation_message(string deprecatedModName) {
  exists(int majorVersion, int minorVersion | 
    module_deprecation_info(deprecatedModName, _, majorVersion, minorVersion)
  |
    result = "Module '" + deprecatedModName + "' was deprecated in Python " + 
             majorVersion.toString() + "." + minorVersion.toString()
  )
}

/**
 * Generates replacement suggestion for deprecated module
 *
 * @param deprecatedModName The deprecated module name
 * @return Replacement suggestion or empty string
 */
string replacement_message(string deprecatedModName) {
  exists(string suggestedReplacement | 
    module_deprecation_info(deprecatedModName, suggestedReplacement, _, _)
  |
    (result = " Consider using '" + suggestedReplacement + "' instead." and 
     not suggestedReplacement = "no replacement")
    or
    (result = "" and suggestedReplacement = "no replacement")
  )
}

/**
 * Checks if import statement has ImportError exception handling
 *
 * @param importExpression The import statement to verify
 * @return True if ImportError exception handling exists
 */
predicate has_import_error_handling(ImportExpr importExpression) {
  exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpression)
  )
}

// Main query to identify deprecated module imports
from ImportExpr importExpression, string deprecatedModName, string suggestedReplacement
where
  deprecatedModName = importExpression.getName() and
  module_deprecation_info(deprecatedModName, suggestedReplacement, _, _) and
  not has_import_error_handling(importExpression)
select importExpression, deprecation_message(deprecatedModName) + replacement_message(deprecatedModName)