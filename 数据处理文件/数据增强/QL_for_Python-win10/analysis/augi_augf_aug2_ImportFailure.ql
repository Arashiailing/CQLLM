/**
 * @name Unresolved import
 * @description Identifies imports that cannot be resolved, which may reduce analysis coverage and accuracy
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import Python analysis library
import python

// Helper function to find alternative import expressions within conditional structures
ImportExpr findAlternativeImport(ImportExpr originalImport) {
  // Locate aliases linking original import to alternative import
  exists(Alias originalAlias, Alias alternativeAlias |
    (originalAlias.getValue() = originalImport or 
     originalAlias.getValue().(ImportMember).getModule() = originalImport) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check imports in different branches of conditional statements
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(originalImport) and 
        conditionalStmt.getOrelse().contains(result)
      )
      or
      exists(If conditionalStmt | 
        conditionalStmt.getBody().contains(result) and 
        conditionalStmt.getOrelse().contains(originalImport)
      )
      or
      // Check imports in try-except blocks
      exists(Try exceptionHandler | 
        exceptionHandler.getBody().contains(originalImport) and 
        exceptionHandler.getAHandler().contains(result)
      )
      or
      exists(Try exceptionHandler | 
        exceptionHandler.getBody().contains(result) and 
        exceptionHandler.getAHandler().contains(originalImport)
      )
    )
  )
}

// Helper function to identify OS-specific import patterns
string getOSSpecificImportType(ImportExpr importStatement) {
  // Analyze module name patterns to determine OS specificity
  exists(string moduleName | moduleName = importStatement.getImportedModuleName() |
    (
      (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and 
      result = "java"
    )
    or
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    (
      result = "win32" and
      (
        moduleName = "_winapi" or
        moduleName = "_win32api" or
        moduleName = "_winreg" or
        moduleName = "nt" or
        moduleName.matches("win32%") or
        moduleName = "ntpath"
      )
    )
    or
    (
      result = "linux2" and
      (moduleName = "posix" or moduleName = "posixpath")
    )
    or
    (
      result = "unsupported" and
      (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
    )
  )
}

// Retrieve current operating system platform
string getRunningOSPlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Predicate to determine if an import failure is acceptable
predicate isImportFailureAcceptable(ImportExpr importStatement) {
  // Check for alternative imports or OS-specific mismatches
  findAlternativeImport(importStatement).refersTo(_)
  or
  getOSSpecificImportType(importStatement) != getRunningOSPlatform()
}

// Class representing version test nodes in control flow
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }
  
  override string toString() { result = "VersionTest" }
}

/** A guard on the version of the Python interpreter */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionTestNode }
}

// Main query to identify unresolved imports
from ImportExpr unresolvedImport
where
  // Import cannot be resolved
  not unresolvedImport.refersTo(_) and 
  // Valid analysis context exists
  exists(Context analysisContext | analysisContext.appliesTo(unresolvedImport.getAFlowNode())) and 
  // Failure is not acceptable
  not isImportFailureAcceptable(unresolvedImport) and 
  // No version guard protects the import
  not exists(VersionGuardBlock versionGuard | 
    versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)
  )
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."