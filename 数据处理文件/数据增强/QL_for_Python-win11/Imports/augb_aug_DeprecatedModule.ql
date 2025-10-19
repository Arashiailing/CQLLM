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
 * Determines if a module is deprecated in a specific Python version
 * 
 * @param modName The module name being checked
 * @param replacementMod The recommended replacement module
 * @param majorVer Major version number where deprecation occurred
 * @param minorVer Minor version number where deprecation occurred
 * @return true if module is deprecated in specified version
 */
predicate deprecated_module(string modName, string replacementMod, int majorVer, int minorVer) {
  (
    modName = "posixfile" and replacementMod = "fcntl" and majorVer = 1 and minorVer = 5
  ) or (
    modName = "gopherlib" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 5
  ) or (
    modName = "rgbimgmodule" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 5
  ) or (
    modName = "pre" and replacementMod = "re" and majorVer = 1 and minorVer = 5
  ) or (
    modName = "whrandom" and replacementMod = "random" and majorVer = 2 and minorVer = 1
  ) or (
    modName = "rfc822" and replacementMod = "email" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "mimetools" and replacementMod = "email" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "MimeWriter" and replacementMod = "email" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "mimify" and replacementMod = "email" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "rotor" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 4
  ) or (
    modName = "statcache" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 2
  ) or (
    modName = "mpz" and replacementMod = "a third party" and majorVer = 2 and minorVer = 2
  ) or (
    modName = "xreadlines" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "multifile" and replacementMod = "email" and majorVer = 2 and minorVer = 5
  ) or (
    modName = "sets" and replacementMod = "builtins" and majorVer = 2 and minorVer = 6
  ) or (
    modName = "buildtools" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "cfmfile" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 4
  ) or (
    modName = "macfs" and replacementMod = "no replacement" and majorVer = 2 and minorVer = 3
  ) or (
    modName = "md5" and replacementMod = "hashlib" and majorVer = 2 and minorVer = 5
  ) or (
    modName = "sha" and replacementMod = "hashlib" and majorVer = 2 and minorVer = 5
  )
}

/**
 * Generates deprecation version information for a module
 * 
 * @param modName The module name to check
 * @return Formatted string with deprecation version details
 */
string get_deprecation_info(string modName) {
  exists(int majorVer, int minorVer |
    deprecated_module(modName, _, majorVer, minorVer) and
    result = "The " + modName + " module was deprecated in version " + 
             majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 * 
 * @param modName The module name to check
 * @return Replacement suggestion message or empty string
 */
string get_replacement_suggestion(string modName) {
  exists(string replacementMod |
    deprecated_module(modName, replacementMod, _, _) and
    (
      result = " Use " + replacementMod + " module instead." and 
      replacementMod != "no replacement"
      or
      result = "" and replacementMod = "no replacement"
    )
  )
}

from ImportExpr importNode, string modName, string replacementMod
where
  modName = importNode.getName() and
  deprecated_module(modName, replacementMod, _, _) and
  not exists(Try tryBlock, ExceptStmt exceptHandler |
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importNode)
  )
select importNode, 
       get_deprecation_info(modName) + get_replacement_suggestion(modName)