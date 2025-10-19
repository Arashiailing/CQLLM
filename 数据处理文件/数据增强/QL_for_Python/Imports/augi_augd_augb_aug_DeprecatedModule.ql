/**
 * @name Import of deprecated module
 * @description Identifies imports of deprecated Python modules
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
 * Determines if a module has been deprecated in a specific Python version.
 * 
 * @param importedModuleName The name of the module being checked for deprecation
 * @param replacementSuggestion The recommended replacement module
 * @param majorVer Major version number where deprecation occurred
 * @param minorVer Minor version number where deprecation occurred
 * @return true if the module is deprecated in the specified version
 */
predicate moduleIsDeprecated(string importedModuleName, string replacementSuggestion, int majorVer, int minorVer) {
  // POSIX file operations module
  importedModuleName = "posixfile" and replacementSuggestion = "fcntl" and majorVer = 1 and minorVer = 5
  or
  // Gopher protocol client module
  importedModuleName = "gopherlib" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 5
  or
  // RGB image processing module
  importedModuleName = "rgbimgmodule" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 5
  or
  // Regular expression operations (old module)
  importedModuleName = "pre" and replacementSuggestion = "re" and majorVer = 1 and minorVer = 5
  or
  // Pseudo-random number generator (old module)
  importedModuleName = "whrandom" and replacementSuggestion = "random" and majorVer = 2 and minorVer = 1
  or
  // RFC-822 message handling module
  importedModuleName = "rfc822" and replacementSuggestion = "email" and majorVer = 2 and minorVer = 3
  or
  // MIME tools module
  importedModuleName = "mimetools" and replacementSuggestion = "email" and majorVer = 2 and minorVer = 3
  or
  // MIME writer module
  importedModuleName = "MimeWriter" and replacementSuggestion = "email" and majorVer = 2 and minorVer = 3
  or
  // MIME message handling module
  importedModuleName = "mimify" and replacementSuggestion = "email" and majorVer = 2 and minorVer = 3
  or
  // Enigma-like encryption module
  importedModuleName = "rotor" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 4
  or
  // Cached file status module
  importedModuleName = "statcache" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 2
  or
  // Multiple precision integers module
  importedModuleName = "mpz" and replacementSuggestion = "a third party" and majorVer = 2 and minorVer = 2
  or
  // Line-oriented file interface module
  importedModuleName = "xreadlines" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 3
  or
  // Multi-file handling module
  importedModuleName = "multifile" and replacementSuggestion = "email" and majorVer = 2 and minorVer = 5
  or
  // Set data type module (replaced by built-in)
  importedModuleName = "sets" and replacementSuggestion = "builtins" and majorVer = 2 and minorVer = 6
  or
  // Build tools module
  importedModuleName = "buildtools" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 3
  or
  // Macintosh resource fork module
  importedModuleName = "cfmfile" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 4
  or
  // Macintosh file system module
  importedModuleName = "macfs" and replacementSuggestion = "no replacement" and majorVer = 2 and minorVer = 3
  or
  // MD5 hash algorithm module
  importedModuleName = "md5" and replacementSuggestion = "hashlib" and majorVer = 2 and minorVer = 5
  or
  // SHA hash algorithm module
  importedModuleName = "sha" and replacementSuggestion = "hashlib" and majorVer = 2 and minorVer = 5
}

/**
 * Constructs a formatted string containing deprecation version information for a module.
 * 
 * @param importedModuleName The name of the module to check
 * @return A formatted string with deprecation version details
 */
string getDeprecationVersionInfo(string importedModuleName) {
  exists(int majorVer, int minorVer |
    moduleIsDeprecated(importedModuleName, _, majorVer, minorVer) and
    result = "The " + importedModuleName + " module was deprecated in version " + 
             majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Generates a replacement recommendation message for a deprecated module.
 * 
 * @param importedModuleName The name of the module to check
 * @return Replacement suggestion message or empty string if no replacement exists
 */
string getReplacementRecommendation(string importedModuleName) {
  exists(string replacementSuggestion |
    moduleIsDeprecated(importedModuleName, replacementSuggestion, _, _) and
    (
      result = " Use " + replacementSuggestion + " module instead." and 
      replacementSuggestion != "no replacement"
      or
      result = "" and replacementSuggestion = "no replacement"
    )
  )
}

from ImportExpr importExpr, string importedModuleName, string replacementSuggestion
where
  // Match imported module name
  importedModuleName = importExpr.getName()
  // Check if module is deprecated
  and moduleIsDeprecated(importedModuleName, replacementSuggestion, _, _)
  // Exclude imports wrapped in ImportError handling
  and not exists(Try tryStmt, ExceptStmt exceptClause |
    exceptClause = tryStmt.getAHandler() and
    exceptClause.getType().pointsTo(ClassValue::importError()) and
    exceptClause.containsInScope(importExpr)
  )
select importExpr, 
       getDeprecationVersionInfo(importedModuleName) + getReplacementRecommendation(importedModuleName)