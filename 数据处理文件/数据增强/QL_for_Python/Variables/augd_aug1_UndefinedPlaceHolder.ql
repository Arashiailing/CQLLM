/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are initialized, which may cause runtime exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/undefined-placeholder-variable
 */

import python
import Variables.MonkeyPatched

// Helper function to retrieve the enclosing class containing the placeholder usage
Class getEnclosingClassForPlaceholder(PlaceHolder varUsage) { 
  result.getAMethod() = varUsage.getScope() 
}

// Checks if a placeholder is properly initialized as a local variable within its scope
predicate isPlaceholderInitializedLocally(PlaceHolder varUsage) {
  exists(SsaVariable ssaVariable, Function enclosingFunction | 
    enclosingFunction = varUsage.getScope() and 
    ssaVariable.getAUse() = varUsage.getAFlowNode() |
    ssaVariable.getVariable() instanceof LocalVariable and
    not ssaVariable.maybeUndefined()
  )
}

// Determines if a placeholder represents a template attribute defined in an import-time scope
predicate isPlaceholderTemplateAttribute(PlaceHolder varUsage) {
  exists(ImportTimeScope importScope | 
    importScope = getEnclosingClassForPlaceholder(varUsage) | 
    importScope.definesName(varUsage.getId())
  )
}

// Verifies that a placeholder is not defined as a global variable, monkey-patched builtin, or globally defined name
predicate isNotGlobalOrBuiltinPlaceholder(PlaceHolder varUsage) {
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(varUsage.getId()) and 
    moduleObject.getModule() = varUsage.getEnclosingModule()
  ) and
  not globallyDefinedName(varUsage.getId()) and
  not monkey_patched_builtin(varUsage.getId()) and
  not globallyDefinedName(varUsage.getId())
}

// Main query: Identifies and reports potentially undefined placeholder variable usages
from PlaceHolder targetPlaceholder
where
  not isPlaceholderInitializedLocally(targetPlaceholder) and
  not isPlaceholderTemplateAttribute(targetPlaceholder) and
  isNotGlobalOrBuiltinPlaceholder(targetPlaceholder)
select targetPlaceholder, "This use of placeholder variable '" + targetPlaceholder.getId() + "' may be undefined."