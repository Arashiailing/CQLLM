/**
 * @name Use of an undefined placeholder variable
 * @description Detects placeholder variables used without proper initialization,
 *              which may cause runtime errors or unexpected behavior in Python code.
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

// Check if placeholder is initialized as a local variable
predicate initializedAsLocalVar(PlaceHolder placeholderUsage) {
  exists(SsaVariable ssaVar, Function enclosingFunc | 
    enclosingFunc = placeholderUsage.getScope() and 
    ssaVar.getAUse() = placeholderUsage.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// Retrieve containing class for placeholder usage
Class getContainingClass(PlaceHolder placeholderUsage) { 
  result.getAMethod() = placeholderUsage.getScope() 
}

// Check if placeholder is a template attribute
predicate isTemplateAttr(PlaceHolder placeholderUsage) {
  exists(ImportTimeScope classScope | 
    classScope = getContainingClass(placeholderUsage) | 
    classScope.definesName(placeholderUsage.getId())
  )
}

// Check if placeholder is NOT a module attribute
predicate notModuleAttr(PlaceHolder placeholderUsage) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(placeholderUsage.getId()) and 
    moduleObj.getModule() = placeholderUsage.getEnclosingModule()
  )
}

// Check if placeholder is NOT a monkey-patched builtin
predicate notMonkeyPatchedBuiltin(PlaceHolder placeholderUsage) {
  not monkey_patched_builtin(placeholderUsage.getId())
}

// Check if placeholder is NOT a globally defined name
predicate notGloballyDefined(PlaceHolder placeholderUsage) {
  not globallyDefinedName(placeholderUsage.getId())
}

// Combined check for non-global sources
predicate notGlobalVariable(PlaceHolder placeholderUsage) {
  notModuleAttr(placeholderUsage) and
  notMonkeyPatchedBuiltin(placeholderUsage) and
  notGloballyDefined(placeholderUsage)
}

// Main query: Find potentially undefined placeholder variables
from PlaceHolder problematicPlaceholder
where
  not initializedAsLocalVar(problematicPlaceholder) and
  not isTemplateAttr(problematicPlaceholder) and
  notGlobalVariable(problematicPlaceholder)
select problematicPlaceholder, "This use of placeholder variable '" + problematicPlaceholder.getId() + "' may be undefined."