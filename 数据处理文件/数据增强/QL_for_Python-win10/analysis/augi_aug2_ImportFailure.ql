/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved to any module,
 *              which may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import Python analysis library
import python

// Helper function to locate alternative import expressions
ImportExpr findAlternativeImport(ImportExpr targetImport) {
  // Check for aliases connecting target import to alternative import
  exists(Alias sourceAlias, Alias replacementAlias |
    (sourceAlias.getValue() = targetImport or 
     sourceAlias.getValue().(ImportMember).getModule() = targetImport) and
    (replacementAlias.getValue() = result or 
     replacementAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Verify imports appear in different if-statement branches
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(targetImport) and 
        conditionalStmt.getOrelse().contains(result)
      )
      or
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(result) and 
        conditionalStmt.getOrelse().contains(targetImport)
      )
      or
      // Verify imports appear in try-except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(targetImport) and 
        tryBlock.getAHandler().contains(result)
      )
      or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and 
        tryBlock.getAHandler().contains(targetImport)
      )
    )
  )
}

// Helper function to determine OS-specific imports
string identifyOSSpecificImport(ImportExpr importStatement) {
  // Analyze module name patterns to identify OS specificity
  exists(string importedModuleName | importedModuleName = importStatement.getImportedModuleName() |
    (
      // Java platform imports
      (importedModuleName.matches("org.python.%") or importedModuleName.matches("java.%")) and 
      result = "java"
    )
    or
    // macOS imports
    importedModuleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows imports
    (
      result = "win32" and
      (importedModuleName = "_winapi" or
       importedModuleName = "_win32api" or
       importedModuleName = "_winreg" or
       importedModuleName = "nt" or
       importedModuleName.matches("win32%") or
       importedModuleName = "ntpath")
    )
    or
    // Linux imports
    (
      result = "linux2" and
      (importedModuleName = "posix" or importedModuleName = "posixpath")
    )
    or
    // Unsupported platform imports
    (
      result = "unsupported" and
      (importedModuleName = "__pypy__" or 
       importedModuleName = "ce" or 
       importedModuleName.matches("riscos%"))
    )
  )
}

// Retrieve current operating system platform
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Predicate to determine if import failure is acceptable
predicate isAcceptableFailure(ImportExpr importStatement) {
  // Check for alternative imports or OS-specific mismatches
  findAlternativeImport(importStatement).refersTo(_)
  or
  identifyOSSpecificImport(importStatement) != getCurrentOS()
}

// Class representing version test nodes in control flow
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttributeName |
      versionAttributeName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttributeName))
    )
  }
  
  override string toString() { result = "VersionTest" }
}

/** A guard on the version of the Python interpreter */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionTestNode }
}

// Main query to detect unresolved imports
from ImportExpr failedImport
where
  not failedImport.refersTo(_) and // Import cannot be resolved
  exists(Context analysisContext | analysisContext.appliesTo(failedImport.getAFlowNode())) and // Valid context exists
  not isAcceptableFailure(failedImport) and // Failure is not acceptable
  not exists(VersionGuardBlock versionProtectionBlock | // No version guard protects the import
    versionProtectionBlock.controls(failedImport.getAFlowNode().getBasicBlock(), _)
  )
select failedImport, "Unable to resolve import of '" + failedImport.getImportedModuleName() + "'."