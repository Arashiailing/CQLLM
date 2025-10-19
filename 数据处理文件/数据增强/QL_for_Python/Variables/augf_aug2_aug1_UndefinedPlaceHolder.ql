/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are used without proper initialization,
 *              potentially leading to runtime errors or unexpected behavior in Python applications.
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

// Determine if a placeholder variable has been properly initialized as a local variable
// within its scope, ensuring it's not undefined at the point of use
predicate isProperlyInitializedAsLocal(PlaceHolder varRef) {
  exists(SsaVariable ssaVar, Function enclosingFunc | 
    enclosingFunc = varRef.getScope() and 
    ssaVar.getAUse() = varRef.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// Retrieve the class that contains the usage of the placeholder variable
// This helps in determining if the variable is a class attribute
Class findContainingClass(PlaceHolder varRef) { 
  result.getAMethod() = varRef.getScope() 
}

// Check if the placeholder variable is defined as a template attribute
// within the class definition scope
predicate isDefinedAsTemplateAttr(PlaceHolder varRef) {
  exists(ImportTimeScope classDefScope | 
    classDefScope = findContainingClass(varRef) | 
    classDefScope.definesName(varRef.getId())
  )
}

// Check if the placeholder variable is not defined as a module attribute
// This ensures we don't flag variables that are properly defined at module level
predicate isNotDefinedAsModuleAttr(PlaceHolder varRef) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(varRef.getId()) and 
    moduleObj.getModule() = varRef.getEnclosingModule()
  )
}

// Check if the placeholder variable is not a monkey-patched builtin
// Monkey-patched builtins are dynamically added to built-in modules
predicate isNotMonkeyPatched(PlaceHolder varRef) {
  not monkey_patched_builtin(varRef.getId())
}

// Check if the placeholder variable is not defined as a global name
// This helps identify variables that should be defined globally but aren't
predicate isNotGlobalName(PlaceHolder varRef) {
  not globallyDefinedName(varRef.getId())
}

// Combined check to ensure the placeholder variable is not defined globally
// in any form (module attribute, monkey-patched builtin, or global name)
predicate isNotDefinedGlobally(PlaceHolder varRef) {
  isNotDefinedAsModuleAttr(varRef) and
  isNotMonkeyPatched(varRef) and
  isNotGlobalName(varRef)
}

// Main query: Identify and report potentially undefined placeholder variable usages
// These are variables that are used without proper initialization in any scope
from PlaceHolder placeholderVar
where
  not isProperlyInitializedAsLocal(placeholderVar) and
  not isDefinedAsTemplateAttr(placeholderVar) and
  isNotDefinedGlobally(placeholderVar)
select placeholderVar, "This use of placeholder variable '" + placeholderVar.getId() + "' may be undefined."