/**
 * @name Unresolved import
 * @description Detects import statements that cannot be resolved, which may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import essential Python analysis capabilities
import python

/**
 * Identifies fallback imports that serve as alternatives to primary imports.
 * This predicate finds imports within conditional (if/else) or exception-handling (try/except) blocks
 * that act as substitutes when primary imports are unavailable.
 */
ImportExpr findFallbackImport(ImportExpr mainImport) {
  // Ensure both primary and fallback imports have associated aliases
  exists(Alias mainAlias, Alias substituteAlias |
    // Primary import alias relationship
    (mainAlias.getValue() = mainImport or mainAlias.getValue().(ImportMember).getModule() = mainImport) and
    // Fallback import alias relationship
    (substituteAlias.getValue() = result or substituteAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Identify alternative imports in conditional structures
      exists(If branchCondition | 
        (branchCondition.getBody().contains(mainImport) and branchCondition.getOrelse().contains(result)) or
        (branchCondition.getBody().contains(result) and branchCondition.getOrelse().contains(mainImport))
      )
      or
      // Identify alternative imports in exception handling blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(mainImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(mainImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS identifier when the import is platform-dependent.
 */
string detectPlatformSpecificImport(ImportExpr importExpr) {
  // Analyze imported module names for platform-specific patterns
  exists(string modName | modName = importExpr.getImportedModuleName() |
    // Java platform imports
    (modName.matches("org.python.%") or modName.matches("java.%")) and result = "java"
    or
    // macOS platform imports
    modName.matches("Carbon.%") and result = "darwin"
    or
    // Windows platform imports
    result = "win32" and
    (
      modName = "_winapi" or
      modName = "_win32api" or
      modName = "_winreg" or
      modName = "nt" or
      modName.matches("win32%") or
      modName = "ntpath"
    )
    or
    // Linux platform imports
    result = "linux2" and
    (modName = "posix" or modName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (modName = "__pypy__" or modName = "ce" or modName.matches("riscos%"))
  )
}

/**
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getRunningPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import should be considered acceptable.
 * An import failure is acceptable if it has a working alternative or is
 * platform-specific for a platform different from the current one.
 */
predicate isAcceptableImportFailure(ImportExpr importStatement) {
  // Check for available alternative imports
  findFallbackImport(importStatement).refersTo(_)
  or
  // Check for platform-specific imports on incompatible platforms
  detectPlatformSpecificImport(importStatement) != getRunningPlatform()
}

/**
 * Represents control flow nodes that evaluate Python interpreter version.
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
 * Represents conditional blocks that guard code based on interpreter version.
 * Used to identify version-specific imports that should not be flagged.
 */
class VersionGuardedBlock extends ConditionBlock {
  VersionGuardedBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context applicableContext | applicableContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isAcceptableImportFailure(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."