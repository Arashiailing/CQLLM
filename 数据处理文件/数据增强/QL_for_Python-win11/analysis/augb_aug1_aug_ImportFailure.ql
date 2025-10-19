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
 * Fetches the operating system platform from the Python interpreter environment.
 */
string getPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies operating system-specific imports and returns the corresponding OS name.
 */
string identifyOSImport(ImportExpr importStmt) {
  // Evaluate if the imported module name corresponds to OS-specific patterns
  exists(string importedName | importedName = importStmt.getImportedModuleName() |
    // Java platform imports
    (importedName.matches("org.python.%") or importedName.matches("java.%")) and result = "java"
    or
    // Darwin/macOS imports
    importedName.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
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
    // Linux platform imports
    result = "linux2" and
    (importedName = "posix" or importedName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (importedName = "__pypy__" or importedName = "ce" or importedName.matches("riscos%"))
  )
}

/**
 * Finds fallback import expressions used as alternatives.
 * This function detects imports in conditional branches (if/else) or
 * exception handling blocks (try/except) that serve as alternatives.
 */
ImportExpr findFallbackImport(ImportExpr primaryImport) {
  // Confirm both primary and fallback imports have associated aliases
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary alias association
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback alias association
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in separate conditional branches
      exists(If branchCondition | 
        branchCondition.getBody().contains(primaryImport) and branchCondition.getOrelse().contains(result)
      )
      or
      exists(If branchCondition | 
        branchCondition.getBody().contains(result) and branchCondition.getOrelse().contains(primaryImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)
      )
      or
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport)
      )
    )
  )
}

/**
 * Evaluates if an import failure is acceptable and should not be flagged.
 * Import failures are acceptable when there's a working alternative or when
 * the import is OS-specific for a different platform than the current one.
 */
predicate isAcceptableImportFailure(ImportExpr importStmt) {
  // Verify existence of a working fallback import
  findFallbackImport(importStmt).refersTo(_)
  or
  // Check if the import targets a different OS than the current platform
  identifyOSImport(importStmt) != getPlatform()
}

/**
 * Represents a control flow node performing Python interpreter version checks.
 * These nodes typically guard version-specific import statements.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
    exists(string versionAttribute |
      versionAttribute.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttribute))
    )
  }

  override string toString() { result = "VersionCheck" }
}

/**
 * Represents a conditional block that protects code based on interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Identify unresolved imports that should be reported as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isAcceptableImportFailure(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."