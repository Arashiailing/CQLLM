/**
 * @name Use of an undefined placeholder variable
 * @description Identifies placeholder variables that are referenced without prior initialization,
 *              potentially leading to runtime exceptions or unexpected behavior.
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

// Verifies if a placeholder variable is initialized within its local scope
predicate isInitializedLocally(PlaceHolder placeholderRef) {
  exists(SsaVariable localSsaVar, Function enclosingFunction | 
    enclosingFunction = placeholderRef.getScope() and 
    localSsaVar.getAUse() = placeholderRef.getAFlowNode() |
    localSsaVar.getVariable() instanceof LocalVariable and
    not localSsaVar.maybeUndefined()
  )
}

// Retrieves the class that contains the placeholder reference
Class getEnclosingClass(PlaceHolder placeholderRef) { 
  result.getAMethod() = placeholderRef.getScope() 
}

// Determines if the placeholder is a template attribute defined in a class
predicate isClassTemplateAttribute(PlaceHolder placeholderRef) {
  exists(ImportTimeScope classInitScope | 
    classInitScope = getEnclosingClass(placeholderRef) | 
    classInitScope.definesName(placeholderRef.getId())
  )
}

// Confirms the placeholder is not a global variable, module attribute, or patched builtin
predicate isNotGlobalVariable(PlaceHolder placeholderRef) {
  // Exclude module attributes, globally defined names, and monkey-patched builtins
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(placeholderRef.getId()) and 
    moduleObject.getModule() = placeholderRef.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholderRef.getId()) and
  not monkey_patched_builtin(placeholderRef.getId())
}

// Main query: Identifies placeholder variables that may be used without proper initialization
from PlaceHolder undefinedPlaceholder
where
  not isInitializedLocally(undefinedPlaceholder) and
  not isClassTemplateAttribute(undefinedPlaceholder) and
  isNotGlobalVariable(undefinedPlaceholder)
select undefinedPlaceholder, "This use of place-holder variable '" + undefinedPlaceholder.getId() + "' may be undefined."