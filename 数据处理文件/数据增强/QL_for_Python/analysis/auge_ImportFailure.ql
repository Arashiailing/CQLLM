/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

// Helper function to find alternative import expressions in control flow structures
ImportExpr findAlternativeImport(ImportExpr originalImport) {
  exists(Alias currentAlias, Alias alternativeAlias |
    // Establish alias relationship between original and alternative imports
    (currentAlias.getValue() = originalImport or 
     currentAlias.getValue().(ImportMember).getModule() = originalImport) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    // Check control flow structures containing both imports
    (
      // If-statement branches
      exists(If branch | 
        branch.getBody().contains(originalImport) and branch.getOrelse().contains(result)
      ) or
      exists(If branch | 
        branch.getBody().contains(result) and branch.getOrelse().contains(originalImport)
      ) or
      // Try-except blocks
      exists(Try tryBlock | 
        tryBlock.getBody().contains(originalImport) and tryBlock.getAHandler().contains(result)
      ) or
      exists(Try tryBlock | 
        tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(originalImport)
      )
    )
  )
}

// Identify OS-specific imports and return target OS name
string identifyOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java platform imports
    (moduleName.matches("org.python.%") and result = "java") or
    (moduleName.matches("java.%") and result = "java") or
    // macOS imports
    (moduleName.matches("Carbon.%") and result = "darwin") or
    // Windows imports
    (result = "win32" and
      (moduleName = "_winapi" or moduleName = "_win32api" or moduleName = "_winreg" or
       moduleName = "nt" or moduleName.matches("win32%") or moduleName = "ntpath")
    ) or
    // Linux imports
    (result = "linux2" and
      (moduleName = "posix" or moduleName = "posixpath")
    ) or
    // Unsupported platforms
    (result = "unsupported" and
      (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
    )
  )
}

// Retrieve current OS platform information
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Determine if an import is allowed to fail
predicate isImportAllowedToFail(ImportExpr importExpr) {
  // Check for alternative imports
  findAlternativeImport(importExpr).refersTo(_)
  or
  // Check OS-specific imports mismatch
  identifyOSSpecificImport(importExpr) != getCurrentOS()
}

// Represents version comparison nodes in control flow
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttrName |
      versionAttrName.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttrName))
    )
  }
  override string toString() { result = "VersionTest" }
}

// Represents version guard blocks in control flow
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionTestNode }
}

// Main query: Find unresolved imports without valid fallbacks
from ImportExpr importExpr
where
  // Import cannot be resolved
  not importExpr.refersTo(_) and
  // Import exists in analyzable context
  exists(Context analysisContext | analysisContext.appliesTo(importExpr.getAFlowNode())) and
  // Import is not allowed to fail
  not isImportAllowedToFail(importExpr) and
  // No version guard protects this import
  not exists(VersionGuardBlock versionGuard | 
    versionGuard.controls(importExpr.getAFlowNode().getBasicBlock(), _)
  )
select importExpr, "Unable to resolve import of '" + importExpr.getImportedModuleName() + "'."