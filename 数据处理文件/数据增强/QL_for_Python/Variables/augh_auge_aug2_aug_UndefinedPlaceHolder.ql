/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before initialization, potentially causing runtime exceptions.
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

// Determines if a placeholder variable is properly initialized as a local variable
predicate isLocalInitialized(PlaceHolder placeholderVar) {
  exists(SsaVariable ssaVar, Function func | 
    func = placeholderVar.getScope() and 
    ssaVar.getAUse() = placeholderVar.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// Retrieves the class enclosing the variable usage scope
Class getEnclosingClass(PlaceHolder placeholderVar) { 
  result.getAMethod() = placeholderVar.getScope() 
}

// Checks if variable is defined as a template attribute in its enclosing class
predicate isClassTemplateAttribute(PlaceHolder placeholderVar) {
  exists(ImportTimeScope clsScope | 
    clsScope = getEnclosingClass(placeholderVar) and 
    clsScope.definesName(placeholderVar.getId())
  )
}

// Verifies variable is not a global, module attribute, or monkey-patched builtin
predicate isNonGlobalVariable(PlaceHolder placeholderVar) {
  // Exclude module attributes
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(placeholderVar.getId()) and 
    moduleObj.getModule() = placeholderVar.getEnclosingModule()
  ) and
  // Exclude globally defined names
  not globallyDefinedName(placeholderVar.getId()) and
  // Exclude monkey-patched builtins
  not monkey_patched_builtin(placeholderVar.getId())
}

// Main detection logic for undefined placeholder variables
from PlaceHolder undefinedPlaceholder
where
  // Filter out properly initialized locals
  not isLocalInitialized(undefinedPlaceholder) and
  // Filter out class template attributes
  not isClassTemplateAttribute(undefinedPlaceholder) and
  // Filter out global variables
  isNonGlobalVariable(undefinedPlaceholder)
select undefinedPlaceholder, "This use of place-holder variable '" + undefinedPlaceholder.getId() + "' may be undefined."