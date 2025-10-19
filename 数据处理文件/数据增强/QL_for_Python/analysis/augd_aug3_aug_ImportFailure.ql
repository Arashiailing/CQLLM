/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved, potentially reducing analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import core Python analysis functionality
import python

/**
 * Identifies fallback imports used as alternatives to primary imports.
 * This function detects imports within conditional (if/else) or exception-handling (try/except) blocks
 * that serve as fallback options when primary imports fail.
 */
ImportExpr findFallbackImport(ImportExpr mainImport) {
  // Ensure aliases exist for both main and fallback imports
  exists(Alias mainAlias, Alias fallbackAlias |
    // Main import alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback import alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check for fallback imports in conditional branches
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(mainImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(mainImport))
      )
      or
      // Check for fallback imports in exception handlers
      exists(Try tryStmt | 
        (tryStmt.getBody().contains(mainImport) and tryStmt.getAHandler().contains(result)) or
        (tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS identifier when the import is platform-specific.
 */
string detectPlatformSpecificImport(ImportExpr importExpr) {
  // Check for platform-specific patterns in imported module names
  exists(string modulePath | modulePath = importExpr.getImportedModuleName() |
    // Java platform imports
    (modulePath.matches("org.python.%") or modulePath.matches("java.%")) and result = "java"
    or
    // macOS platform imports
    modulePath.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
    result = "win32" and
    (
      modulePath = "_winapi" or
      modulePath = "_win32api" or
      modulePath = "_winreg" or
      modulePath = "nt" or
      modulePath.matches("win32%") or
      modulePath = "ntpath"
    )
    or
    // Linux platform imports
    result = "linux2" and
    (modulePath = "posix" or modulePath = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (modulePath = "__pypy__" or modulePath = "ce" or modulePath.matches("riscos%"))
  )
}

/**
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getHostPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import should be ignored.
 * An import is acceptable to fail if it has a working alternative or is
 * platform-specific for a platform different from the current one.
 */
predicate isAcceptableImportFailure(ImportExpr importStatement) {
  // Check for working alternative imports
  findFallbackImport(importStatement).refersTo(_)
  or
  // Check for platform-specific imports on incompatible platforms
  detectPlatformSpecificImport(importStatement) != getHostPlatform()
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
  exists(Context validCtx | validCtx.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isAcceptableImportFailure(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."