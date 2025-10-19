/**
 * @name Unresolved Import Detection
 * @description This query identifies import statements that fail to resolve and do not have
 *              fallback mechanisms or OS-specific guards. These unresolved imports may
 *              negatively impact the coverage and precision of the analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Finds a fallback import expression for a specified main import.
 * The fallback import must be located in a distinct branch (else/except) of
 * a conditional or exception handling structure.
 */
ImportExpr getAlternativeImport(ImportExpr mainImport) {
  exists(Alias mainAlias, Alias altAlias |
    // Map main import to its alias
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Map fallback import to its alias
    (altAlias.getValue() = result or altAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional statement branches
      exists(If conditionBlock | 
        (conditionBlock.getBody().contains(mainImport) and conditionBlock.getOrelse().contains(result)) or
        (conditionBlock.getBody().contains(result) and conditionBlock.getOrelse().contains(mainImport))
      )
      or
      // Check exception handling blocks
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(mainImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Identifies the operating system tied to an OS-specific import statement.
 * Provides the OS identifier (e.g., "win32", "darwin") for recognized OS-specific modules.
 */
string getOSSpecificImport(ImportExpr importStmt) {
  exists(string moduleName | moduleName = importStmt.getImportedModuleName() |
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
 * Obtains the identifier of the current platform from Python's sys.platform.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines whether an unresolved import is acceptable, considering:
 * 1. The presence of a fallback alternative import
 * 2. The OS-specific import targeting a platform other than the current one
 */
predicate isAcceptableImportFailure(ImportExpr importStmt) {
  // Check for working alternative import
  getAlternativeImport(importStmt).refersTo(_)
  or
  // Check OS-specific import for non-current platform
  getOSSpecificImport(importStmt) != getCurrentPlatform()
}

/**
 * Represents control flow nodes that perform checks on the Python interpreter version.
 * These nodes help identify version-specific imports that should be excluded from flagging.
 */
class InterpreterVersionCheck extends ControlFlowNode {
  InterpreterVersionCheck() {
    exists(string versionString |
      versionString.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionString))
    )
  }

  override string toString() { result = "VersionCheck" }
}

/**
 * Represents condition blocks that protect code segments based on interpreter version.
 * These blocks assist in identifying version-specific imports that should not be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof InterpreterVersionCheck }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import resolution failure
  exists(Context execContext | execContext.appliesTo(unresolvedImport.getAFlowNode())) and // Valid execution context
  not isAcceptableImportFailure(unresolvedImport) and // No acceptable failure condition
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."