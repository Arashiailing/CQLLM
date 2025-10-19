/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are properly initialized,
 *              which can lead to runtime exceptions.
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

// Check if the placeholder is initialized as a local variable within its scope
predicate is_local_initialized(PlaceHolder varUse) {
  exists(SsaVariable localVar, Function containingFunction | 
    containingFunction = varUse.getScope() and 
    localVar.getAUse() = varUse.getAFlowNode() |
    localVar.getVariable() instanceof LocalVariable and
    not localVar.maybeUndefined()
  )
}

// Retrieve the enclosing class for a placeholder variable usage
Class get_enclosing_class(PlaceHolder varUse) { 
  result.getAMethod() = varUse.getScope() 
}

// Determine if the placeholder corresponds to a template attribute
predicate is_template_attr(PlaceHolder varUse) {
  exists(ImportTimeScope classScope | 
    classScope = get_enclosing_class(varUse) | 
    classScope.definesName(varUse.getId())
  )
}

// Verify that the placeholder is not a global variable or a monkey-patched builtin
predicate is_not_global_var(PlaceHolder varUse) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(varUse.getId()) and 
    moduleObj.getModule() = varUse.getEnclosingModule()
  ) and
  not globallyDefinedName(varUse.getId()) and
  not monkey_patched_builtin(varUse.getId()) and
  not globallyDefinedName(varUse.getId())
}

// Main query: Identify and report potentially undefined placeholder variable usages
from PlaceHolder placeholderVar
where
  not is_local_initialized(placeholderVar) and // Exclude locally initialized variables
  not is_template_attr(placeholderVar) and     // Exclude template attributes
  is_not_global_var(placeholderVar)           // Exclude global variables
select placeholderVar, "This use of place-holder variable '" + placeholderVar.getId() + "' may be undefined."