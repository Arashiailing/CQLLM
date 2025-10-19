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
 * Identifies fallback import expressions used as alternatives.
 * This function finds imports that serve as alternatives to each other,
 * typically found in conditional statements (if/else) or exception handling (try/except).
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Verify aliases exist for both the primary and result imports
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(primaryImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(primaryImport))
      )
      or
      // Check if imports are in try and except blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the operating system name if the import is OS-specific.
 */
string determineOSSpecificImport(ImportExpr importExpr) {
  // Check if the imported module name matches OS-specific patterns
  exists(string importedModuleName | importedModuleName = importExpr.getImportedModuleName() |
    // Java-related imports
    (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and result = "java"
    or
    // macOS imports
    importedModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows imports
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
    // Linux imports
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
 * Determines if an import is allowed to fail without being flagged as an issue.
 * An import is allowed to fail if it has an alternative or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportAcceptableToFail(ImportExpr importExpr) {
  // Check if there's a working alternative import
  getAlternativeImport(importExpr).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  determineOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * Represents a control flow node that tests the Python interpreter version.
 * These nodes are typically used to conditionally import modules based on version compatibility.
 */
class InterpreterVersionTest extends ControlFlowNode {
  InterpreterVersionTest() {
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
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
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."