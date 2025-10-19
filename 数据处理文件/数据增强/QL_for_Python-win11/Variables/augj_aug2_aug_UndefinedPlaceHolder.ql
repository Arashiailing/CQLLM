/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are utilized before initialization,
 *              potentially leading to runtime exceptions.
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

// Determines if a placeholder variable is initialized as a local variable
predicate is_initialized_locally(PlaceHolder variableReference) {
  exists(SsaVariable ssaLocalVariable, Function containingFunction | 
    containingFunction = variableReference.getScope() and 
    ssaLocalVariable.getAUse() = variableReference.getAFlowNode() |
    ssaLocalVariable.getVariable() instanceof LocalVariable and
    not ssaLocalVariable.maybeUndefined()
  )
}

// Retrieves the enclosing class for a variable reference
Class get_enclosing_class(PlaceHolder variableReference) { 
  result.getAMethod() = variableReference.getScope() 
}

// Checks if a variable is a template attribute within its class
predicate is_template_attribute(PlaceHolder variableReference) {
  exists(ImportTimeScope classDefinition | 
    classDefinition = get_enclosing_class(variableReference) and 
    classDefinition.definesName(variableReference.getId())
  )
}

// Verifies that a variable is not a global variable
predicate is_not_global(PlaceHolder variableReference) {
  // Ensure the variable is not a module attribute, globally defined name,
  // or monkey-patched built-in variable
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(variableReference.getId()) and 
    moduleObject.getModule() = variableReference.getEnclosingModule()
  ) and
  not globallyDefinedName(variableReference.getId()) and
  not monkey_patched_builtin(variableReference.getId())
}

// Main query to find uninitialized placeholder variables
from PlaceHolder uninitializedPlaceholder
where
  // Exclude variables that are initialized locally, are template attributes,
  // or are global variables
  not is_initialized_locally(uninitializedPlaceholder) and
  not is_template_attribute(uninitializedPlaceholder) and
  is_not_global(uninitializedPlaceholder)
select uninitializedPlaceholder, "This use of place-holder variable '" + uninitializedPlaceholder.getId() + "' may be undefined."