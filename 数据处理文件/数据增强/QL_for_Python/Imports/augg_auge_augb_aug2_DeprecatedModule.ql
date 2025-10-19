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
 * Determines if a module was deprecated in a specific Python version
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @param replacementModule Recommended replacement module or "no replacement"
 * @param majorVersion Major Python version where deprecation occurred
 * @param minorVersion Minor Python version where deprecation occurred
 * @return True if module was deprecated in specified version
 */
predicate is_module_deprecated(string deprecatedModuleName, string replacementModule, int majorVersion, int minorVersion) {
  // Python 1.x deprecated modules
  (
    deprecatedModuleName = "posixfile" and replacementModule = "fcntl" and majorVersion = 1 and minorVersion = 5
    or
    deprecatedModuleName = "pre" and replacementModule = "re" and majorVersion = 1 and minorVersion = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModuleName = "whrandom" and replacementModule = "random" and majorVersion = 2 and minorVersion = 1
    or
    deprecatedModuleName = "statcache" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 2
    or
    deprecatedModuleName = "mpz" and replacementModule = "a third party" and majorVersion = 2 and minorVersion = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModuleName = "rfc822" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "mimetools" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "MimeWriter" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "mimify" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "xreadlines" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "rotor" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModuleName = "gopherlib" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModuleName = "rgbimgmodule" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModuleName = "multifile" and replacementModule = "email" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModuleName = "sets" and replacementModule = "builtins" and majorVersion = 2 and minorVersion = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModuleName = "buildtools" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "cfmfile" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
    or
    deprecatedModuleName = "macfs" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
    or
    deprecatedModuleName = "md5" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
    or
    deprecatedModuleName = "sha" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return Formatted warning message with deprecation version
 */
string get_deprecation_warning(string deprecatedModuleName) {
  exists(int majorVersion, int minorVersion | 
    is_module_deprecated(deprecatedModuleName, _, majorVersion, minorVersion)
  |
    result =
      "The " + deprecatedModuleName + " module was deprecated in Python " + 
      majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement
 */
string get_replacement_suggestion(string deprecatedModuleName) {
  exists(string replacementModule | 
    is_module_deprecated(deprecatedModuleName, replacementModule, _, _)
  |
    (result = " Consider using " + replacementModule + " instead." and 
     not replacementModule = "no replacement")
    or
    (result = "" and replacementModule = "no replacement")
  )
}

/**
 * Checks if ImportError exception handling exists for import
 *
 * @param importExpression Import expression to evaluate
 * @return True if ImportError exception handling is present
 */
predicate has_import_error_handling(ImportExpr importExpression) {
  exists(Try tryStatement, ExceptStmt exceptStatement | 
    exceptStatement = tryStatement.getAHandler() and
    exceptStatement.getType().pointsTo(ClassValue::importError()) and
    exceptStatement.containsInScope(importExpression)
  )
}

// Main query: Find unhandled deprecated module imports
from ImportExpr importStatement, string deprecatedModuleName, string replacementSuggestion
where
  deprecatedModuleName = importStatement.getName() and
  is_module_deprecated(deprecatedModuleName, replacementSuggestion, _, _) and
  not has_import_error_handling(importStatement)
select importStatement, get_deprecation_warning(deprecatedModuleName) + get_replacement_suggestion(deprecatedModuleName)