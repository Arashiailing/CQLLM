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
 * Locates fallback imports used as alternatives to primary imports.
 * This function identifies imports within conditional (if/else) or exception-handling (try/except) blocks
 * that serve as alternatives when primary imports fail.
 */
ImportExpr getAlternativeImport(ImportExpr mainImport) {
  // Verify aliases exist for both primary and alternative imports
  exists(Alias mainAlias, Alias alternativeAlias |
    // Main import alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Alternative import alias mapping
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check for alternative imports in conditional branches
      exists(If ifStmt | 
        (ifStmt.getBody().contains(mainImport) and ifStmt.getOrelse().contains(result)) or
        (ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(mainImport))
      )
      or
      // Check for alternative imports in exception handlers
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
string identifyOSSpecificImport(ImportExpr importExpr) {
  // Check for OS-specific patterns in imported module names
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
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
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import should be ignored.
 * An import is acceptable to fail if it has a working alternative or is
 * OS-specific for a platform different from the current one.
 */
predicate isPermittedImportFailure(ImportExpr importExpr) {
  // Check for working alternative imports
  getAlternativeImport(importExpr).refersTo(_)
  or
  // Check for OS-specific imports on incompatible platforms
  identifyOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * Represents control flow nodes that check Python interpreter version.
 * These nodes typically guard version-specific import statements.
 */
class InterpreterVersionTest extends ControlFlowNode {
  InterpreterVersionTest() {
    exists(string versionPattern |
      versionPattern.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionPattern))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents conditional blocks that guard code based on interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isPermittedImportFailure(unresolvedImport) and // Import failure is not permitted
  not exists(VersionBasedGuard versionCheck | versionCheck.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."