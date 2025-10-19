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
 * Identifies fallback import expressions used as alternatives in conditional or exception handling contexts.
 * This function finds imports used in if/else branches or try/except blocks as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr originalImport) {
  // Verify aliases exist for both the original and fallback imports
  exists(Alias originalAlias, Alias fallbackAlias |
    // Original alias mapping
    (originalAlias.getValue() = originalImport or originalAlias.getValue().(ImportMember).getModule() = originalImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditional | 
        conditional.getBody().contains(originalImport) and conditional.getOrelse().contains(result)
      )
      or
      exists(If conditional | 
        conditional.getBody().contains(result) and conditional.getOrelse().contains(originalImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(originalImport) and tryBlock.getAHandler().contains(result)
      )
      or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(originalImport)
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS name if the import is platform-specific.
 */
string determineOSSpecificImport(ImportExpr moduleImport) {
  // Check if the imported module name matches OS-specific patterns
  exists(string moduleName | moduleName = moduleImport.getImportedModuleName() |
    // Java-related imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS imports
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows imports
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
    // Linux imports
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
 * Determines if an import is allowed to fail without being flagged.
 * An import is acceptable to fail if it has a working alternative or is OS-specific
 * for a different OS than the current one.
 */
predicate isImportAcceptableToFail(ImportExpr importStatement) {
  // Check if there's a working alternative import
  getAlternativeImport(importStatement).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  determineOSSpecificImport(importStatement) != getCurrentPlatform()
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
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(problematicImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(problematicImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionCheck | versionCheck.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."