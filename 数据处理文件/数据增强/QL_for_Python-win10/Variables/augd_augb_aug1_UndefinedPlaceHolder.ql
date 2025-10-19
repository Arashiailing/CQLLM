/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are used without proper initialization,
 *              potentially leading to runtime errors.
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

// Determines if a placeholder reference is initialized within its local function scope
predicate initializedInLocalScope(PlaceHolder placeholderRef) {
  exists(SsaVariable ssaDefinition, Function funcContext | 
    funcContext = placeholderRef.getScope() and 
    ssaDefinition.getAUse() = placeholderRef.getAFlowNode() |
    ssaDefinition.getVariable() instanceof LocalVariable and
    not ssaDefinition.maybeUndefined()
  )
}

// Retrieves the class that contains the placeholder reference
Class findEnclosingClass(PlaceHolder placeholderRef) { 
  result.getAMethod() = placeholderRef.getScope() 
}

// Checks if the placeholder is defined as a template attribute within its containing class
predicate definedAsClassAttribute(PlaceHolder placeholderRef) {
  exists(ImportTimeScope classContext | 
    classContext = findEnclosingClass(placeholderRef) | 
    classContext.definesName(placeholderRef.getId())
  )
}

// Verifies that the placeholder is not defined globally, as a monkey-patched builtin, or as a global name
predicate notGloballyAccessible(PlaceHolder placeholderRef) {
  not exists(PythonModuleObject moduleEntity |
    moduleEntity.hasAttribute(placeholderRef.getId()) and 
    moduleEntity.getModule() = placeholderRef.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholderRef.getId()) and
  not monkey_patched_builtin(placeholderRef.getId())
}

// Main query: Identifies and reports potentially undefined placeholder variable usages
from PlaceHolder targetPlaceholder
where
  not initializedInLocalScope(targetPlaceholder) and
  not definedAsClassAttribute(targetPlaceholder) and
  notGloballyAccessible(targetPlaceholder)
select targetPlaceholder, "This use of placeholder variable '" + targetPlaceholder.getId() + "' may be undefined."