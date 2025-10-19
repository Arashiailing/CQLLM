/**
 * @name Import of deprecated module
 * @description Identifies Python imports of modules deprecated in specific versions
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
 * Checks if a module was deprecated in a specific Python version
 *
 * @param deprecatedModName Name of the deprecated module
 * @param replacementMod Recommended replacement module or "no replacement"
 * @param majorVer Major Python version where deprecation occurred
 * @param minorVer Minor Python version where deprecation occurred
 * @return True if module was deprecated in specified version
 */
predicate isDeprecatedModule(string deprecatedModName, string replacementMod, int majorVer, int minorVer) {
  // Python 1.x deprecated modules
  (
    deprecatedModName = "posixfile" and replacementMod = "fcntl" and majorVer = 1 and minorVer = 5
    or
    deprecatedModName = "pre" and replacementMod = "re" and majorVer = 1 and minorVer = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModName = "whrandom" and replacementMod = "random" and majorVer = 2 and minorVer = 1
    or
    deprecatedModName = "statcache" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 2
    or
    deprecatedModName = "mpz" and replacementMod = "a third party" and majorVer = 2 and minorVer = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModName = "rfc822" and replacementMod = "email" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "mimetools" and replacementMod = "email" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "MimeWriter" and replacementMod = "email" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "mimify" and replacementMod = "email" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "xreadlines" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "rotor" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModName = "gopherlib" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "rgbimgmodule" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "multifile" and replacementMod = "email" and majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "sets" and replacementMod = "builtins" and majorVer = 2 and minorVer = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModName = "buildtools" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "cfmfile" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 4
    or
    deprecatedModName = "macfs" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "md5" and replacementMod = "hashlib" and majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "sha" and replacementMod = "hashlib" and majorVer = 2 and minorVer = 5
  )
}

/**
 * Creates deprecation warning message for a module
 *
 * @param deprecatedModName Name of the deprecated module
 * @return Formatted warning message with deprecation version
 */
string getDeprecationWarning(string deprecatedModName) {
  exists(int majorVer, int minorVer | 
    isDeprecatedModule(deprecatedModName, _, majorVer, minorVer)
  |
    result =
      "Module " + deprecatedModName + " was deprecated in Python " + 
      majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Provides replacement suggestion for deprecated module
 *
 * @param deprecatedModName Name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement
 */
string getReplacementSuggestion(string deprecatedModName) {
  exists(string replacementMod | 
    isDeprecatedModule(deprecatedModName, replacementMod, _, _)
  |
    (result = " Consider using " + replacementMod + " instead." and 
     not replacementMod = "no replacement")
    or
    (result = "" and replacementMod = "no replacement")
  )
}

/**
 * Detects ImportError exception handling for an import
 *
 * @param importExpr Import expression to evaluate
 * @return True if ImportError exception handling is present
 */
predicate hasImportErrorHandling(ImportExpr importExpr) {
  exists(Try tryStmt, ExceptStmt exceptStmt | 
    exceptStmt = tryStmt.getAHandler() and
    exceptStmt.getType().pointsTo(ClassValue::importError()) and
    exceptStmt.containsInScope(importExpr)
  )
}

// Main query: Find deprecated module imports without error handling
from ImportExpr importExpr, string deprecatedModName, string replacementMod
where
  deprecatedModName = importExpr.getName() and
  isDeprecatedModule(deprecatedModName, replacementMod, _, _) and
  not hasImportErrorHandling(importExpr)
select importExpr, getDeprecationWarning(deprecatedModName) + getReplacementSuggestion(deprecatedModName)