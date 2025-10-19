/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are used before initialization,
 *              potentially leading to runtime exceptions or undefined behavior.
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

// Determine if a placeholder variable is properly initialized as a local variable
// within its scope, ensuring it's not potentially undefined when accessed
predicate is_initialized_local(PlaceHolder varUsage) {
  exists(SsaVariable localSsaVariable, Function containingFunction | 
    containingFunction = varUsage.getScope() and 
    localSsaVariable.getAUse() = varUsage.getAFlowNode() |
    localSsaVariable.getVariable() instanceof LocalVariable and
    not localSsaVariable.maybeUndefined()
  )
}

// Retrieve the class that contains the usage of a placeholder variable
Class get_containing_class(PlaceHolder varUsage) { 
  result.getAMethod() = varUsage.getScope() 
}

// Check if the placeholder variable corresponds to a template attribute
// defined in the import-time scope of the containing class
predicate is_template_attribute(PlaceHolder varUsage) {
  exists(ImportTimeScope classScope | 
    classScope = get_containing_class(varUsage) | 
    classScope.definesName(varUsage.getId())
  )
}

// Verify that the placeholder variable is not a global variable
// by excluding module attributes, globally defined names, and monkey-patched builtins
predicate is_not_global_variable(PlaceHolder varUsage) {
  // Ensure the variable is not a module attribute
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(varUsage.getId()) and 
    moduleObject.getModule() = varUsage.getEnclosingModule()
  ) and
  // Ensure the variable is not a globally defined name
  not globallyDefinedName(varUsage.getId()) and
  // Ensure the variable is not a monkey-patched builtin
  not monkey_patched_builtin(varUsage.getId())
}

// Main query to identify placeholder variables that may be undefined at their usage point
from PlaceHolder placeholderVariable
where
  // Exclude variables that are properly initialized as local variables
  not is_initialized_local(placeholderVariable) and
  // Exclude variables that are template attributes
  not is_template_attribute(placeholderVariable) and
  // Exclude variables that are global variables
  is_not_global_variable(placeholderVariable)
select placeholderVariable, "This use of place-holder variable '" + placeholderVariable.getId() + "' may be undefined."