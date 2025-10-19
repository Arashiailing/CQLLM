/**
 * @name Unresolved import
 * @description Identifies imports that fail to resolve without fallback mechanisms
 *              or OS-specific compatibility checks, potentially impacting analysis completeness.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import the Python analysis library
import python

/**
 * Locates a fallback import expression for a given primary import.
 * The fallback import resides in an alternative branch (else/except) of control structures.
 */
ImportExpr findFallbackImport(ImportExpr mainImport) {
  // Verify both imports have associated aliases
  exists(Alias mainAlias, Alias altAlias |
    // Primary import alias mapping
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback import alias mapping
    (altAlias.getValue() = result or altAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional statement branches
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(mainImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(mainImport))
      )
      or
      // Check exception handler blocks
      exists(Try exceptionHandler | 
        (exceptionHandler.getBody().contains(mainImport) and exceptionHandler.getAHandler().contains(result)) or
        (exceptionHandler.getBody().contains(result) and exceptionHandler.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Identifies the operating system associated with an import expression.
 * Returns OS name (e.g., "win32", "darwin") for platform-specific modules.
 */
string identifyOSSpecificImport(ImportExpr importExpr) {
  // Analyze imported module name for OS-specific patterns
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
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
 * Retrieves the current platform identifier from sys.platform.
 */
string getRuntimePlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import is acceptable due to fallback mechanisms
 * or platform-specific compatibility.
 */
predicate isUnresolvedImportAcceptable(ImportExpr importExpr) {
  // Check for working fallback import
  findFallbackImport(importExpr).refersTo(_)
  or
  // Check for OS-specific import on incompatible platform
  identifyOSSpecificImport(importExpr) != getRuntimePlatform()
}

/**
 * Represents control flow nodes checking Python interpreter version.
 * Used to identify version-specific imports.
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
 * Represents condition blocks guarding code based on Python version.
 * Helps identify version-specific imports that shouldn't be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr problematicImport
where
  not problematicImport.refersTo(_) and // Import resolution failed
  exists(Context context | context.appliesTo(problematicImport.getAFlowNode())) and // Valid context
  not isUnresolvedImportAcceptable(problematicImport) and // No acceptable failure reason
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(problematicImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select problematicImport, "Unable to resolve import of '" + problematicImport.getImportedModuleName() + "'."