/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis module
import python

/**
 * Obtains the current operating system platform from the Python interpreter.
 */
string getCurrentOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies if an import is specific to a particular operating system.
 * Returns the operating system name if the import is OS-specific.
 */
string identifyOSSpecificImport(ImportExpr importExpr) {
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
 * Finds alternative import expressions that serve as fallback imports.
 * This function identifies imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to each other.
 */
ImportExpr findFallbackImport(ImportExpr sourceImport) {
  // Verify aliases exist for both the source and fallback imports
  exists(Alias sourceAlias, Alias fallbackAlias |
    // Source alias mapping
    (sourceAlias.getValue() = sourceImport or sourceAlias.getValue().(ImportMember).getModule() = sourceImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditional | 
        conditional.getBody().contains(sourceImport) and conditional.getOrelse().contains(result)
      )
      or
      exists(If conditional | 
        conditional.getBody().contains(result) and conditional.getOrelse().contains(sourceImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(sourceImport) and tryBlock.getAHandler().contains(result)
      )
      or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(sourceImport)
      )
    )
  )
}

/**
 * Determines if an import is permitted to fail without being flagged as an issue.
 * An import is permitted to fail if it has an alternative or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportFailureAcceptable(ImportExpr importStatement) {
  // Check if there's a working fallback import
  findFallbackImport(importStatement).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  identifyOSSpecificImport(importStatement) != getCurrentOSPlatform()
}

/**
 * Represents a control flow node that checks the Python interpreter version.
 * These nodes are typically used to conditionally import modules based on version compatibility.
 */
class PythonVersionCheckNode extends ControlFlowNode {
  PythonVersionCheckNode() {
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
class VersionConditionalBlock extends ConditionBlock {
  VersionConditionalBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

// Main query: Identify unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context applicableContext | applicableContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportFailureAcceptable(unresolvedImport) and // Import is not permitted to fail
  not exists(VersionConditionalBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."