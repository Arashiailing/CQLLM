/**
 * @name Use of an undefined placeholder variable
 * @description Detects placeholder variables that are used without proper initialization,
 *              which could result in runtime errors during program execution.
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

// Check if a placeholder variable is properly initialized within its local function scope
predicate isInitializedLocally(PlaceHolder placeholderVar) {
  exists(SsaVariable ssaVarDefinition, Function enclosingFunction | 
    enclosingFunction = placeholderVar.getScope() and 
    ssaVarDefinition.getAUse() = placeholderVar.getAFlowNode() |
    ssaVarDefinition.getVariable() instanceof LocalVariable and
    not ssaVarDefinition.maybeUndefined()
  )
}

// Find the class that encloses the placeholder variable
Class getEnclosingClass(PlaceHolder placeholderVar) { 
  result.getAMethod() = placeholderVar.getScope() 
}

// Determine if the placeholder is defined as an attribute within its enclosing class
predicate isDefinedAsClassAttribute(PlaceHolder placeholderVar) {
  exists(ImportTimeScope enclosingClass | 
    enclosingClass = getEnclosingClass(placeholderVar) | 
    enclosingClass.definesName(placeholderVar.getId())
  )
}

// Ensure the placeholder is not accessible globally, either as a module attribute,
// a monkey-patched builtin, or a globally defined name
predicate isNotGloballyAccessible(PlaceHolder placeholderVar) {
  not exists(PythonModuleObject globalModule |
    globalModule.hasAttribute(placeholderVar.getId()) and 
    globalModule.getModule() = placeholderVar.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholderVar.getId()) and
  not monkey_patched_builtin(placeholderVar.getId())
}

// Main query: Identify and report placeholder variables that may be undefined
from PlaceHolder problematicPlaceholder
where
  not isInitializedLocally(problematicPlaceholder) and
  not isDefinedAsClassAttribute(problematicPlaceholder) and
  isNotGloballyAccessible(problematicPlaceholder)
select problematicPlaceholder, "This use of placeholder variable '" + problematicPlaceholder.getId() + "' may be undefined."