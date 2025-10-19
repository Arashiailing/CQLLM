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
ImportExpr findAlternativeImport(ImportExpr originalImportExpr) {
  // Identify aliases linking original import to alternative import
  exists(Alias originalAlias, Alias alternativeAlias |
    (originalAlias.getValue() = originalImportExpr or 
     originalAlias.getValue().(ImportMember).getModule() = originalImportExpr) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check imports in different if-statement branches
      exists(If conditionalBlock | 
        (conditionalBlock.getBody().contains(originalImportExpr) and 
         conditionalBlock.getOrelse().contains(result))
        or
        (conditionalBlock.getBody().contains(result) and 
         conditionalBlock.getOrelse().contains(originalImportExpr))
      )
      or
      // Check imports in try-except blocks
      exists(Try exceptionBlock | 
        (exceptionBlock.getBody().contains(originalImportExpr) and 
         exceptionBlock.getAHandler().contains(result))
        or
        (exceptionBlock.getBody().contains(result) and 
         exceptionBlock.getAHandler().contains(originalImportExpr))
      )
    )
  )
}

// Helper function to identify OS-specific imports
string identifyOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") and result = "java")
    or
    (moduleName.matches("java.%") and result = "java")
    or
    // Darwin platform imports
    (moduleName.matches("Carbon.%") and result = "darwin")
    or
    // Windows platform imports
    (result = "win32" and
      (moduleName = "_winapi" or
       moduleName = "_win32api" or
       moduleName = "_winreg" or
       moduleName = "nt" or
       moduleName.matches("win32%") or
       moduleName = "ntpath")
    )
    or
    // Linux platform imports
    (result = "linux2" and
      (moduleName = "posix" or moduleName = "posixpath")
    )
    or
    // Unsupported platform imports
    (result = "unsupported" and
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
  // Check for alternative imports or OS mismatch
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
from ImportExpr unresolvedImportExpr
where
  not unresolvedImportExpr.refersTo(_) and // Import cannot be resolved
  exists(Context context | context.appliesTo(unresolvedImportExpr.getAFlowNode())) and // Valid context exists
  not isAcceptableFailure(unresolvedImportExpr) and // Failure is not acceptable
  not exists(VersionGuardBlock versionGuard | // No version guard protects the import
    versionGuard.controls(unresolvedImportExpr.getAFlowNode().getBasicBlock(), _)
  )
select unresolvedImportExpr, "Unable to resolve import of '" + unresolvedImportExpr.getImportedModuleName() + "'."