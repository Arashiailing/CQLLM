/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import Python analysis library
import python

// Helper function to locate alternative import expressions
ImportExpr locateAlternativeImport(ImportExpr originalExpr) {
  // Find aliases connecting original import to alternative import
  exists(Alias originalAlias, Alias alternativeAlias |
    (originalAlias.getValue() = originalExpr or 
     originalAlias.getValue().(ImportMember).getModule() = originalExpr) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Check if imports appear in different branches of conditional statements
      exists(If conditional | 
        conditional.getBody().contains(originalExpr) and 
        conditional.getOrelse().contains(result)
      )
      or
      exists(If conditional | 
        conditional.getBody().contains(result) and 
        conditional.getOrelse().contains(originalExpr)
      )
      or
      // Check if imports appear in try-except blocks
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(originalExpr) and 
        exceptionBlock.getAHandler().contains(result)
      )
      or
      exists(Try exceptionBlock | 
        exceptionBlock.getBody().contains(result) and 
        exceptionBlock.getAHandler().contains(originalExpr)
      )
    )
  )
}

// Helper function to determine OS-specific imports
string detectOSSpecificImport(ImportExpr importNode) {
  // Analyze module name patterns to identify OS specificity
  exists(string moduleName | moduleName = importNode.getImportedModuleName() |
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
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Predicate to determine if an import failure is acceptable
predicate isAcceptableFailure(ImportExpr importNode) {
  // Check for alternative imports or OS-specific mismatches
  locateAlternativeImport(importNode).refersTo(_)
  or
  detectOSSpecificImport(importNode) != getCurrentOS()
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
from ImportExpr unresolvedImportExpr
where
  // Import cannot be resolved
  not unresolvedImportExpr.refersTo(_) and 
  // Valid analysis context exists
  exists(Context context | context.appliesTo(unresolvedImportExpr.getAFlowNode())) and 
  // Failure is not acceptable
  not isAcceptableFailure(unresolvedImportExpr) and 
  // No version guard protects the import
  not exists(VersionGuardBlock versionGuard | 
    versionGuard.controls(unresolvedImportExpr.getAFlowNode().getBasicBlock(), _)
  )
select unresolvedImportExpr, "Unable to resolve import of '" + unresolvedImportExpr.getImportedModuleName() + "'."