/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved and lack proper fallback mechanisms
 *              or OS-specific guards. These unresolved imports may impact analysis coverage.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Represents a control flow node that examines the Python interpreter version.
 * These nodes are utilized to conditionally import modules based on version compatibility.
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
 * Represents a conditional block that shields code based on the Python interpreter version.
 * This assists in identifying version-specific imports that should not be marked as unresolved.
 */
class VersionBasedGuard extends ConditionBlock {
  VersionBasedGuard() { this.getLastNode() instanceof InterpreterVersionTest }
}

/**
 * Retrieves the platform identifier from the Python interpreter's sys.platform attribute.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines the operating system linked to an import expression when it's OS-specific.
 * Returns the OS identifier (e.g., "win32", "darwin") for recognized OS-specific modules, otherwise returns nothing.
 */
string determineOSSpecificImport(ImportExpr importExpr) {
  // Verify if the imported module name corresponds to OS-specific patterns
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
 * Retrieves a fallback import expression for a specified primary import.
 * The fallback import is positioned in a different branch (else or except) of a conditional or try-except structure.
 */
ImportExpr getAlternativeImport(ImportExpr mainImport) {
  // Ensure aliases exist for both primary and fallback imports
  exists(Alias mainAlias, Alias backupAlias |
    // Primary alias relationship
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback alias relationship
    (backupAlias.getValue() = result or backupAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports are in separate branches of conditional statements
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(mainImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(mainImport))
      )
      or
      // Check if imports are in try and except blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(mainImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines whether an unresolved import is acceptable (not problematic) due to having a fallback alternative
 * or being designed for a different operating system than the current one.
 */
predicate isImportAcceptableToFail(ImportExpr importExpr) {
  // Verify if there's a functioning alternative import
  getAlternativeImport(importExpr).refersTo(_)
  or
  // Verify if the import is OS-specific but not intended for the current OS
  determineOSSpecificImport(importExpr) != getCurrentPlatform()
}

// Main query: Identify unresolved imports that should be flagged as issues
from ImportExpr brokenImport
where
  not brokenImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(brokenImport.getAFlowNode())) and // Import is in a valid context
  not isImportAcceptableToFail(brokenImport) and // Import is not allowed to fail
  not exists(VersionBasedGuard versionGuard | versionGuard.controls(brokenImport.getAFlowNode().getBasicBlock(), _)) // Not protected by version guard
select brokenImport, "Unable to resolve import of '" + brokenImport.getImportedModuleName() + "'."