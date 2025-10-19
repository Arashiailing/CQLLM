/**
 * @name Undefined Placeholder Variable Usage
 * @description Identifies instances where placeholder variables are utilized prior to initialization, potentially leading to runtime errors.
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
predicate isLocallyInitialized(PlaceHolder varUsage) {
  exists(SsaVariable localSSAVar, Function funcScope | 
    funcScope = varUsage.getScope() and 
    localSSAVar.getAUse() = varUsage.getAFlowNode() |
    localSSAVar.getVariable() instanceof LocalVariable and
    not localSSAVar.maybeUndefined()
  )
}

// Retrieves the enclosing class for a variable usage
Class getEnclosingClass(PlaceHolder varUsage) { 
  result.getAMethod() = varUsage.getScope() 
}

// Checks if a variable is a template attribute
predicate isTemplateAttribute(PlaceHolder varUsage) {
  exists(ImportTimeScope clsScope | 
    clsScope = getEnclosingClass(varUsage) | 
    clsScope.definesName(varUsage.getId())
  )
}

// Verifies that a variable is not a global variable
predicate isNotGlobal(PlaceHolder varUsage) {
  // Ensures the variable is not a module attribute, globally defined name, or monkey-patched builtin
  not exists(PythonModuleObject pyModule |
    pyModule.hasAttribute(varUsage.getId()) and 
    pyModule.getModule() = varUsage.getEnclosingModule()
  ) and
  not globallyDefinedName(varUsage.getId()) and
  not monkey_patched_builtin(varUsage.getId())
}

// Query for uninitialized placeholder variables
from PlaceHolder phVar
where
  // Excludes locally initialized variables, template attributes, and global variables
  not isLocallyInitialized(phVar) and
  not isTemplateAttribute(phVar) and
  isNotGlobal(phVar)
select phVar, "This use of place-holder variable '" + phVar.getId() + "' may be undefined."