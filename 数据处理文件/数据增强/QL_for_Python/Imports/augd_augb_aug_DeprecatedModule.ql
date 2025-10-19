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
 * Checks if a module is deprecated in specific Python version
 * 
 * @param moduleName The module name being checked
 * @param replacementModule The recommended replacement module
 * @param majorVersion Major version number where deprecation occurred
 * @param minorVersion Minor version number where deprecation occurred
 * @return true if module is deprecated in specified version
 */
predicate is_module_deprecated(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  // POSIX file operations module
  moduleName = "posixfile" and replacementModule = "fcntl" and majorVersion = 1 and minorVersion = 5
  or
  // Gopher protocol client module
  moduleName = "gopherlib" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  // RGB image processing module
  moduleName = "rgbimgmodule" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 5
  or
  // Regular expression operations (old module)
  moduleName = "pre" and replacementModule = "re" and majorVersion = 1 and minorVersion = 5
  or
  // Pseudo-random number generator (old module)
  moduleName = "whrandom" and replacementModule = "random" and majorVersion = 2 and minorVersion = 1
  or
  // RFC-822 message handling module
  moduleName = "rfc822" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  // MIME tools module
  moduleName = "mimetools" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  // MIME writer module
  moduleName = "MimeWriter" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  // MIME message handling module
  moduleName = "mimify" and replacementModule = "email" and majorVersion = 2 and minorVersion = 3
  or
  // Enigma-like encryption module
  moduleName = "rotor" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  // Cached file status module
  moduleName = "statcache" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 2
  or
  // Multiple precision integers module
  moduleName = "mpz" and replacementModule = "a third party" and majorVersion = 2 and minorVersion = 2
  or
  // Line-oriented file interface module
  moduleName = "xreadlines" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  // Multi-file handling module
  moduleName = "multifile" and replacementModule = "email" and majorVersion = 2 and minorVersion = 5
  or
  // Set data type module (replaced by built-in)
  moduleName = "sets" and replacementModule = "builtins" and majorVersion = 2 and minorVersion = 6
  or
  // Build tools module
  moduleName = "buildtools" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  // Macintosh resource fork module
  moduleName = "cfmfile" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 4
  or
  // Macintosh file system module
  moduleName = "macfs" and replacementModule = "no replacement" and majorVersion = 2 and minorVersion = 3
  or
  // MD5 hash algorithm module
  moduleName = "md5" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
  or
  // SHA hash algorithm module
  moduleName = "sha" and replacementModule = "hashlib" and majorVersion = 2 and minorVersion = 5
}

/**
 * Generates deprecation version information for a module
 * 
 * @param moduleName The module name to check
 * @return Formatted string with deprecation version details
 */
string get_deprecation_version_info(string moduleName) {
  exists(int majorVersion, int minorVersion |
    is_module_deprecated(moduleName, _, majorVersion, minorVersion) and
    result = "The " + moduleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Generates replacement suggestion for deprecated module
 * 
 * @param moduleName The module name to check
 * @return Replacement suggestion message or empty string
 */
string get_replacement_recommendation(string moduleName) {
  exists(string replacementModule |
    is_module_deprecated(moduleName, replacementModule, _, _) and
    (
      result = " Use " + replacementModule + " module instead." and 
      replacementModule != "no replacement"
      or
      result = "" and replacementModule = "no replacement"
    )
  )
}

from ImportExpr importStatement, string moduleName, string replacementModule
where
  // Match imported module name
  moduleName = importStatement.getName()
  // Check if module is deprecated
  and is_module_deprecated(moduleName, replacementModule, _, _)
  // Exclude imports wrapped in ImportError handling
  and not exists(Try tryBlock, ExceptStmt exceptHandler |
    exceptHandler = tryBlock.getAHandler() and
    exceptHandler.getType().pointsTo(ClassValue::importError()) and
    exceptHandler.containsInScope(importStatement)
  )
select importStatement, 
       get_deprecation_version_info(moduleName) + get_replacement_recommendation(moduleName)