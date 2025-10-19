/**
 * @name Unresolved import
 * @description Detects import statements that cannot be resolved to any known module.
 *              Unresolved imports may lead to reduced analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library for code analysis
import python

/**
 * Retrieves the current operating system platform identifier from the Python interpreter environment.
 * This helps determine platform-specific imports that may fail on different systems.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines the target operating system for platform-specific import statements.
 * Returns the corresponding OS name based on the imported module name patterns.
 */
string determineOSTarget(ImportExpr importExpression) {
  exists(string importedModuleName | importedModuleName = importExpression.getImportedModuleName() |
    // Java platform imports (Jython specific)
    (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and result = "java"
    or
    // Darwin/macOS platform imports
    importedModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
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
    // Linux/Unix platform imports
    result = "linux2" and
    (importedModuleName = "posix" or importedModuleName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (importedModuleName = "__pypy__" or importedModuleName = "ce" or importedModuleName.matches("riscos%"))
  )
}

/**
 * Represents a control flow node that performs Python interpreter version checks.
 * These nodes are typically used to guard version-specific import statements.
 */
class PythonVersionCheckNode extends ControlFlowNode {
  PythonVersionCheckNode() {
    exists(string versionAttributeName |
      versionAttributeName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttributeName))
    )
  }

  override string toString() { result = "VersionCheck" }
}

/**
 * Represents a conditional block that protects code based on interpreter version.
 * Used to identify version-specific imports that should not be flagged as issues.
 */
class VersionSpecificGuardBlock extends ConditionBlock {
  VersionSpecificGuardBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

/**
 * Checks if two imports are in separate conditional branches.
 */
predicate areInSeparateBranches(ImportExpr import1, ImportExpr import2) {
  exists(If conditionalBranch | 
    conditionalBranch.getBody().contains(import1) and conditionalBranch.getOrelse().contains(import2)
  )
  or
  exists(If conditionalBranch | 
    conditionalBranch.getBody().contains(import2) and conditionalBranch.getOrelse().contains(import1)
  )
}

/**
 * Checks if two imports are in try and except blocks.
 */
predicate areInTryExceptBlocks(ImportExpr import1, ImportExpr import2) {
  exists(Try exceptionHandlingBlock | 
    exceptionHandlingBlock.getBody().contains(import1) and exceptionHandlingBlock.getAHandler().contains(import2)
  )
  or
  exists(Try exceptionHandlingBlock | 
    exceptionHandlingBlock.getBody().contains(import2) and exceptionHandlingBlock.getAHandler().contains(import1)
  )
}

/**
 * Identifies alternative import expressions used as fallback mechanisms.
 * This function detects imports in conditional branches (if/else) or exception handling 
 * blocks (try/except) that serve as alternatives when the primary import fails.
 */
ImportExpr findAlternativeImport(ImportExpr mainImport) {
  // Ensure both primary and fallback imports have associated aliases
  exists(Alias mainAlias, Alias alternativeAlias |
    // Primary alias association check
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback alias association check
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in separate conditional branches
      areInSeparateBranches(mainImport, result)
      or
      // Check if imports are in try and except blocks
      areInTryExceptBlocks(mainImport, result)
    )
  )
}

/**
 * Determines if an import failure is acceptable and should not be flagged as an issue.
 * Import failures are considered acceptable when there's a working alternative import
 * or when the import is OS-specific for a different platform than the current one.
 */
predicate isAcceptableFailure(ImportExpr importExpression) {
  // Check for existence of a working fallback import
  findAlternativeImport(importExpression).refersTo(_)
  or
  // Verify if the import targets a different OS than the current platform
  determineOSTarget(importExpression) != getCurrentPlatform()
}

/**
 * Checks if an import is protected by a version guard block.
 */
predicate isProtectedByVersionGuard(ImportExpr importExpression) {
  exists(VersionSpecificGuardBlock versionGuard | 
    versionGuard.controls(importExpression.getAFlowNode().getBasicBlock(), _)
  )
}

// Main query: Identify unresolved imports that should be reported as issues
from ImportExpr unresolvedImportExpression
where
  not unresolvedImportExpression.refersTo(_) and // Import cannot be resolved to any known module
  exists(Context validContext | validContext.appliesTo(unresolvedImportExpression.getAFlowNode())) and // Import is in a valid context
  not isAcceptableFailure(unresolvedImportExpression) and // Import failure is not acceptable
  not isProtectedByVersionGuard(unresolvedImportExpression) // Not protected by version guard
select unresolvedImportExpression, "Unable to resolve import of '" + unresolvedImportExpression.getImportedModuleName() + "'."