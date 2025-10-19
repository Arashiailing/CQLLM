/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are initialized, which can cause runtime exceptions.
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

// Helper predicate to determine if a placeholder variable is initialized as a local variable
predicate isInitializedAsLocal(PlaceHolder variableUsage) {
  exists(SsaVariable ssaLocalVariable, Function enclosingFunction | 
    enclosingFunction = variableUsage.getScope() and 
    ssaLocalVariable.getAUse() = variableUsage.getAFlowNode() |
    ssaLocalVariable.getVariable() instanceof LocalVariable and
    not ssaLocalVariable.maybeUndefined()
  )
}

// Helper function to retrieve the enclosing class for a variable usage
Class getEnclosingClass(PlaceHolder variableUsage) { 
  result.getAMethod() = variableUsage.getScope() 
}

// Helper predicate to check if a variable is a template attribute within its enclosing class
predicate isTemplateAttribute(PlaceHolder variableUsage) {
  exists(ImportTimeScope classScope | 
    classScope = getEnclosingClass(variableUsage) and 
    classScope.definesName(variableUsage.getId())
  )
}

// Helper predicate to verify that a variable is not a global variable, module attribute, or monkey-patched builtin
predicate isNotGlobalVariable(PlaceHolder variableUsage) {
  // Ensure the variable is not a module attribute
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(variableUsage.getId()) and 
    moduleObject.getModule() = variableUsage.getEnclosingModule()
  ) and
  // Ensure the variable is not a globally defined name
  not globallyDefinedName(variableUsage.getId()) and
  // Ensure the variable is not a monkey-patched builtin
  not monkey_patched_builtin(variableUsage.getId())
}

// Main query to find undefined placeholder variables
from PlaceHolder undefinedPlaceholder
where
  // Exclude variables that are initialized as locals
  not isInitializedAsLocal(undefinedPlaceholder) and
  // Exclude variables that are template attributes
  not isTemplateAttribute(undefinedPlaceholder) and
  // Exclude variables that are global variables
  isNotGlobalVariable(undefinedPlaceholder)
select undefinedPlaceholder, "This use of place-holder variable '" + undefinedPlaceholder.getId() + "' may be undefined."