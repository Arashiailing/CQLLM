/**
 * @name Unresolved import
 * @description Identifies import statements that fail to resolve and lack
 *              fallback mechanisms or platform-specific guards. Such imports
 *              may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Locates alternative import expressions for a specified main import.
 * The alternative must reside in a different branch (else/except) of
 * conditional or exception handling constructs.
 */
ImportExpr getAlternativeImport(ImportExpr mainImport) {
  exists(Alias mainAlias, Alias altAlias |
    // Associate main import with its alias
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Associate fallback import with its alias
    (altAlias.getValue() = result or altAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Verify conditional statement branches
      exists(If ifStmt | 
        (ifStmt.getBody().contains(mainImport) and ifStmt.getOrelse().contains(result)) or
        (ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(mainImport))
      )
      or
      // Verify exception handling blocks
      exists(Try tryStmt | 
        (tryStmt.getBody().contains(mainImport) and tryStmt.getAHandler().contains(result)) or
        (tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines the operating system associated with a platform-specific import.
 * Returns OS identifier (e.g., "win32", "darwin") for known platform-specific modules.
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
 * 1. Presence of working alternative imports
 * 2. OS-specific targeting differing from current platform
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
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
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
from ImportExpr failedImport
where
  // The import cannot be resolved
  not failedImport.refersTo(_)
  and
  // The import is in a valid execution context
  exists(Context context | context.appliesTo(failedImport.getAFlowNode()))
  and
  // There is no acceptable failure condition (like a fallback or OS-specific import)
  not isAcceptableImportFailure(failedImport)
  and
  // There is no version guard protecting the import
  not exists(VersionGuardBlock guardBlock | guardBlock.controls(failedImport.getAFlowNode().getBasicBlock(), _))
select failedImport, "Unable to resolve import of '" + failedImport.getImportedModuleName() + "'."