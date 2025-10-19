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
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Verify aliases exist for both primary and alternative imports
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary import alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback import alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check for alternative imports in conditional branches
      exists(If conditionalBlock | 
        (conditionalBlock.getBody().contains(primaryImport) and conditionalBlock.getOrelse().contains(result)) or
        (conditionalBlock.getBody().contains(result) and conditionalBlock.getOrelse().contains(primaryImport))
      )
      or
      // Check for alternative imports in exception handlers
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS identifier when the import is platform-specific.
 */
string identifyOSSpecificImport(ImportExpr importStatement) {
  // Check for OS-specific patterns in imported module names
  exists(string importedModuleName | importedModuleName = importStatement.getImportedModuleName() |
    // Java platform imports
    (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and result = "java"
    or
    // macOS platform imports
    importedModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
    result = "win32" and
    (
      importedModuleName = "_winapi" or
      importedModuleName = "_win32api" or
      importedModuleName = "_winreg" or
      importedModuleName = "nt" or
      importedModuleName.matches("win32%") or
      importedModuleName = "ntpath"
    )
    or
    // Linux platform imports
    result = "linux2" and
    (importedModuleName = "posix" or importedModuleName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (importedModuleName = "__pypy__" or importedModuleName = "ce" or importedModuleName.matches("riscos%"))
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
predicate isPermittedImportFailure(ImportExpr failedImport) {
  // Check for working alternative imports
  getAlternativeImport(failedImport).refersTo(_)
  or
  // Check for OS-specific imports on incompatible platforms
  identifyOSSpecificImport(failedImport) != getCurrentPlatform()
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