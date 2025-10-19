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
string getHostPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies OS-specific imports by matching module names against platform patterns.
 * Returns the platform name if the import is OS-specific.
 */
string determineOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and 
    result = "java"
    or
    // macOS platform imports
    moduleName.matches("Carbon.%") and 
    result = "darwin"
    or
    // Windows platform imports
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
    // Linux platform imports
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
  )
}

/**
 * Finds fallback imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to primary imports.
 */
ImportExpr locateAlternativeImport(ImportExpr mainImport) {
  exists(Alias mainAlias, Alias alternativeAlias |
    // Map main import to its alias
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Map alternative import to its alias
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different conditional branches
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(mainImport) and conditionalStmt.getOrelse().contains(result)
        or
        conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(mainImport)
      )
      or
      // Check if imports are in try/except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(mainImport) and tryBlock.getAHandler().contains(result)
        or
        tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(mainImport)
      )
    )
  )
}

/**
 * Determines if an unresolved import is acceptable by checking for:
 * 1. A working alternative import
 * 2. OS-specific import for a different OS than the current platform
 */
predicate isUnresolvedImportAcceptable(ImportExpr importExpr) {
  locateAlternativeImport(importExpr).refersTo(_)
  or
  determineOSSpecificImport(importExpr) != getHostPlatform()
}

/**
 * Represents control flow nodes that test Python interpreter version.
 * Typically used for version-conditional imports.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents conditional blocks guarded by Python version checks.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isUnresolvedImportAcceptable(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."