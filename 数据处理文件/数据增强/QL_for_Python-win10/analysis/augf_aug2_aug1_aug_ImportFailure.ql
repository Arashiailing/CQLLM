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
 * This is used to determine if OS-specific imports should be flagged as unresolved.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies imports that are specific to a particular operating system.
 * Returns the operating system name if the import is OS-specific.
 */
string identifyOSSpecificImport(ImportExpr importStmt) {
  exists(string importedModuleName | importedModuleName = importStmt.getImportedModuleName() |
    // Java-related imports
    (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and 
    result = "java"
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
ImportExpr findAlternativeImport(ImportExpr mainImport) {
  exists(Alias mainAlias, Alias altAlias |
    // Primary alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback alias mapping
    (altAlias.getValue() = result or altAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditional | 
        (conditional.getBody().contains(mainImport) and conditional.getOrelse().contains(result)) or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(mainImport))
      )
      or
      // Check if imports are in try and except blocks
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(mainImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines if an import is allowed to fail without being flagged as an issue.
 * An import is allowed to fail if it has an alternative or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportFailureAcceptable(ImportExpr importStmt) {
  // Check if there's a working alternative import
  findAlternativeImport(importStmt).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  identifyOSSpecificImport(importStmt) != getCurrentPlatform()
}

/**
 * Represents a control flow node that tests the Python interpreter version.
 * These nodes are typically used to conditionally import modules based on version compatibility.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
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
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(problematicImport.getAFlowNode())) and // Import is in a valid context
  not isImportFailureAcceptable(problematicImport) and // Import is not allowed to fail
  not exists(VersionGuardBlock guardBlock | guardBlock.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."