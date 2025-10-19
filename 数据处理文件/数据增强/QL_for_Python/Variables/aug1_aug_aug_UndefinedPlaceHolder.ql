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
 * within its containing function scope. This predicate verifies whether
 * there exists an SSA variable representing a local variable that is used
 * at the placeholder's flow node and is not potentially undefined.
 */
predicate isInitializedAsLocal(PlaceHolder placeholder) {
  exists(SsaVariable ssaLocalVar, Function containingFunction |
    containingFunction = placeholder.getScope() and
    ssaLocalVar.getAUse() = placeholder.getAFlowNode() and
    ssaLocalVar.getVariable() instanceof LocalVariable and
    not ssaLocalVar.maybeUndefined()
  )
}

/**
 * Retrieves the class that contains the placeholder usage.
 * This helper predicate identifies the enclosing class by checking
 * if the placeholder's scope is a method of that class.
 */
Class getEnclosingClass(PlaceHolder placeholder) {
  result.getAMethod() = placeholder.getScope()
}

/**
 * Checks if a placeholder corresponds to a template attribute
 * defined within its enclosing class. This predicate verifies
 * whether the placeholder's identifier is defined in the
 * import-time scope of its enclosing class.
 */
predicate isTemplateAttribute(PlaceHolder placeholder) {
  exists(ImportTimeScope classImportScope |
    classImportScope = getEnclosingClass(placeholder) and
    classImportScope.definesName(placeholder.getId())
  )
}

/**
 * Verifies that a placeholder is neither a global variable,
 * monkey-patched builtin, nor globally defined name. This predicate
 * ensures the placeholder is not defined as an attribute in
 * the enclosing module, not a globally defined name, and not a
 * monkey-patched builtin.
 */
predicate isNotGlobalVariable(PlaceHolder placeholder) {
  // Check if the placeholder is not defined as an attribute in the enclosing module
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(placeholder.getId()) and
    moduleObject.getModule() = placeholder.getEnclosingModule()
  ) and
  // Check if the placeholder is not a globally defined name
  not globallyDefinedName(placeholder.getId()) and
  // Check if the placeholder is not a monkey-patched builtin
  not monkey_patched_builtin(placeholder.getId())
}

// Main query identifying undefined placeholder variables
// This query finds placeholders that are:
// 1. Not initialized as local variables
// 2. Not template attributes in their enclosing class
// 3. Not global variables, monkey-patched builtins, or globally defined names
from PlaceHolder placeholder
where
  not isInitializedAsLocal(placeholder) and
  not isTemplateAttribute(placeholder) and
  isNotGlobalVariable(placeholder)
select placeholder, "This use of place-holder variable '" + placeholder.getId() + "' may be undefined."