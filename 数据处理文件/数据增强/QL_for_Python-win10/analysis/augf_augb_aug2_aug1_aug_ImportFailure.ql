/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved, which may lead to reduced analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Retrieves the current operating system platform from the Python interpreter.
 * This information is used to determine if OS-specific imports should be flagged as unresolved.
 */
string getCurrentOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the operating system name if the import is OS-specific.
 */
string getOSSpecificImportType(ImportExpr importStatement) {
  // Check if the imported module name matches OS-specific patterns
  exists(string importedModuleName | importedModuleName = importStatement.getImportedModuleName() |
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
 * Identifies fallback import expressions that serve as alternatives.
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
      exists(If conditional | 
        conditional.getBody().contains(primaryImport) and conditional.getOrelse().contains(result)
      )
      or
      exists(If conditional | 
        conditional.getBody().contains(result) and conditional.getOrelse().contains(primaryImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(primaryImport) and tryBlock.getAHandler().contains(result)
      )
      or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(primaryImport)
      )
    )
  )
}

/**
 * Determines if an import is allowed to fail without being flagged as an issue.
 * An import is allowed to fail if it has a fallback or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportFailureAllowed(ImportExpr importStatement) {
  // Check if there's a working fallback import
  getAlternativeImport(importStatement).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  getOSSpecificImportType(importStatement) != getCurrentOSPlatform()
}

/**
 * Represents a control flow node that tests the Python interpreter version.
 * These nodes are typically used to conditionally import modules based on version compatibility.
 */
class InterpreterVersionCheckNode extends ControlFlowNode {
  InterpreterVersionCheckNode() {
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
class InterpreterVersionGuardBlock extends ConditionBlock {
  InterpreterVersionGuardBlock() { this.getLastNode() instanceof InterpreterVersionCheckNode }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import cannot be resolved
  exists(Context applicableContext | applicableContext.appliesTo(problematicImport.getAFlowNode())) and // Import is in a valid context
  not isImportFailureAllowed(problematicImport) and // Import is not allowed to fail
  not exists(InterpreterVersionGuardBlock versionCheckBlock | versionCheckBlock.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."