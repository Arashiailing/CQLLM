/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are utilized without proper initialization,
 * potentially leading to runtime errors and unexpected behavior.
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

// Determine if the placeholder variable has been initialized as a local variable within its scope
predicate initializedAsLocalVar(PlaceHolder phVar) {
  exists(SsaVariable ssaVar, Function enclosingFunction | 
    enclosingFunction = phVar.getScope() and 
    ssaVar.getAUse() = phVar.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// Retrieve the class that contains the usage of the placeholder variable
Class findEnclosingClass(PlaceHolder phVar) { 
  result.getAMethod() = phVar.getScope() 
}

// Check if the placeholder variable represents a template attribute within its enclosing class
predicate isClassTemplateAttribute(PlaceHolder phVar) {
  exists(ImportTimeScope classDefScope | 
    classDefScope = findEnclosingClass(phVar) | 
    classDefScope.definesName(phVar.getId())
  )
}

// Verify that the placeholder variable is not a global variable, a monkey-patched built-in, or globally defined
predicate isNonGlobalVar(PlaceHolder phVar) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(phVar.getId()) and 
    moduleObj.getModule() = phVar.getEnclosingModule()
  ) and
  not globallyDefinedName(phVar.getId()) and
  not monkey_patched_builtin(phVar.getId())
}

// Main query: Identify and report potentially undefined placeholder variable usages
from PlaceHolder phVar
where
  not initializedAsLocalVar(phVar) and
  not isClassTemplateAttribute(phVar) and
  isNonGlobalVar(phVar)
select phVar, "This use of placeholder variable '" + phVar.getId() + "' may be undefined."