/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved and lack fallback mechanisms
 *              or OS-specific guards. Such imports may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Locates alternative import expressions for a given primary import.
 * The alternative import must reside in a different branch (else/except) of
 * conditional or exception handling blocks.
 */
ImportExpr getAlternativeImport(ImportExpr mainImport) {
  exists(Alias mainAlias, Alias altAlias |
    // Map primary import to its alias
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Map fallback import to its alias
    (altAlias.getValue() = result or altAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional statement branches
      exists(If conditionalBlock | 
        (conditionalBlock.getBody().contains(mainImport) and conditionalBlock.getOrelse().contains(result)) or
        (conditionalBlock.getBody().contains(result) and conditionalBlock.getOrelse().contains(mainImport))
      )
      or
      // Check exception handling blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(mainImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines the operating system associated with an OS-specific import.
 * Returns OS identifier (e.g., "win32", "darwin") for known OS-specific modules.
 */
string getOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform modules
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS-specific modules
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows-specific modules
    result = "win32" and
    (
      moduleName = "_winapi" or
      moduleName = "_win32api" or
      moduleName = "_winreg" or
      moduleName = "nt" or
      moduleName.matches("win32%") or
      moduleName = "ntpath"
    )
    or
    // Linux-specific modules
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // Unsupported platform modules
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
  )
}

/**
 * Retrieves the current platform identifier from Python's sys.platform.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Evaluates if an unresolved import is acceptable due to:
 * 1. Availability of fallback alternatives
 * 2. OS-specific targeting different than current platform
 */
predicate isAcceptableImportFailure(ImportExpr importExpr) {
  // Check for working alternative import
  getAlternativeImport(importExpr).refersTo(_)
  or
  // Check OS-specific import for non-current platform
  getOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * Represents control flow nodes checking Python interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class InterpreterVersionCheck extends ControlFlowNode {
  InterpreterVersionCheck() {
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionCheck" }
}

/**
 * Represents condition blocks guarding code based on interpreter version.
 * Helps identify version-specific imports that should not be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof InterpreterVersionCheck }
}

// Main query: Identify problematic unresolved imports
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import resolution failure
  exists(Context execContext | execContext.appliesTo(problematicImport.getAFlowNode())) and // Valid execution context
  not isAcceptableImportFailure(problematicImport) and // No acceptable failure condition
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."