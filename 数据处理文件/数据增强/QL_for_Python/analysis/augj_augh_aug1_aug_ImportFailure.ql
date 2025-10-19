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
string determineOSSpecificImport(ImportExpr importStatement) {
  exists(string importedName | importedName = importStatement.getImportedModuleName() |
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
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  exists(Alias primaryAlias, Alias alternativeAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or 
     primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Alternative alias mapping
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Conditional branches (if/else)
      exists(If conditional | 
        (conditional.getBody().contains(primaryImport) and conditional.getOrelse().contains(result)) or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(primaryImport))
      )
      or
      // Exception handling (try/except)
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(primaryImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an unresolved import is acceptable based on fallback mechanisms
 * or OS-specific conditions.
 */
predicate isImportAcceptableToFail(ImportExpr importStatement) {
  // Check for working alternative import
  getAlternativeImport(importStatement).refersTo(_)
  or
  // Check OS-specific import for different platform
  determineOSSpecificImport(importStatement) != getCurrentPlatform()
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
from ImportExpr failedImport
where
  not failedImport.refersTo(_) and // Import cannot be resolved
  exists(Context executionContext | executionContext.appliesTo(failedImport.getAFlowNode())) and // Import is in valid context
  not isImportAcceptableToFail(failedImport) and // No acceptable failure condition
  not exists(VersionBasedGuard versionGuard | // Not protected by version guard
    versionGuard.controls(failedImport.getAFlowNode().getBasicBlock(), _)
  )
select failedImport, "Unable to resolve import of '" + failedImport.getImportedModuleName() + "'."