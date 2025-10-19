/**
 * @name Unresolved import
 * @description Detects import statements that cannot be resolved to any module,
 *              which may indicate missing dependencies or platform-specific code.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Retrieves the current operating system platform identifier from the Python interpreter.
 * Used to determine if platform-specific imports should be considered unresolved.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies platform-specific imports and returns their corresponding platform name.
 * Returns the platform identifier if the import is platform-specific.
 */
string identifyOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and 
    result = "java"
    or
    // macOS platform imports
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
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
    // Linux platform imports
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
  )
}

/**
 * Locates alternative import expressions used as fallbacks in conditional structures.
 * Identifies imports in if/else branches or try/except blocks that serve as alternatives.
 */
ImportExpr findAlternativeImport(ImportExpr primaryImport) {
  exists(Alias primaryAlias, Alias alternativeAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback alias mapping
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional branches for alternative imports
      exists(If ifStmt | 
        (ifStmt.getBody().contains(primaryImport) and ifStmt.getOrelse().contains(result)) or
        (ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(primaryImport))
      )
      or
      // Check exception handling blocks for alternative imports
      exists(Try tryStmt | 
        (tryStmt.getBody().contains(primaryImport) and tryStmt.getAHandler().contains(result)) or
        (tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an unresolved import should be considered acceptable.
 * An import is acceptable if it has a working alternative or is platform-specific
 * for a different platform than the current one.
 */
predicate isImportFailureAcceptable(ImportExpr importExpr) {
  // Check for valid alternative imports
  findAlternativeImport(importExpr).refersTo(_)
  or
  // Check for platform-specific imports on different platforms
  identifyOSSpecificImport(importExpr) != getCurrentPlatform()
}

/**
 * Represents control flow nodes that check Python interpreter version.
 * Typically used for version-specific conditional imports.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents conditional blocks guarded by version checks.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isImportFailureAcceptable(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."