/**
 * @name Unresolved import
 * @description Detects imports that cannot be resolved and lack fallback mechanisms
 *              or OS-specific guards. Such imports may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Finds alternative import expressions for a specified primary import.
 * The alternative must reside in a different branch (else/except) of
 * conditional or exception handling constructs.
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Map primary import to its alias
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Map fallback import to its alias
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Verify conditional statement branches
      exists(If conditionalBlock | 
        (conditionalBlock.getBody().contains(primaryImport) and conditionalBlock.getOrelse().contains(result)) or
        (conditionalBlock.getBody().contains(result) and conditionalBlock.getOrelse().contains(primaryImport))
      )
      or
      // Verify exception handling blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines the operating system associated with an OS-specific import.
 * Returns OS identifier (e.g., "win32", "darwin") for known platform-specific modules.
 */
string getOSSpecificImport(ImportExpr targetImport) {
  exists(string targetModuleName | targetModuleName = targetImport.getImportedModuleName() |
    // Java platform modules
    (targetModuleName.matches("org.python.%") or targetModuleName.matches("java.%")) and result = "java"
    or
    // macOS-specific modules
    targetModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows-specific modules
    result = "win32" and
    (
      targetModuleName = "_winapi" or
      targetModuleName = "_win32api" or
      targetModuleName = "_winreg" or
      targetModuleName = "nt" or
      targetModuleName.matches("win32%") or
      targetModuleName = "ntpath"
    )
    or
    // Linux-specific modules
    result = "linux2" and
    (targetModuleName = "posix" or targetModuleName = "posixpath")
    or
    // Unsupported platform modules
    result = "unsupported" and
    (targetModuleName = "__pypy__" or targetModuleName = "ce" or targetModuleName.matches("riscos%"))
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
predicate isAcceptableImportFailure(ImportExpr targetImport) {
  // Check for working alternative import
  getAlternativeImport(targetImport).refersTo(_)
  or
  // Check OS-specific import for non-current platform
  getOSSpecificImport(targetImport) != getCurrentPlatform()
}

/**
 * Represents control flow nodes checking Python interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class InterpreterVersionCheck extends ControlFlowNode {
  InterpreterVersionCheck() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
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
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import resolution failure
  exists(Context execContext | execContext.appliesTo(unresolvedImport.getAFlowNode())) and // Valid execution context
  not isAcceptableImportFailure(unresolvedImport) and // No acceptable failure condition
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."