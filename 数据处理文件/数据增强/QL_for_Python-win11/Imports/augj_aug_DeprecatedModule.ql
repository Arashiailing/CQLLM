/**
 * @name Import of deprecated module
 * @description Identifies imports of deprecated Python modules that should be replaced
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
 * Identifies deprecated modules with their replacements and deprecation versions
 * 
 * @param moduleName Name of the deprecated module
 * @param replacementModule Recommended replacement module ("no replacement" if none)
 * @param majorVersion Major Python version where deprecation occurred
 * @param minorVersion Minor Python version where deprecation occurred
 */
predicate deprecated_module(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  // Deprecated modules with their replacements and deprecation versions
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
 * @param moduleName Name of the deprecated module
 * @return Formatted deprecation warning with version information
 */
string get_deprecation_info(string moduleName) {
  exists(int majorVersion, int minorVersion | 
    deprecated_module(moduleName, _, majorVersion, minorVersion) |
    result = "The " + moduleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated modules
 * 
 * @param moduleName Name of the deprecated module
 * @return Replacement suggestion string or empty string if no replacement exists
 */
string get_replacement_suggestion(string moduleName) {
  exists(string replacementModule | 
    deprecated_module(moduleName, replacementModule, _, _) |
    result = " Use " + replacementModule + " module instead." 
             and not replacementModule = "no replacement"
    or
    result = "" and replacementModule = "no replacement"
  )
}

from ImportExpr importNode, string moduleName, string replacementModule
where
  moduleName = importNode.getName() and
  deprecated_module(moduleName, replacementModule, _, _) and
  not exists(Try tryStmt, ExceptStmt exceptHandler |
    exceptHandler = tryStmt.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importNode)
  )
select importNode, get_deprecation_info(moduleName) + get_replacement_suggestion(moduleName)