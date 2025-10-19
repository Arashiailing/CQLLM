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
 * @param moduleName The name of the deprecated module
 * @param replacementModule The recommended replacement module ("no replacement" if none)
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return true if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  moduleName = "posixfile" and replacementModule = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "gopherlib" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "rgbimgmodule" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "pre" and replacementModule = "re" and majorVersion = 1 and minorVersion = 5
  or
  moduleName = "whrandom" and replacementModule = "random" and majorVersion = 2 and minorVersion = 1
  or
  moduleName = "rfc822" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimetools" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "MimeWriter" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "mimify" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "rotor" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "statcache" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "mpz" and replacementModule = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  moduleName = "xreadlines" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "multifile" and replacementModule = "email" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sets" and replacementModule = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  moduleName = "buildtools" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "cfmfile" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  moduleName = "macfs" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  moduleName = "md5" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  moduleName = "sha" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates deprecation warning message for a module
 * 
 * @param moduleName The name of the deprecated module
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
 * @param moduleName The name of the deprecated module
 * @return String with replacement recommendation (empty if no replacement)
 */
string replacement_message(string moduleName) {
  exists(string replacementModule | 
    deprecated_module(moduleName, replacementModule, _, _) |
    result = " Use '" + replacementModule + "' instead." and replacementModule != "no replacement"
    or
    result = "" and replacementModule = "no replacement"
  )
}

// Identify deprecated module imports not protected by ImportError handling
from ImportExpr importExpr, string moduleName, string replacementModule
where
  moduleName = importExpr.getName() and
  deprecated_module(moduleName, replacementModule, _, _) and
  not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importExpr)
  )
select importExpr, deprecation_message(moduleName) + replacement_message(moduleName)