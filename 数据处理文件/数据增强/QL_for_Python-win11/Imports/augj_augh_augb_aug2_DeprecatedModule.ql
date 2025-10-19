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
 * Determines if a module was deprecated in a specific Python version
 * and provides its recommended replacement
 *
 * @param deprecatedModName Name of the deprecated module
 * @param replacementMod Recommended replacement module or "no replacement"
 * @param majorVer Major version where module was deprecated
 * @param minorVer Minor version where module was deprecated
 * @return True if module was deprecated in specified version
 */
predicate is_module_deprecated(string deprecatedModName, string replacementMod, 
                              int majorVer, int minorVer) {
  // Python 1.x deprecated modules
  (
    deprecatedModName = "posixfile" and replacementMod = "fcntl" and 
    majorVer = 1 and minorVer = 5
    or
    deprecatedModName = "pre" and replacementMod = "re" and 
    majorVer = 1 and minorVer = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModName = "whrandom" and replacementMod = "random" and 
    majorVer = 2 and minorVer = 1
    or
    deprecatedModName = "statcache" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 2
    or
    deprecatedModName = "mpz" and replacementMod = "a third party" and 
    majorVer = 2 and minorVer = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModName = "rfc822" and replacementMod = "email" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "mimetools" and replacementMod = "email" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "MimeWriter" and replacementMod = "email" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "mimify" and replacementMod = "email" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "xreadlines" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "rotor" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModName = "gopherlib" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "rgbimgmodule" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "multifile" and replacementMod = "email" and 
    majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "sets" and replacementMod = "builtins" and 
    majorVer = 2 and minorVer = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModName = "buildtools" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "cfmfile" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 4
    or
    deprecatedModName = "macfs" and replacementMod = "no replacement" and 
    majorVer = 2 and minorVer = 3
    or
    deprecatedModName = "md5" and replacementMod = "hashlib" and 
    majorVer = 2 and minorVer = 5
    or
    deprecatedModName = "sha" and replacementMod = "hashlib" and 
    majorVer = 2 and minorVer = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param deprecatedModName Name of the deprecated module
 * @return String describing deprecation version
 */
string get_deprecation_warning(string deprecatedModName) {
  exists(int majorVer, int minorVer | 
    is_module_deprecated(deprecatedModName, _, majorVer, minorVer)
  |
    result = "The " + deprecatedModName + " module was deprecated in Python " + 
             majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 *
 * @param deprecatedModName Name of the deprecated module
 * @return Replacement suggestion or empty string
 */
string get_replacement_suggestion(string deprecatedModName) {
  exists(string replacementMod | 
    is_module_deprecated(deprecatedModName, replacementMod, _, _)
  |
    (result = " Consider using " + replacementMod + " instead." and 
     not replacementMod = "no replacement")
    or
    (result = "" and replacementMod = "no replacement")
  )
}

/**
 * Verifies if import statement has ImportError exception handling
 *
 * @param importNode Import expression to check
 * @return True if ImportError is properly handled
 */
predicate is_import_error_handled(ImportExpr importNode) {
  exists(Try tryNode, ExceptStmt exceptNode | 
    exceptNode = tryNode.getAHandler() and
    exceptNode.getType().pointsTo(ClassValue::importError()) and
    exceptNode.containsInScope(importNode)
  )
}

// Main query to detect deprecated module imports
from ImportExpr importStmt, string modName, string replacementMod
where
  modName = importStmt.getName() and
  is_module_deprecated(modName, replacementMod, _, _) and
  not is_import_error_handled(importStmt)
select importStmt, get_deprecation_warning(modName) + get_replacement_suggestion(modName)