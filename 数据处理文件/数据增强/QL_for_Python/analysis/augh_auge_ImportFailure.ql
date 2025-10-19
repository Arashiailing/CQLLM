/**
 * @name Unresolved import
 * @description An unresolved import may result in reduced coverage and accuracy of analysis.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

import python

// Helper function to locate alternative import expressions in control flow structures
ImportExpr locateAlternativeImport(ImportExpr initialImport) {
  exists(Alias sourceAlias, Alias targetAlias |
    // Establish alias relationship between initial and alternative imports
    (sourceAlias.getValue() = initialImport or 
     sourceAlias.getValue().(ImportMember).getModule() = initialImport) and
    (targetAlias.getValue() = result or 
     targetAlias.getValue().(ImportMember).getModule() = result) and
    // Check control flow structures containing both imports
    (
      // If-statement branches (both directions)
      exists(If branch | 
        (branch.getBody().contains(initialImport) and branch.getOrelse().contains(result)) or
        (branch.getBody().contains(result) and branch.getOrelse().contains(initialImport))
      ) or
      // Try-except blocks (both directions)
      exists(Try tryBlock | 
        (tryBlock.getBody().contains(initialImport) and tryBlock.getAHandler().contains(result)) or
        (tryBlock.getBody().contains(result) and tryBlock.getAHandler().contains(initialImport))
      )
    )
  )
}

// Identify platform-specific imports and return target platform name
string determinePlatformSpecificImport(ImportExpr importStatement) {
  exists(string moduleName | moduleName = importStatement.getImportedModuleName() |
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
string getRuntimePlatform() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Determine if an import is permitted to fail
predicate isImportFailureAllowed(ImportExpr importStatement) {
  // Check for alternative imports
  locateAlternativeImport(importStatement).refersTo(_)
  or
  // Check platform-specific imports mismatch
  determinePlatformSpecificImport(importStatement) != getRuntimePlatform()
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
from ImportExpr importStatement
where
  // Import cannot be resolved
  not importStatement.refersTo(_) and
  // Import exists in analyzable context
  exists(Context analysisContext | analysisContext.appliesTo(importStatement.getAFlowNode())) and
  // Import is not permitted to fail
  not isImportFailureAllowed(importStatement) and
  // No version guard protects this import
  not exists(VersionGuardBlock versionGuard | 
    versionGuard.controls(importStatement.getAFlowNode().getBasicBlock(), _)
  )
select importStatement, "Unable to resolve import of '" + importStatement.getImportedModuleName() + "'."