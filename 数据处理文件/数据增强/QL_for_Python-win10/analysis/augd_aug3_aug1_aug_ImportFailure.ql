/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

/**
 * Retrieves the current operating system platform from the Python interpreter.
 */
string getCurrentOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

/**
 * Determines if an import is platform-specific and returns the platform name.
 */
string identifyOSSpecificImport(ImportExpr importExpr) {
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
 * Identifies fallback imports used in conditional logic or exception handling.
 */
ImportExpr findFallbackImport(ImportExpr sourceImport) {
  exists(Alias sourceAlias, Alias fallbackAlias |
    // Map source import to its alias
    (sourceAlias.getValue() = sourceImport or 
     sourceAlias.getValue().(ImportMember).getModule() = sourceImport) and
    // Map fallback import to its alias
    (fallbackAlias.getValue() = result or 
     fallbackAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check conditional branches (if/else)
      exists(If conditional | 
        conditional.getBody().contains(sourceImport) and 
        conditional.getOrelse().contains(result)
      )
      or
      exists(If conditional | 
        conditional.getBody().contains(result) and 
        conditional.getOrelse().contains(sourceImport)
      )
      or
      // Check exception handling (try/except)
      exists(Try tryBlock | 
        tryBlock.getBody().contains(sourceImport) and 
        tryBlock.getAHandler().contains(result)
      )
      or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and 
        tryBlock.getAHandler().contains(sourceImport)
      )
    )
  )
}

/**
 * Checks if an import failure is acceptable due to fallbacks or platform specificity.
 */
predicate isImportFailureAcceptable(ImportExpr importStatement) {
  // Has valid fallback import
  findFallbackImport(importStatement).refersTo(_)
  or
  // Platform-specific import for different OS
  identifyOSSpecificImport(importStatement) != getCurrentOSPlatform()
}

/**
 * Represents control flow nodes checking Python interpreter version.
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
 * Represents conditional blocks guarded by Python version checks.
 */
class VersionConditionalBlock extends ConditionBlock {
  VersionConditionalBlock() { this.getLastNode() instanceof PythonVersionCheckNode }
}

// Main query: Identify problematic unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context validContext | validContext.appliesTo(unresolvedImport.getAFlowNode())) and // Valid context
  not isImportFailureAcceptable(unresolvedImport) and // Not an acceptable failure
  not exists(VersionConditionalBlock guard | guard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)) // No version guard
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."