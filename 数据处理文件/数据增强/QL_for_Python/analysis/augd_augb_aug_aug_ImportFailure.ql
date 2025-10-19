/**
 * @name Unresolved import
 * @description Detects imports that fail to resolve and lack fallback mechanisms
 *              or OS-specific compatibility checks. These may reduce analysis completeness.
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
ImportExpr findFallbackImport(ImportExpr primaryImport) {
  // Verify both imports have associated aliases
  exists(Alias primaryAlias, Alias alternateAlias |
    // Primary import alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback import alias mapping
    (alternateAlias.getValue() = result or alternateAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional statement branches
      exists(If conditionalStmt | 
        (conditionalStmt.getBody().contains(primaryImport) and conditionalStmt.getOrelse().contains(result)) or
        (conditionalStmt.getBody().contains(result) and conditionalStmt.getOrelse().contains(primaryImport))
      )
      or
      // Check exception handler blocks
      exists(Try exceptionHandler | 
        (exceptionHandler.getBody().contains(primaryImport) and exceptionHandler.getAHandler().contains(result)) or
        (exceptionHandler.getBody().contains(result) and exceptionHandler.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Identifies the operating system associated with an import expression.
 * Returns OS name (e.g., "win32", "darwin") for platform-specific modules.
 */
string identifyOSSpecificImport(ImportExpr targetImport) {
  // Analyze imported module name for OS-specific patterns
  exists(string importedName | importedName = targetImport.getImportedModuleName() |
    // Java platform imports
    (importedName.matches("org.python.%") or importedName.matches("java.%")) and result = "java"
    or
    // macOS platform imports
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
 * Retrieves the current platform identifier from sys.platform.
 */
string getRuntimePlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import is acceptable due to fallback mechanisms
 * or platform-specific compatibility.
 */
predicate isUnresolvedImportAcceptable(ImportExpr targetImport) {
  // Check for working fallback import
  findFallbackImport(targetImport).refersTo(_)
  or
  // Check for OS-specific import on incompatible platform
  identifyOSSpecificImport(targetImport) != getRuntimePlatform()
}

/**
 * Represents control flow nodes checking Python interpreter version.
 * Used to identify version-specific imports.
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
 * Represents condition blocks guarding code based on Python version.
 * Helps identify version-specific imports that shouldn't be flagged.
 */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import resolution failed
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Valid context
  not isUnresolvedImportAcceptable(unresolvedImport) and // No acceptable failure reason
  not exists(VersionGuardBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."