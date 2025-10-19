/**
 * @name Import of deprecated module
 * @description Identifies imports of deprecated Python modules and suggests replacements
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

// Import the Python library for handling Python code queries
import python

/**
 * Determines if a module is deprecated in a specific Python version
 * 
 * @param deprecatedModName The name of the deprecated module
 * @param replacementModName The replacement module name ("no replacement" if none)
 * @param majorVersion The major version number where deprecation occurred
 * @param minorVersion The minor version number where deprecation occurred
 * @return true if the module is deprecated in the specified version
 */
predicate deprecated_module(string deprecatedModName, string replacementModName, int majorVersion, int minorVersion) {
  // Core deprecation definitions for various Python modules
  deprecatedModName = "posixfile" and replacementModName = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  deprecatedModName = "gopherlib" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModName = "rgbimgmodule" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModName = "pre" and replacementModName = "re" and majorVersion = 1 and minorVersion = 5
  or
  deprecatedModName = "whrandom" and replacementModName = "random" and majorVersion = 2 and minorVersion = 1
  or
  deprecatedModName = "rfc822" and replacementModName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "mimetools" and replacementModName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "MimeWriter" and replacementModName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "mimify" and replacementModName = "email" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "rotor" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  deprecatedModName = "statcache" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  deprecatedModName = "mpz" and replacementModName = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  deprecatedModName = "xreadlines" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "multifile" and replacementModName = "email" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModName = "sets" and replacementModName = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  deprecatedModName = "buildtools" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "cfmfile" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  deprecatedModName = "macfs" and replacementModName = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  deprecatedModName = "md5" and replacementModName = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  deprecatedModName = "sha" and replacementModName = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates deprecation version information for a module
 * 
 * @param deprecatedModName The name of the deprecated module
 * @return A string containing the deprecation version information
 */
string get_deprecation_info(string deprecatedModName) {
  // Generate version-specific deprecation message
  exists(int majorVersion, int minorVersion | 
    deprecated_module(deprecatedModName, _, majorVersion, minorVersion)
  |
    result = "The " + deprecatedModName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for a deprecated module
 * 
 * @param deprecatedModName The name of the deprecated module
 * @return A string containing replacement suggestion or empty if no replacement
 */
string get_replacement_suggestion(string deprecatedModName) {
  // Generate replacement suggestion if available
  exists(string replacementModName | 
    deprecated_module(deprecatedModName, replacementModName, _, _)
  |
    result = " Use " + replacementModName + " module instead." 
    and not replacementModName = "no replacement"
    or
    result = "" and replacementModName = "no replacement"
  )
}

// Main query to find deprecated module imports
from ImportExpr importNode, string deprecatedModName, string replacementModName
where
  // Identify imported module name
  deprecatedModName = importNode.getName()
  and
  // Verify module is deprecated
  deprecated_module(deprecatedModName, replacementModName, _, _)
  and
  // Exclude imports handled by ImportError try-except blocks
  not exists(Try tryStmt, ExceptStmt exceptHandler |
    exceptHandler = tryStmt.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importNode)
  )
select importNode, 
       get_deprecation_info(deprecatedModName) + 
       get_replacement_suggestion(deprecatedModName)