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
string identifyOSSpecificImport(ImportExpr importExpr) {
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
 * Finds alternative import expressions that serve as fallback imports.
 * This function identifies imports used in conditional statements (if/else) or 
 * exception handling (try/except) as alternatives to each other.
 */
ImportExpr findAlternativeImport(ImportExpr primaryImport) {
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
 * An import is allowed to fail if it has an alternative or if it's OS-specific
 * for a different OS than the current one.
 */
predicate isImportFailureAcceptable(ImportExpr importExpr) {
  // Check if there's a working alternative import
  findAlternativeImport(importExpr).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  identifyOSSpecificImport(importExpr) != getCurrentPlatform()
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
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportFailureAcceptable(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."