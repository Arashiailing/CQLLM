/**
 * @name Unresolved import
 * @description Detects unresolved imports that are not handled by fallback mechanisms or OS-specific guards.
 *              Such imports may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Finds a fallback import expression for a given primary import.
 * The fallback import is located in an alternative branch (else or except) of a conditional or try-except block.
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Verify aliases exist for both the primary and fallback imports
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If ifStmt | 
        (ifStmt.getBody().contains(primaryImport) and ifStmt.getOrelse().contains(result)) or
        (ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(primaryImport))
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryStmt | 
        (tryStmt.getBody().contains(primaryImport) and tryStmt.getAHandler().contains(result)) or
        (tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Identifies the operating system associated with an import expression, if it is OS-specific.
 * Returns the OS name (e.g., "win32", "darwin") for known OS-specific modules, otherwise no result.
 */
string determineOSSpecificImport(ImportExpr importExpression) {
  // Check if the imported module name matches OS-specific patterns
  exists(string importedModuleName | importedModuleName = importExpression.getImportedModuleName() |
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
 * Obtains the current platform identifier from the Python interpreter's sys.platform.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Checks if an unresolved import is acceptable (i.e., not a problem) because it has a fallback alternative
 * or is intended for a different operating system than the current one.
 */
predicate isImportAcceptableToFail(ImportExpr importExpression) {
  // Check if there's a working alternative import
  getAlternativeImport(importExpression).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  determineOSSpecificImport(importExpression) != getCurrentPlatform()
}

/**
 * Represents a control flow node that checks the Python interpreter version.
 * Such nodes are used to conditionally import modules based on version compatibility.
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
 * Represents a condition block that guards code based on the Python interpreter version.
 * This helps identify version-specific imports that should not be flagged as unresolved.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."