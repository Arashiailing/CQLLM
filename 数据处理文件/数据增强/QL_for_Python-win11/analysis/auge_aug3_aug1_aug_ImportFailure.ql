/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved to a module, which may lead to
 *              reduced analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis module
import python

/**
 * Retrieves the operating system platform from the Python interpreter's system information.
 */
string determineOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an import is designed for a specific operating system.
 * Returns the corresponding OS name if the import is platform-specific.
 */
string getOSSpecificImportName(ImportExpr importDeclaration) {
  // Verify if the imported module matches platform-specific patterns
  exists(string moduleName | moduleName = importDeclaration.getImportedModuleName() |
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
 * Locates alternative import expressions that act as fallback imports.
 * This function identifies imports used in conditional branches (if/else) or 
 * exception handling blocks (try/except) as alternatives to each other.
 */
ImportExpr getAlternativeImport(ImportExpr primaryImport) {
  // Ensure aliases exist for both the primary and alternative imports
  exists(Alias primaryAlias, Alias alternativeAlias |
    // Primary alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Alternative alias mapping
    (alternativeAlias.getValue() = result or alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in different branches of conditional statements
      exists(If conditionalStatement | 
        conditionalStatement.getBody().contains(primaryImport) and conditionalStatement.getOrelse().contains(result)
      )
      or
      exists(If conditionalStatement | 
        conditionalStatement.getBody().contains(result) and conditionalStatement.getOrelse().contains(primaryImport)
      )
      or
      // Check if imports are in try and except blocks
      exists(Try exceptionHandler | 
        exceptionHandler.getBody().contains(primaryImport) and exceptionHandler.getAHandler().contains(result)
      )
      or
      exists(Try exceptionHandler | 
        exceptionHandler.getBody().contains(result) and exceptionHandler.getAHandler().contains(primaryImport)
      )
    )
  )
}

/**
 * Evaluates whether an import is allowed to fail without being reported as an issue.
 * An import is considered acceptable to fail if it has an alternative or if it's 
 * designed for a different OS than the current one.
 */
predicate isImportFailurePermitted(ImportExpr importStatement) {
  // Check if there's a functioning alternative import
  getAlternativeImport(importStatement).refersTo(_)
  or
  // Check if the import is platform-specific but not for the current platform
  getOSSpecificImportName(importStatement) != determineOSPlatform()
}

/**
 * Represents a control flow node that evaluates the Python interpreter version.
 * These nodes typically conditionally import modules based on version compatibility.
 */
class VersionCheckControlNode extends ControlFlowNode {
  VersionCheckControlNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents a conditional block that guards code based on the Python interpreter version.
 * This helps identify version-specific imports that should not be flagged.
 */
class VersionGuardedBlock extends ConditionBlock {
  VersionGuardedBlock() { this.getLastNode() instanceof VersionCheckControlNode }
}

// Main query: Detect unresolved imports that should be reported as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isImportFailurePermitted(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."