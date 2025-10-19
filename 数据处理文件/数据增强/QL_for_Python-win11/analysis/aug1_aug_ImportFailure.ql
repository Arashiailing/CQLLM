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
string determineOSSpecificImport(ImportExpr importExpr) {
  // Check if the imported module name matches OS-specific patterns
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
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
 * Identifies alternative import expressions that serve as fallback imports.
 * This function finds imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr originalImport) {
  // Verify aliases exist for both the original and alternative imports
  exists(Alias originalAlias, Alias alternativeAlias |
    // Original alias mapping
    (originalAlias.getValue() = originalImport or originalAlias.getValue().(ImportMember).getModule() = originalImport) and
    // Alternative alias mapping
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
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
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
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
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(problematicImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(problematicImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionCheck | versionCheck.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."