/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
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
string determineOSSpecificImport(ImportExpr importNode) {
  // Check if the imported module name matches OS-specific patterns
  exists(string importedName | importedName = importNode.getImportedModuleName() |
    // Java-related imports
    (importedName.matches("org.python.%") or importedName.matches("java.%")) and result = "java"
    or
    // macOS imports
    importedName.matches("Carbon.%") and result = "darwin"
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
 * Identifies alternative import expressions that serve as fallback imports.
 * This function finds imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Verify aliases exist for both the primary and alternative imports
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If ifStmt | 
        ifStmt.getBody().contains(primaryImport) and ifStmt.getOrelse().contains(result)
      )
      or
      exists(If ifStmt | 
        ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(primaryImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryStmt | 
        tryStmt.getBody().contains(primaryImport) and tryStmt.getAHandler().contains(result)
      )
      or
      exists(Try tryStmt | 
        tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(primaryImport)
      )
    )
  )
}

/**
 * Determines if an import is allowed to fail without being flagged as an issue.
 * An import is allowed to fail if it has an alternative or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportAcceptableToFail(ImportExpr importNode) {
  // Check if there's a working alternative import
  getAlternativeImport(importNode).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  determineOSSpecificImport(importNode) != getCurrentPlatform()
}

/**
 * Represents a control flow node that tests the Python interpreter version.
 * These nodes are typically used to conditionally import modules based on version compatibility.
 */
class InterpreterVersionTest extends ControlFlowNode {
  InterpreterVersionTest() {
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents a conditional block that guards code based on the Python interpreter version.
 * This is used to identify version-specific import statements that should not be flagged.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."