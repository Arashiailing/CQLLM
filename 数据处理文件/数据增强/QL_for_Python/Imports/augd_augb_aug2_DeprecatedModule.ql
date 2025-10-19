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
 * Checks if a module was deprecated in a specific Python version
 * and provides the recommended replacement module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @param suggestedReplacement The recommended replacement module or "no replacement"
 * @param deprecatedMajorVersion The major version number of Python where the module was deprecated
 * @param deprecatedMinorVersion The minor version number of Python where the module was deprecated
 * @return True if the module was deprecated in the specified version
 */
predicate is_module_deprecated(string deprecatedModuleName, string suggestedReplacement, 
                              int deprecatedMajorVersion, int deprecatedMinorVersion) {
  // Python 1.x deprecated modules
  (
    deprecatedModuleName = "posixfile" and suggestedReplacement = "fcntl" and 
    deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
    or
    deprecatedModuleName = "pre" and suggestedReplacement = "re" and 
    deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
  )
  or
  // Python 2.0-2.2 deprecated modules
  (
    deprecatedModuleName = "whrandom" and suggestedReplacement = "random" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 1
    or
    deprecatedModuleName = "statcache" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
    or
    deprecatedModuleName = "mpz" and suggestedReplacement = "a third party" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
  )
  or
  // Python 2.3-2.4 deprecated modules
  (
    deprecatedModuleName = "rfc822" and suggestedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "mimetools" and suggestedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "MimeWriter" and suggestedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "mimify" and suggestedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "xreadlines" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "rotor" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
  )
  or
  // Python 2.5-2.6 deprecated modules
  (
    deprecatedModuleName = "gopherlib" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
    or
    deprecatedModuleName = "rgbimgmodule" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
    or
    deprecatedModuleName = "multifile" and suggestedReplacement = "email" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
    or
    deprecatedModuleName = "sets" and suggestedReplacement = "builtins" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 6
  )
  or
  // Additional deprecated modules
  (
    deprecatedModuleName = "buildtools" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "cfmfile" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
    or
    deprecatedModuleName = "macfs" and suggestedReplacement = "no replacement" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
    or
    deprecatedModuleName = "md5" and suggestedReplacement = "hashlib" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
    or
    deprecatedModuleName = "sha" and suggestedReplacement = "hashlib" and 
    deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  )
}

/**
 * Generates deprecation warning message for a module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return A string describing when the module was deprecated
 */
string get_deprecation_warning(string deprecatedModuleName) {
  // Find deprecation version and format warning message
  exists(int deprecatedMajorVersion, int deprecatedMinorVersion | 
    is_module_deprecated(deprecatedModuleName, _, deprecatedMajorVersion, deprecatedMinorVersion)
  |
    result = "The " + deprecatedModuleName + " module was deprecated in Python " + 
             deprecatedMajorVersion.toString() + "." + deprecatedMinorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for a deprecated module
 *
 * @param deprecatedModuleName The name of the deprecated module
 * @return A string with replacement suggestion or empty string if no replacement
 */
string get_replacement_suggestion(string deprecatedModuleName) {
  // Check for replacement module and format suggestion
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
 * Checks if an import statement has ImportError exception handling
 *
 * @param importExpr The import statement to check
 * @return True if the import is properly handled with ImportError exception handling
 */
predicate is_import_error_handled(ImportExpr importExpr) {
  exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpr)
  )
}

// Main query to identify imports of deprecated modules
from ImportExpr deprecatedImport, string importedModuleName, string replacementSuggestion
where
  // Extract imported module name
  importedModuleName = deprecatedImport.getName() and
  // Verify module is deprecated
  is_module_deprecated(importedModuleName, replacementSuggestion, _, _) and
  // Exclude properly handled imports
  not is_import_error_handled(deprecatedImport)
select deprecatedImport, get_deprecation_warning(importedModuleName) + get_replacement_suggestion(importedModuleName)