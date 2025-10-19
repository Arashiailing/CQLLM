/**
 * @name Use of an undefined placeholder variable
 * @description Detects placeholder variables used before initialization,
 *              which may cause runtime exceptions when accessed.
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

/**
 * Determines if a placeholder is properly initialized as a local variable
 * within its containing function scope.
 */
predicate isInitializedAsLocal(PlaceHolder ph) {
  exists(SsaVariable localVar, Function enclosingFunc |
    enclosingFunc = ph.getScope() and
    localVar.getAUse() = ph.getAFlowNode() and
    localVar.getVariable() instanceof LocalVariable and
    not localVar.maybeUndefined()
  )
}

/**
 * Retrieves the class that contains the placeholder usage.
 */
Class getEnclosingClass(PlaceHolder ph) {
  result.getAMethod() = ph.getScope()
}

/**
 * Checks if a placeholder corresponds to a template attribute
 * defined within its enclosing class.
 */
predicate isTemplateAttribute(PlaceHolder ph) {
  exists(ImportTimeScope enclosingClassScope |
    enclosingClassScope = getEnclosingClass(ph) and
    enclosingClassScope.definesName(ph.getId())
  )
}

/**
 * Verifies that a placeholder is neither a global variable,
 * monkey-patched builtin, nor globally defined name.
 */
predicate isNotGlobalVariable(PlaceHolder ph) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(ph.getId()) and
    moduleObj.getModule() = ph.getEnclosingModule()
  ) and
  not globallyDefinedName(ph.getId()) and
  not monkey_patched_builtin(ph.getId())
}

// Main query identifying undefined placeholder variables
from PlaceHolder ph
where
  not isInitializedAsLocal(ph) and
  not isTemplateAttribute(ph) and
  isNotGlobalVariable(ph)
select ph, "This use of place-holder variable '" + ph.getId() + "' may be undefined."