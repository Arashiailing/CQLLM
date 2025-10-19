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
 * Predicate to determine if a module was deprecated in a specific Python version
 * 
 * @param moduleIdentifier The name of the deprecated module
 * @param suggestedReplacement The recommended replacement module ("no replacement" if none)
 * @param deprecatedMajorVersion Major version number where deprecation occurred
 * @param deprecatedMinorVersion Minor version number where deprecation occurred
 * @return true if the module was deprecated in the specified version
 */
predicate deprecated_module(string moduleIdentifier, string suggestedReplacement, int deprecatedMajorVersion, int deprecatedMinorVersion) {
  // Deprecated modules with their replacements and deprecation versions
  moduleIdentifier = "posixfile" and suggestedReplacement = "fcntl" and deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "gopherlib" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "rgbimgmodule" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "pre" and suggestedReplacement = "re" and deprecatedMajorVersion = 1 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "whrandom" and suggestedReplacement = "random" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 1
  or
  moduleIdentifier = "rfc822" and suggestedReplacement = "email" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "mimetools" and suggestedReplacement = "email" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "MimeWriter" and suggestedReplacement = "email" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "mimify" and suggestedReplacement = "email" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "rotor" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
  or
  moduleIdentifier = "statcache" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
  or
  moduleIdentifier = "mpz" and suggestedReplacement = "a third party" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 2
  or
  moduleIdentifier = "xreadlines" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "multifile" and suggestedReplacement = "email" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "sets" and suggestedReplacement = "builtins" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 6
  or
  moduleIdentifier = "buildtools" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "cfmfile" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 4
  or
  moduleIdentifier = "macfs" and suggestedReplacement = "no replacement" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 3
  or
  moduleIdentifier = "md5" and suggestedReplacement = "hashlib" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
  or
  moduleIdentifier = "sha" and suggestedReplacement = "hashlib" and deprecatedMajorVersion = 2 and deprecatedMinorVersion = 5
}

/**
 * Generates deprecation warning message for a module
 * 
 * @param moduleIdentifier The name of the deprecated module
 * @return String describing the deprecation version
 */
string deprecation_message(string moduleIdentifier) {
  exists(int deprecatedMajorVersion, int deprecatedMinorVersion | 
    deprecated_module(moduleIdentifier, _, deprecatedMajorVersion, deprecatedMinorVersion) |
    result = "Module '" + moduleIdentifier + "' was deprecated in Python " + 
             deprecatedMajorVersion.toString() + "." + deprecatedMinorVersion.toString()
  )
}

/**
 * Generates replacement recommendation message for a module
 * 
 * @param moduleIdentifier The name of the deprecated module
 * @return String with replacement recommendation (empty if no replacement)
 */
string replacement_message(string moduleIdentifier) {
  exists(string suggestedReplacement | 
    deprecated_module(moduleIdentifier, suggestedReplacement, _, _) |
    if suggestedReplacement != "no replacement"
    then result = " Use '" + suggestedReplacement + "' instead."
    else result = ""
  )
}

// Identify deprecated module imports not protected by ImportError handling
from ImportExpr importStatement, string moduleIdentifier, string suggestedReplacement
where
  moduleIdentifier = importStatement.getName() and
  deprecated_module(moduleIdentifier, suggestedReplacement, _, _) and
  not exists(Try exceptionHandlingBlock, ExceptStmt exceptionHandler | 
    exceptionHandler = exceptionHandlingBlock.getAHandler() and
    exceptionHandler.getType().pointsTo(ClassValue::importError()) and
    exceptionHandler.containsInScope(importStatement)
  )
select importStatement, deprecation_message(moduleIdentifier) + replacement_message(moduleIdentifier)