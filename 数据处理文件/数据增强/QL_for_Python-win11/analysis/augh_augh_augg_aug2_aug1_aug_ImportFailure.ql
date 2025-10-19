/**
 * @name Unresolved import
 * @description Detects imports that cannot be resolved, which may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Retrieves the current OS platform from the Python interpreter.
 * Used to determine if OS-specific imports should be flagged as unresolved.
 */
string getCurrentOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies OS-specific imports by matching module names against platform patterns.
 * Returns the platform name if the import is OS-specific.
 */
string identifyOSSpecificImport(ImportExpr importStatement) {
  exists(string targetModule | targetModule = importStatement.getImportedModuleName() |
    // Java platform imports
    (targetModule.matches("org.python.%") or targetModule.matches("java.%")) and 
    result = "java"
    or
    // macOS platform imports
    targetModule.matches("Carbon.%") and 
    result = "darwin"
    or
    // Windows platform imports
    result = "win32" and
    (
      targetModule = "_winapi" or
      targetModule = "_win32api" or
      targetModule = "_winreg" or
      targetModule = "nt" or
      targetModule.matches("win32%") or
      targetModule = "ntpath"
    )
    or
    // Linux platform imports
    result = "linux2" and
    (targetModule = "posix" or targetModule = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (targetModule = "__pypy__" or targetModule = "ce" or targetModule.matches("riscos%"))
  )
}

/**
 * Finds fallback imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to primary imports.
 */
ImportExpr findFallbackImport(ImportExpr primaryImport) {
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Map primary import to its alias
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Map fallback import to its alias
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different conditional branches
      exists(If conditionalBlock | 
        conditionalBlock.getBody().contains(primaryImport) and conditionalBlock.getOrelse().contains(result)
        or
        conditionalBlock.getBody().contains(result) and conditionalBlock.getOrelse().contains(primaryImport)
      )
      or
      // Check if imports are in try/except blocks
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)
        or
        exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport)
      )
    )
  )
}

/**
 * Determines if an unresolved import is acceptable by checking for:
 * 1. A working alternative import
 * 2. OS-specific import for a different OS than the current platform
 */
predicate isAcceptableUnresolvedImport(ImportExpr importStatement) {
  findFallbackImport(importStatement).refersTo(_)
  or
  identifyOSSpecificImport(importStatement) != getCurrentOSPlatform()
}

/**
 * Represents control flow nodes that test Python interpreter version.
 * Typically used for version-conditional imports.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents conditional blocks guarded by Python version checks.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardedBlock extends ConditionBlock {
  VersionGuardedBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  not isAcceptableUnresolvedImport(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."