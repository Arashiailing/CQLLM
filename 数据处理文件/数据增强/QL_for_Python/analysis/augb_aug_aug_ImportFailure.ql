/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved and are not handled by fallback mechanisms
 *              or OS-specific guards. These unresolved imports may impact analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Retrieves a fallback import expression for a specified primary import.
 * The fallback import is located in an alternative branch (else or except) of a conditional or try-except block.
 */
ImportExpr findFallbackImport(ImportExpr mainImport) {
  // Ensure aliases exist for both the main and fallback imports
  exists(Alias mainAlias, Alias fallbackAlias |
    // Main alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Verify imports are in different branches of conditional statements
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(mainImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(mainImport))
      )
      or
      // Verify imports are in try and except blocks
      exists(Try exceptionHandler | 
        (exceptionHandler.getBody().contains(mainImport) and exceptionHandler.getAHandler().contains(result)) or
        (exceptionHandler.getBody().contains(result) and exceptionHandler.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines the operating system associated with an import expression, if it is OS-specific.
 * Returns the OS name (e.g., "win32", "darwin") for known OS-specific modules, otherwise no result.
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
 * Retrieves the current platform identifier from the Python interpreter's sys.platform.
 */
string getRuntimePlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import is acceptable (i.e., not a problem) because it has a fallback alternative
 * or is intended for a different operating system than the current one.
 */
predicate isUnresolvedImportAcceptable(ImportExpr importExpr) {
  // Check if there's a working fallback import
  findFallbackImport(importExpr).refersTo(_)
  or
  // Check if the import is OS-specific but not for the current OS
  identifyOSSpecificImport(importExpr) != getRuntimePlatform()
}

/**
 * Represents a control flow node that checks the Python interpreter version.
 * These nodes are used to conditionally import modules based on version compatibility.
 */
class PythonVersionCheckNode extends ControlFlowNode {
  PythonVersionCheckNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Represents a condition block that guards code based on the Python interpreter version.
 * This helps identify version-specific imports that should not be flagged as unresolved.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

// Main query: Find unresolved imports that should be flagged as issues
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in a valid context
  not isUnresolvedImportAcceptable(unresolvedImport) and // Import is not allowed to fail
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."