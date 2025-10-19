/**
 * @name Unresolved import
 * @description Detects imports that cannot be resolved, potentially reducing analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Locates alternative import expressions used as fallbacks in conditional or exception handling contexts.
 * This function identifies imports used in if/else branches or try/except blocks as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Verify aliases exist for both the primary and alternative imports
  exists(Alias primaryAlias, Alias alternativeAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Alternative alias mapping
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditional | 
        (conditional.getBody().contains(primaryImport) and conditional.getOrelse().contains(result))
        or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(primaryImport))
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(primaryImport) and tryBlock.getAHandler().contains(result))
        or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS name if the import is platform-specific.
 */
string determineOSSpecificImport(ImportExpr platformImport) {
  // Check if the imported module name matches OS-specific patterns
  exists(string importedName | importedName = platformImport.getImportedModuleName() |
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
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an import is allowed to fail without being flagged.
 * An import is acceptable to fail if it has a working alternative or is OS-specific
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
 * These nodes typically conditionally import modules based on version compatibility.
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
 * Represents a conditional block that guards code based on the Python interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

// Main query: Identify unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionCheck | versionCheck.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."