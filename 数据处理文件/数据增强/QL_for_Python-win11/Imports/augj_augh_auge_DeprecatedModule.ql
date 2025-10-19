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

import python

/**
 * Determines if a module was deprecated in a specific Python version
 * 
 * @param moduleName Name of the deprecated module
 * @param replacement Recommended replacement module ("no replacement" if none)
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return true if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleName, string replacement, int majorVersion, int minorVersion) {
  // List of deprecated modules with their replacements and deprecation versions
  moduleName = "posixfile" and replacement = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "gopherlib" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "rgbimgmodule" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "pre" and replacement = "re" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "whrandom" and replacement = "random" and majorVersion = 2 and minorVersion = 1
  or
  moduleName = "rfc822" and replacement = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimetools" and replacement = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "MimeWriter" and replacement = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimify" and replacement = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "rotor" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "statcache" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "mpz" and replacement = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "xreadlines" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "multifile" and replacement = "email" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sets" and replacement = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  moduleName = "buildtools" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "cfmfile" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "macfs" and replacement = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "md5" and replacement = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sha" and replacement = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates deprecation warning message for a module
 * 
 * @param moduleName Name of the deprecated module
 * @return String describing the deprecation version
 */
string deprecation_message(string moduleName) {
  exists(int majorVersion, int minorVersion | 
    deprecated_module(moduleName, _, majorVersion, minorVersion) |
    result = "Module '" + moduleName + "' was deprecated in Python " + 
             majorVersion.toString() + "." + minorVersion.toString()
  )
}

/**
 * Generates replacement recommendation message for a module
 * 
 * @param moduleName Name of the deprecated module
 * @return String with replacement recommendation (empty if no replacement)
 */
string replacement_message(string moduleName) {
  exists(string replacement | 
    deprecated_module(moduleName, replacement, _, _) |
    if replacement != "no replacement"
    then result = " Use '" + replacement + "' instead."
    else result = ""
  )
}

// Identify deprecated module imports not protected by ImportError handling
from ImportExpr importStmt, string moduleName, string replacement
where
  moduleName = importStmt.getName() and
  deprecated_module(moduleName, replacement, _, _) and
  not exists(Try tryBlock, ExceptStmt handler | 
    handler = tryBlock.getAHandler() and
    handler.getType().pointsTo(ClassValue::importError()) and
    handler.containsInScope(importStmt)
  )
select importStmt, deprecation_message(moduleName) + replacement_message(moduleName)