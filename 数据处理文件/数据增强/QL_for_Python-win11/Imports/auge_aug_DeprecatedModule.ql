/**
 * @name Import of deprecated module
 * @description Detects imports of deprecated Python modules and suggests replacements
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
 * Identifies deprecated modules and their replacements across Python versions
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @param replacementModuleName Suggested replacement module ("no replacement" if none)
 * @param majorVersion Major version where deprecation occurred
 * @param minorVersion Minor version where deprecation occurred
 * @return True if module is deprecated in specified version
 */
predicate deprecated_module(string deprecatedModuleName, string replacementModuleName, int majorVersion, int minorVersion) {
  // Core deprecation definitions with version information
  deprecatedModuleName = "posixfile" and replacementModuleName = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  deprecatedModuleName = "gopherlib" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModuleName = "rgbimgmodule" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModuleName = "pre" and replacementModuleName = "re" and majorVersion = 1 and minorVersion = 5
  or
  deprecatedModuleName = "whrandom" and replacementModuleName = "random" and majorVersion = 2 and minorVersion = 1
  or
  deprecatedModuleName = "rfc822" and replacementModuleName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "mimetools" and replacementModuleName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "MimeWriter" and replacementModuleName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "mimify" and replacementModuleName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "rotor" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  deprecatedModuleName = "statcache" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  deprecatedModuleName = "mpz" and replacementModuleName = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  deprecatedModuleName = "xreadlines" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "multifile" and replacementModuleName = "email" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModuleName = "sets" and replacementModuleName = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  deprecatedModuleName = "buildtools" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "cfmfile" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  deprecatedModuleName = "macfs" and replacementModuleName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModuleName = "md5" and replacementModuleName = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModuleName = "sha" and replacementModuleName = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates deprecation version information for a module
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return Formatted string with deprecation version details
 */
string get_deprecation_info(string deprecatedModuleName) {
  // Construct version-specific deprecation message
  exists(int majorVersion, int minorVersion | 
    deprecated_module(deprecatedModuleName, _, majorVersion, minorVersion)
  |
    result = "The " + deprecatedModuleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated modules
 *
 * @param deprecatedModuleName Name of the deprecated module
 * @return Replacement suggestion or empty string if no replacement
 */
string get_replacement_suggestion(string deprecatedModuleName) {
  // Provide replacement guidance if available
  exists(string replacementModuleName | 
    deprecated_module(deprecatedModuleName, replacementModuleName, _, _)
  |
    result = " Use " + replacementModuleName + " module instead." 
    and not replacementModuleName = "no replacement"
    or
    result = "" and replacementModuleName = "no replacement"
  )
}

// Main query logic to detect deprecated imports
from ImportExpr importStatement, string deprecatedModuleName, string replacementModuleName
where
  // Extract imported module name
  deprecatedModuleName = importStatement.getName() 
  and
  // Verify module deprecation status
  deprecated_module(deprecatedModuleName, replacementModuleName, _, _) 
  and
  // Exclude imports protected by ImportError handling
  not exists(Try tryBlock, ExceptStmt exceptionHandler |
    exceptionHandler = tryBlock.getAHandler() and
    exceptionHandler.getType().pointsTo(ClassValue::importError()) and
    exceptionHandler.containsInScope(importStatement)
  )
select importStatement, 
       get_deprecation_info(deprecatedModuleName) + get_replacement_suggestion(deprecatedModuleName)