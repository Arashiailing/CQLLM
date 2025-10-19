/**
 * @name Unresolved import
 * @description Identifies import statements that cannot be resolved to any module,
 * potentially indicating missing dependencies or platform-specific imports that
 * may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import core Python analysis capabilities
import python

/**
 * Locates alternative imports that serve as fallbacks for primary imports.
 * This predicate identifies imports within conditional (if/else) or 
 * exception-handling (try/except) blocks that act as substitutes when
 * primary imports fail to resolve.
 */
ImportExpr locateFallbackImport(ImportExpr primaryImport) {
  // Ensure both primary and fallback imports have associated aliases
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary import alias relationship
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback import alias relationship
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Identify alternative imports in conditional structures
      exists(If conditionalBranch | 
        (conditionalBranch.getBody().contains(primaryImport) and conditionalBranch.getOrelse().contains(result)) or
        (conditionalBranch.getBody().contains(result) and conditionalBranch.getOrelse().contains(primaryImport))
      )
      or
      // Identify alternative imports in exception handling blocks
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(primaryImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an import is specific to a particular operating system.
 * Returns the OS identifier when the import is platform-dependent.
 */
string identifyPlatformSpecificImport(ImportExpr importStatement) {
  // Analyze imported module names for platform-specific patterns
  exists(string moduleName | moduleName = importStatement.getImportedModuleName() |
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
 * Retrieves the current operating system platform from the Python interpreter.
 */
string currentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an unresolved import should be considered acceptable.
 * An import failure is acceptable if it has a working alternative or is
 * platform-specific for a platform different from the current one.
 */
predicate isValidImportFailure(ImportExpr importStatement) {
  // Check for available alternative imports
  locateFallbackImport(importStatement).refersTo(_)
  or
  // Check for platform-specific imports on incompatible platforms
  identifyPlatformSpecificImport(importStatement) != currentPlatform()
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
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImport.getAFlowNode())) and // Import is in valid context
  not isValidImportFailure(unresolvedImport) and // Import failure is not acceptable
  not exists(VersionGuardedBlock versionGuard | versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."