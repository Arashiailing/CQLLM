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

// Check if variable is initialized as a local variable
predicate is_local_initialized(PlaceHolder varNode) {
  exists(SsaVariable localSsaVar, Function enclosingFunc | 
    enclosingFunc = varNode.getScope() and 
    localSsaVar.getAUse() = varNode.getAFlowNode() |
    localSsaVar.getVariable() instanceof LocalVariable and
    not localSsaVar.maybeUndefined()
  )
}

// Retrieve the enclosing class for variable usage
Class get_enclosing_class(PlaceHolder varNode) { 
  result.getAMethod() = varNode.getScope() 
}

// Check if variable is a template attribute
predicate is_template_attribute(PlaceHolder varNode) {
  exists(ImportTimeScope classDefScope | 
    classDefScope = get_enclosing_class(varNode) and 
    classDefScope.definesName(varNode.getId())
  )
}

// Verify variable is not a global entity
predicate is_not_global(PlaceHolder varNode) {
  // Ensure variable is not a module attribute, globally defined name, or monkey-patched builtin
  not exists(PythonModuleObject modObj |
    modObj.hasAttribute(varNode.getId()) and 
    modObj.getModule() = varNode.getEnclosingModule()
  ) and
  not globallyDefinedName(varNode.getId()) and
  not monkey_patched_builtin(varNode.getId())
}

// Query for uninitialized placeholder variables
from PlaceHolder undefinedVar
where
  // Exclude initialized locals, template attributes, and global variables
  not is_local_initialized(undefinedVar) and
  not is_template_attribute(undefinedVar) and
  is_not_global(undefinedVar)
select undefinedVar, "This use of place-holder variable '" + undefinedVar.getId() + "' may be undefined."