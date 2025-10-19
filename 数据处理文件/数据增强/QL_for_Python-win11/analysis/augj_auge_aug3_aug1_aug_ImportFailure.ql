/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved to a module, which may lead to
 *              reduced analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Determines the current operating system platform from Python's system information.
 */
string getCurrentPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Identifies platform-specific imports and returns their target OS name.
 */
string getPlatformTarget(ImportExpr importExpr) {
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
 * Locates fallback imports used in conditional branches or exception handlers.
 */
ImportExpr getFallbackImport(ImportExpr primaryImport) {
  exists(Alias primaryAlias, Alias fallbackAlias |
    // Primary import alias mapping
    (primaryAlias.getValue() = primaryImport or primaryAlias.getValue().(ImportMember).getModule() = primaryImport) and
    // Fallback import alias mapping
    (fallbackAlias.getValue() = result or fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Conditional branch handling (both directions)
      exists(If conditional | 
        (conditional.getBody().contains(primaryImport) and conditional.getOrelse().contains(result)) or
        (conditional.getBody().contains(result) and conditional.getOrelse().contains(primaryImport))
      )
      or
      // Exception handling (both directions)
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(primaryImport) and exceptionBlock.getAHandler().contains(result)) or
        (exceptionBlock.getBody().contains(result) and exceptionBlock.getAHandler().contains(primaryImport))
      )
    )
  )
}

/**
 * Determines if an import failure is acceptable due to fallbacks or platform mismatch.
 */
predicate isAcceptableFailure(ImportExpr importExpr) {
  // Has working fallback import
  getFallbackImport(importExpr).refersTo(_)
  or
  // Platform-specific import for different OS
  getPlatformTarget(importExpr) != getCurrentPlatform()
}

/**
 * Control flow node that checks Python interpreter version.
 */
class VersionCheckNode extends ControlFlowNode {
  VersionCheckNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTest" }
}

/**
 * Conditional block guarded by version checks.
 */
class VersionGuardedBlock extends ConditionBlock {
  VersionGuardedBlock() { this.getLastNode() instanceof VersionCheckNode }
}

// Main query: Find problematic unresolved imports
from ImportExpr unresolvedImportExpr
where
  not unresolvedImportExpr.refersTo(_) and // Import cannot be resolved
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImportExpr.getAFlowNode())) and // Valid context
  not isAcceptableFailure(unresolvedImportExpr) and // No acceptable failure reason
  not exists(VersionGuardedBlock guard | guard.controls(unresolvedImportExpr.getAFlowNode().getBasicBlock(), _)) // Not version-guarded
select unresolvedImportExpr, "Unable to resolve import of '" + unresolvedImportExpr.getImportedModuleName() + "'."