/**
 * @name Use of an undefined placeholder variable
 * @description Identifies placeholder variables that are used before being initialized, which can lead to runtime exceptions.
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

// Determine if a placeholder variable is initialized as a local variable within its scope
predicate isInitializedLocally(PlaceHolder variableUsage) {
  exists(SsaVariable localSsaVariable, Function containingFunction | 
    containingFunction = variableUsage.getScope() and 
    localSsaVariable.getAUse() = variableUsage.getAFlowNode() |
    localSsaVariable.getVariable() instanceof LocalVariable and
    not localSsaVariable.maybeUndefined()
  )
}

// Retrieve the enclosing class that contains the variable usage
Class getEnclosingClass(PlaceHolder variableUsage) { 
  result.getAMethod() = variableUsage.getScope() 
}

// Check if the variable is a template attribute defined in the class scope
predicate isTemplateAttribute(PlaceHolder variableUsage) {
  exists(ImportTimeScope classDefinition | 
    classDefinition = getEnclosingClass(variableUsage) and 
    classDefinition.definesName(variableUsage.getId())
  )
}

// Verify that the variable is not a global variable
predicate isNotGlobalVariable(PlaceHolder variableUsage) {
  // Ensure the variable is not a module attribute, globally defined name, or monkey-patched builtin
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(variableUsage.getId()) and 
    moduleObject.getModule() = variableUsage.getEnclosingModule()
  ) and
  not globallyDefinedName(variableUsage.getId()) and
  not monkey_patched_builtin(variableUsage.getId())
}

// Main query: Find placeholder variables that are used without initialization
from PlaceHolder placeholderVar
where
  // Exclude variables that are initialized locally, are template attributes, or are global variables
  not isInitializedLocally(placeholderVar) and
  not isTemplateAttribute(placeholderVar) and
  isNotGlobalVariable(placeholderVar)
select placeholderVar, "This use of place-holder variable '" + placeholderVar.getId() + "' may be undefined."