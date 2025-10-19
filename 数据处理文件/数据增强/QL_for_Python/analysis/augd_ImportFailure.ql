/**
 * @name Unresolved import
 * @description Detects unresolved import statements that may reduce analysis coverage and accuracy.
 * @kind problem
 * @problem.severity info
 * @id py/import-failure
 */

// Import Python analysis library
import python

// Helper function to identify alternative import expressions within conditional blocks
ImportExpr findAlternativeImport(ImportExpr importExpr) {
  // Check for aliases that map to either the current import or its module members
  exists(Alias currentAlias, Alias alternativeAlias |
    (currentAlias.getValue() = importExpr or 
     currentAlias.getValue().(ImportMember).getModule() = importExpr) and
    (alternativeAlias.getValue() = result or 
     alternativeAlias.getValue().(ImportMember).getModule() = result) and
    (
      // Verify if the imports appear in different branches of an if statement
      exists(If ifStmt | 
        ifStmt.getBody().contains(importExpr) and ifStmt.getOrelse().contains(result))
      or
      exists(If ifStmt | 
        ifStmt.getBody().contains(result) and ifStmt.getOrelse().contains(importExpr))
      or
      // Verify if the imports appear in try-except blocks
      exists(Try tryStmt | 
        tryStmt.getBody().contains(importExpr) and tryStmt.getAHandler().contains(result))
      or
      exists(Try tryStmt | 
        tryStmt.getBody().contains(result) and tryStmt.getAHandler().contains(importExpr))
    )
  )
}

// Determine if an import is specific to a particular operating system
string getOSSpecificImport(ImportExpr importExpr) {
  exists(string moduleName | moduleName = importExpr.getImportedModuleName() |
    // Java-specific imports
    (moduleName.matches("org.python.%") or moduleName.matches("java.%")) and result = "java"
    or
    // macOS-specific imports
    moduleName.matches("Carbon.%") and result = "darwin"
    or
    // Windows-specific imports
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
    // Linux-specific imports
    result = "linux2" and
    (moduleName = "posix" or moduleName = "posixpath")
    or
    // Unsupported platform imports
    result = "unsupported" and
    (moduleName = "__pypy__" or moduleName = "ce" or moduleName.matches("riscos%"))
  )
}

// Retrieve the current operating system platform
string getCurrentOS() { 
  py_flags_versioned("sys.platform", result, major_version().toString()) 
}

// Predicate to determine if an import failure is acceptable
predicate isAcceptableFailure(ImportExpr importExpr) {
  // Import has an alternative in conditional code
  findAlternativeImport(importExpr).refersTo(_)
  or
  // Import is OS-specific and doesn't match current platform
  getOSSpecificImport(importExpr) != getCurrentOS()
}

// Class representing version comparison nodes in control flow
class VersionTestNode extends ControlFlowNode {
  VersionTestNode() {
    exists(string versionAttr |
      versionAttr.matches("%version%") and
      this.(CompareNode).getAChild+().pointsTo(Module::named("sys").attr(versionAttr))
    )
  }

  override string toString() { result = "VersionTestNode" }
}

/** A conditional block that guards based on Python interpreter version */
class VersionGuardBlock extends ConditionBlock {
  VersionGuardBlock() { this.getLastNode() instanceof VersionTestNode }
}

// Main query to find unresolved imports that are not properly guarded
from ImportExpr importExpr
where
  // Import cannot be resolved to a module
  not importExpr.refersTo(_) and 
  // Import exists in a valid analysis context
  exists(Context context | context.appliesTo(importExpr.getAFlowNode())) and 
  // Import failure is not acceptable (no alternative or OS-specific handling)
  not isAcceptableFailure(importExpr) and 
  // No version guard protects this import
  not exists(VersionGuardBlock versionGuard | 
    versionGuard.controls(importExpr.getAFlowNode().getBasicBlock(), _))
select importExpr, "Unable to resolve import of '" + importExpr.getImportedModuleName() + "'."