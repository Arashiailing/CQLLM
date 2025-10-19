/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import Python analysis library
import python

// Helper function to find alternative import expressions
ImportExpr findAlternativeImport(ImportExpr originalImport) {
  // Check for aliases linking current import to alternative import
  exists(Alias currentAlias, Alias alternativeAlias |
    (currentAlias.getValue() = originalImport or 
     currentAlias.getValue().(ImportMember).getModule() = originalImport) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if current and alternative imports appear in different branches of if statements
      exists(If ifStmt | 
        ifStmt.getBody().contains(originalImport) and 
        ifStmt.getOrelse().contains(result)
      )
      or
      exists(If ifStmt | 
        ifStmt.getBody().contains(result) and 
        ifStmt.getOrelse().contains(originalImport)
      )
      or
      // Check if current and alternative imports appear in try-except blocks
      exists(Try tryStmt | 
        tryStmt.getBody().contains(originalImport) and 
        tryStmt.getAHandler().contains(result)
      )
      or
      exists(Try tryStmt | 
        tryStmt.getBody().contains(result) and 
        tryStmt.getAHandler().contains(originalImport)
      )
    )
  )
}

// Helper function to identify OS-specific imports
string identifyOSSpecificImport(ImportExpr importExpr) {
  // Check module name patterns to determine OS specificity
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    (
      moduleName.matches("org.python.%") and result = "java"
      or
      moduleName.matches("java.%") and result = "java"
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
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Predicate to determine if an import failure is acceptable
predicate isAcceptableFailure(ImportExpr importExpr) {
  // Check if alternative import exists or if OS-specific import doesn't match current OS
  findAlternativeImport(importExpr).refersTo(_)
  or
  identifyOSSpecificImport(importExpr) != getCurrentOS()
}

// Class representing version test nodes in control flow
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
    )
  }
  
  override string toString() { result = "VersionTest" }
}

/** A guard on the version of the Python interpreter */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionTestNode }
}

// Main query to find unresolved imports
from ImportExpr unresolvedImport
where
  not unresolvedImport.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImport.getAFlowNode())) and // Valid context exists
  not isAcceptableFailure(unresolvedImport) and // Failure is not acceptable
  not exists(VersionGuardBlock versionGuard | // No version guard protects the import
    versionGuard.controls(unresolvedImport.getAFlowNode().getBasicBlock(), _)
  )
select unresolvedImport, "Unable to resolve import of '" + unresolvedImport.getImportedModuleName() + "'."