/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved, which may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the operating system name if the import is OS-specific.
 */
string determineOSSpecificImport(ImportExpr importExpr) {
  exists(string importedName | importedName = importExpr.getImportedModuleName() |
    // Java-related imports
    (importedName.matches("org.python.%") or importedName.matches("java.%")) and 
    result = "java"
    or
    // macOS imports
    importedName.matches("Carbon.%") and 
    result = "darwin"
    or
    // Windows imports
    result = "win32" and
    (
      importedName = "_winapi" or
      importedName = "_win32api" or
      importedName = "_winreg" or
      importedName = "nt" or
      importedName.matches("win32%") or
      importedName = "ntpath"
    )
    or
    // Linux imports
    result = "linux2" and
    (importedName = "posix" or importedName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (importedName = "__pypy__" or importedName = "ce" or importedName.matches("riscos%"))
  )
}

/**
 * Identifies alternative import expressions used as fallback mechanisms.
 * This function finds imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr sourceImport) {
  exists(Alias sourceAlias, Alias fallbackAlias |
    // Source alias mapping
    (sourceAlias.getValue() = sourceImport or 
     sourceAlias.getValue().(ImportMember).getModule() = sourceImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or 
     fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Conditional branches (if/else)
      exists(If conditional | 
        (conditional.getBody().contains(sourceImport) and conditional.getOrelse().contains(result)) or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(sourceImport))
      )
      or
      // Exception handling (try/except)
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(sourceImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(sourceImport))
      )
    )
  )
}

/**
 * Determines if an unresolved import is acceptable based on fallback mechanisms
 * or OS-specific conditions.
 */
predicate isImportAcceptableToFail(ImportExpr importExpr) {
  // Check for working alternative import
  getAlternativeImport(importExpr).refersTo(_)
  or
  // Check OS-specific import for different platform
  determineOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * Represents control flow nodes that test Python interpreter version.
 * These nodes are typically used for version-specific conditional imports.
 */
class InterpreterVersionTest extends ControlFlowNode {
  InterpreterVersionTest() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents conditional blocks guarding code based on Python interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

// Main query: Identify unresolved imports requiring attention
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isImportAcceptableToFail(unresolvedImport) and // No acceptable failure condition
  not exists(VersionBasedGuard versionCheck | // Not protected by version guard
    versionCheck.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)
  )
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."