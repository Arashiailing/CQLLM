/**
 * @name Use of an undefined placeholder variable
 * @description Identifies placeholder variables that are accessed without proper initialization,
 *              potentially leading to runtime errors during execution.
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
 * Checks whether a placeholder is correctly initialized as a local variable
 * within its function context. This predicate confirms the existence of an
 * SSA variable representing a local variable that is utilized at the
 * placeholder's flow node and is not potentially undefined.
 */
predicate isInitializedAsLocal(PlaceHolder ph) {
  exists(SsaVariable ssaVar, Function funcScope |
    funcScope = ph.getScope() and
    ssaVar.getAUse() = ph.getAFlowNode() and
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

/**
 * Obtains the class that encompasses the placeholder usage.
 * This auxiliary predicate identifies the containing class by verifying
 * if the placeholder's scope is a method belonging to that class.
 */
Class getEnclosingClass(PlaceHolder ph) {
  result.getAMethod() = ph.getScope()
}

/**
 * Determines if a placeholder matches a template attribute
 * declared within its containing class. This predicate confirms
 * whether the placeholder's identifier is declared in the
 * import-time scope of its containing class.
 */
predicate isTemplateAttribute(PlaceHolder ph) {
  exists(ImportTimeScope importScope |
    importScope = getEnclosingClass(ph) and
    importScope.definesName(ph.getId())
  )
}

/**
 * Confirms that a placeholder is neither a global variable,
 * monkey-patched builtin, nor a globally defined name. This predicate
 * ensures the placeholder is not declared as an attribute in
 * the containing module, not a globally defined name, and not a
 * monkey-patched builtin.
 */
predicate isNotGlobalVariable(PlaceHolder ph) {
  // Verify the placeholder is not defined as an attribute in the enclosing module
  not exists(PythonModuleObject modObj |
    modObj.hasAttribute(ph.getId()) and
    modObj.getModule() = ph.getEnclosingModule()
  ) and
  // Verify the placeholder is not a globally defined name or monkey-patched builtin
  not globallyDefinedName(ph.getId()) and
  not monkey_patched_builtin(ph.getId())
}

// Primary query for detecting undefined placeholder variables
// This query identifies placeholders that are:
// - Not initialized as local variables
// - Not template attributes in their containing class
// - Not global variables, monkey-patched builtins, or globally defined names
from PlaceHolder ph
where
  not isInitializedAsLocal(ph) and
  not isTemplateAttribute(ph) and
  isNotGlobalVariable(ph)
select ph, "This use of place-holder variable '" + ph.getId() + "' may be undefined."