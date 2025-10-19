/**
 * @name Import of deprecated module
 * @description Identifies imports of Python modules that have been deprecated in specific versions.
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
 * Holds if a module was deprecated in a specific Python version,
 * and provides the recommended replacement module.
 *
 * @param moduleName The name of the deprecated module.
 * @param replacementModule The recommended replacement module or "no replacement".
 * @param major The major version number of Python where the module was deprecated.
 * @param minor The minor version number of Python where the module was deprecated.
 */
predicate deprecated_module(string moduleName, string replacementModule, int major, int minor) {
  // Modules deprecated in Python 1.x
  (moduleName = "posixfile" and replacementModule = "fcntl" and major = 1 and minor = 5
   or
   moduleName = "pre" and replacementModule = "re" and major = 1 and minor = 5)
  or
  // Modules deprecated in Python 2.0-2.2
  (moduleName = "whrandom" and replacementModule = "random" and major = 2 and minor = 1
   or
   moduleName = "statcache" and replacementModule = "no replacement" and major = 2 and minor = 2
   or
   moduleName = "mpz" and replacementModule = "a third party" and major = 2 and minor = 2)
  or
  // Modules deprecated in Python 2.3-2.4
  (moduleName = "rfc822" and replacementModule = "email" and major = 2 and minor = 3
   or
   moduleName = "mimetools" and replacementModule = "email" and major = 2 and minor = 3
   or
   moduleName = "MimeWriter" and replacementModule = "email" and major = 2 and minor = 3
   or
   moduleName = "mimify" and replacementModule = "email" and major = 2 and minor = 3
   or
   moduleName = "xreadlines" and replacementModule = "no replacement" and major = 2 and minor = 3
   or
   moduleName = "rotor" and replacementModule = "no replacement" and major = 2 and minor = 4)
  or
  // Modules deprecated in Python 2.5-2.6
  (moduleName = "gopherlib" and replacementModule = "no replacement" and major = 2 and minor = 5
   or
   moduleName = "rgbimgmodule" and replacementModule = "no replacement" and major = 2 and minor = 5
   or
   moduleName = "multifile" and replacementModule = "email" and major = 2 and minor = 5
   or
   moduleName = "sets" and replacementModule = "builtins" and major = 2 and minor = 6)
  or
  // Other deprecated modules
  (moduleName = "buildtools" and replacementModule = "no replacement" and major = 2 and minor = 3
   or
   moduleName = "cfmfile" and replacementModule = "no replacement" and major = 2 and minor = 4
   or
   moduleName = "macfs" and replacementModule = "no replacement" and major = 2 and minor = 3
   or
   moduleName = "md5" and replacementModule = "hashlib" and major = 2 and minor = 5
   or
   moduleName = "sha" and replacementModule = "hashlib" and major = 2 and minor = 5)
}

/**
 * Gets a deprecation warning message for a module.
 *
 * @param modName The name of the deprecated module.
 * @return A string describing when the module was deprecated.
 */
string deprecation_message(string modName) {
  exists(int majorVer, int minorVer | 
    deprecated_module(modName, _, majorVer, minorVer)
  |
    result = "The " + modName + " module was deprecated in version " + 
             majorVer.toString() + "." + minorVer.toString() + "."
  )
}

/**
 * Gets a replacement suggestion message for a deprecated module.
 *
 * @param modName The name of the deprecated module.
 * @return A string with replacement suggestion or empty string if no replacement.
 */
string replacement_message(string modName) {
  exists(string replMod | 
    deprecated_module(modName, replMod, _, _)
  |
    (result = " Use " + replMod + " module instead." and replMod != "no replacement")
    or
    (result = "" and replMod = "no replacement")
  )
}

// Main query: find imports of deprecated modules without proper exception handling.
from ImportExpr importNode, string modName, string replMod
where
  modName = importNode.getName() and
  deprecated_module(modName, replMod, _, _) and
  // Exclude imports that are properly handled with ImportError exception handling.
  not exists(Try tryBlock, ExceptStmt exceptHandler | 
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importNode)
  )
select importNode, deprecation_message(modName) + replacement_message(modName)