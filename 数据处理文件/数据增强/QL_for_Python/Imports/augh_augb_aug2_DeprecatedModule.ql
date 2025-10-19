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
 * Checks if a module was deprecated in a specific Python version
 * and provides its recommended replacement
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @param suggestedReplacement Recommended replacement module or "no replacement"
 * @param deprecatedMajor Major version where module was deprecated
 * @param deprecatedMinor Minor version where module was deprecated
 * @return True if module was deprecated in specified version
 */
predicate is_module_deprecated(string deprecatedModuleName, string suggestedReplacement, 
                              int deprecatedMajor, int deprecatedMinor) {
  // Python 1.x deprecated modules
  (
    deprecatedModuleName = "posixfile" and suggestedReplacement = "fcntl" and 
    deprecatedMajor = 1 and deprecatedMinor = 5
    or
    deprecatedModuleName = "pre" and suggestedReplacement = "re" and 
    deprecatedMajor = 1 and deprecatedMinor = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModuleName = "whrandom" and suggestedReplacement = "random" and 
    deprecatedMajor = 2 and deprecatedMinor = 1
    or
    deprecatedModuleName = "statcache" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 2
    or
    deprecatedModuleName = "mpz" and suggestedReplacement = "a third party" and 
    deprecatedMajor = 2 and deprecatedMinor = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModuleName = "rfc822" and suggestedReplacement = "email" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "mimetools" and suggestedReplacement = "email" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "MimeWriter" and suggestedReplacement = "email" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "mimify" and suggestedReplacement = "email" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "xreadlines" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "rotor" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModuleName = "gopherlib" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "rgbimgmodule" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "multifile" and suggestedReplacement = "email" and 
    deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "sets" and suggestedReplacement = "builtins" and 
    deprecatedMajor = 2 and deprecatedMinor = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModuleName = "buildtools" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "cfmfile" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 4
    or
    deprecatedModuleName = "macfs" and suggestedReplacement = "no replacement" and 
    deprecatedMajor = 2 and deprecatedMinor = 3
    or
    deprecatedModuleName = "md5" and suggestedReplacement = "hashlib" and 
    deprecatedMajor = 2 and deprecatedMinor = 5
    or
    deprecatedModuleName = "sha" and suggestedReplacement = "hashlib" and 
    deprecatedMajor = 2 and deprecatedMinor = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return String describing deprecation version
 */
string get_deprecation_warning(string deprecatedModuleName) {
  exists(int deprecatedMajor, int deprecatedMinor | 
    is_module_deprecated(deprecatedModuleName, _, deprecatedMajor, deprecatedMinor)
  |
    result = "The " + deprecatedModuleName + " module was deprecated in Python " + 
             deprecatedMajor.toString() + "." + deprecatedMinor.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return Replacement suggestion or empty string
 */
string get_replacement_suggestion(string deprecatedModuleName) {
  exists(string suggestedReplacement | 
    is_module_deprecated(deprecatedModuleName, suggestedReplacement, _, _)
  |
    (result = " Consider using " + suggestedReplacement + " instead." and 
     not suggestedReplacement = "no replacement")
    or
    (result = "" and suggestedReplacement = "no replacement")
  )
}

/**
 * Verifies if import statement has ImportError exception handling
 *
 * @param importExpr Import expression to check
 * @return True if ImportError is properly handled
 */
predicate is_import_error_handled(ImportExpr importExpr) {
  exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpr)
  )
}

// Main query to detect deprecated module imports
from ImportExpr importStmt, string moduleName, string replacementModule
where
  moduleName = importStmt.getName() and
  is_module_deprecated(moduleName, replacementModule, _, _) and
  not is_import_error_handled(importStmt)
select importStmt, get_deprecation_warning(moduleName) + get_replacement_suggestion(moduleName)