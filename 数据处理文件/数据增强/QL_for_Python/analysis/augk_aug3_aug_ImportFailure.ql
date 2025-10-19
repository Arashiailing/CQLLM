/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved, potentially reducing analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Locates fallback imports used as alternatives to primary imports.
 * This function identifies imports within conditional (if/else) or exception-handling (try/except) blocks
 * that serve as alternatives when primary imports fail.
 */
ImportExpr getFallbackImport(ImportExpr mainImport) {
  // Verify aliases exist for both primary and fallback imports
  exists(Alias mainAlias, Alias fallbackAlias |
    // Primary import alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback import alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check for fallback imports in conditional branches
      exists(If conditional | 
        (conditional.getBody().contains(mainImport) and conditional.getOrelse().contains(result)) or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(mainImport))
      )
      or
      // Check for fallback imports in exception handlers
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(mainImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS identifier when the import is platform-specific.
 */
string detectOSSpecificImport(ImportExpr importStmt) {
  // Check for OS-specific patterns in imported module names
  exists(string moduleName | moduleName = importStmt.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS platform imports
    moduleName.matches("Carbon.%") and result = "darwin"
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
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getRuntimePlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import should be ignored.
 * An import is acceptable to fail if it has a working alternative or is
 * OS-specific for a platform different from the current one.
 */
predicate isValidImportFailure(ImportExpr importStmt) {
  // Check for working fallback imports
  getFallbackImport(importStmt).refersTo(_)
  or
  // Check for OS-specific imports on incompatible platforms
  detectOSSpecificImport(importStmt) != getRuntimePlatform()
}

/**
 * Represents control flow nodes that check Python interpreter version.
 * These nodes typically guard version-specific import statements.
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
 * Represents conditional blocks that guard code based on interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardedBlock extends ConditionBlock {
  VersionGuardedBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isValidImportFailure(unresolvedImport) and // Import failure is not permitted
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."