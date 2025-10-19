/**
 * @name Import of deprecated module
 * @description Detects Python source code that imports modules which have been deprecated in certain Python versions
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

// Import the standard Python library for code analysis
import python

/**
 * Identifies modules that have been deprecated in specific Python versions
 * along with their recommended replacements
 *
 * @param moduleName The name of the module that has been deprecated
 * @param replacementModule The suggested replacement module or "no replacement" if none exists
 * @param majorVersion The major Python version where deprecation occurred
 * @param minorVersion The minor Python version where deprecation occurred
 * @return True if the module was deprecated in the specified Python version
 */
predicate deprecated_module(string moduleName, string replacementModule, int majorVersion, int minorVersion) {
  // Python 1.x deprecated modules
  majorVersion = 1 and minorVersion = 5 and (
    moduleName = "posixfile" and replacementModule = "fcntl"
    or
    moduleName = "pre" and replacementModule = "re"
  )
  or
  // Python 2.0-2.2 deprecated modules
  majorVersion = 2 and (
    (minorVersion = 1 and moduleName = "whrandom" and replacementModule = "random")
    or
    (minorVersion = 2 and (
      moduleName = "statcache" and replacementModule = "no replacement"
      or
      moduleName = "mpz" and replacementModule = "a third party"
    ))
  )
  or
  // Python 2.3-2.4 deprecated modules
  majorVersion = 2 and (
    (minorVersion = 3 and (
      moduleName = "rfc822" and replacementModule = "email"
      or
      moduleName = "mimetools" and replacementModule = "email"
      or
      moduleName = "MimeWriter" and replacementModule = "email"
      or
      moduleName = "mimify" and replacementModule = "email"
      or
      moduleName = "xreadlines" and replacementModule = "no replacement"
    ))
    or
    (minorVersion = 4 and moduleName = "rotor" and replacementModule = "no replacement")
  )
  or
  // Python 2.5-2.6 deprecated modules
  majorVersion = 2 and (
    (minorVersion = 5 and (
      moduleName = "gopherlib" and replacementModule = "no replacement"
      or
      moduleName = "rgbimgmodule" and replacementModule = "no replacement"
      or
      moduleName = "multifile" and replacementModule = "email"
    ))
    or
    (minorVersion = 6 and moduleName = "sets" and replacementModule = "builtins")
  )
  or
  // Additional deprecated modules
  majorVersion = 2 and (
    (minorVersion = 3 and (
      moduleName = "buildtools" and replacementModule = "no replacement"
      or
      moduleName = "macfs" and replacementModule = "no replacement"
    ))
    or
    (minorVersion = 4 and moduleName = "cfmfile" and replacementModule = "no replacement")
    or
    (minorVersion = 5 and (
      moduleName = "md5" and replacementModule = "hashlib"
      or
      moduleName = "sha" and replacementModule = "hashlib"
    ))
  )
}

/**
 * Generates a warning message indicating when a module was deprecated
 *
 * @param deprecatedModuleName The name of the module that has been deprecated
 * @return A formatted string describing the deprecation version information
 */
string deprecation_message(string deprecatedModuleName) {
  // Generate warning message with deprecation version information
  exists(int majorVersion, int minorVersion | 
    deprecated_module(deprecatedModuleName, _, majorVersion, minorVersion)
  |
    result = "The " + deprecatedModuleName + " module was deprecated in version " + 
             majorVersion.toString() + "." + minorVersion.toString() + "."
  )
}

/**
 * Creates a message suggesting a replacement for a deprecated module
 *
 * @param deprecatedModuleName The name of the module that has been deprecated
 * @return A string with replacement guidance or empty string if no alternative is available
 */
string replacement_message(string deprecatedModuleName) {
  // Provide replacement guidance if available
  exists(string replacementModule | 
    deprecated_module(deprecatedModuleName, replacementModule, _, _)
  |
    if replacementModule = "no replacement"
    then result = ""
    else result = " Use " + replacementModule + " module instead."
  )
}

// Primary query that identifies deprecated module imports
from ImportExpr importExpression, string moduleName
where
  // Extract the imported module name
  moduleName = importExpression.getName()
  // Verify that the module has been deprecated
  and exists(string replacementModule, int majorVersion, int minorVersion |
    deprecated_module(moduleName, replacementModule, majorVersion, minorVersion)
  )
  // Exclude imports that are properly handled with ImportError exception handling
  and not exists(Try tryStatement, ExceptStmt exceptionHandler | 
    exceptionHandler = tryStatement.getAHandler()
    and exceptionHandler.getType().pointsTo(ClassValue::importError())
    and exceptionHandler.containsInScope(importExpression)
  )
select importExpression, deprecation_message(moduleName) + replacement_message(moduleName)