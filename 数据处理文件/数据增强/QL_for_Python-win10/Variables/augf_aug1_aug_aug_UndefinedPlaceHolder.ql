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
 * Checks if a placeholder variable is properly initialized as a local variable
 * within its containing function scope. This predicate verifies whether
 * there exists an SSA variable representing a local variable that is used
 * at the placeholder's flow node and is not potentially undefined.
 */
predicate initializedAsLocalVar(PlaceHolder uninitPlaceholder) {
  exists(SsaVariable localSsaVar, Function enclosingFunc |
    enclosingFunc = uninitPlaceholder.getScope() and
    localSsaVar.getAUse() = uninitPlaceholder.getAFlowNode() and
    localSsaVar.getVariable() instanceof LocalVariable and
    not localSsaVar.maybeUndefined()
  )
}

/**
 * Retrieves the class that contains the placeholder usage.
 * This helper predicate identifies the enclosing class by checking
 * if the placeholder's scope is a method of that class.
 */
Class enclosingClassOf(PlaceHolder uninitPlaceholder) {
  result.getAMethod() = uninitPlaceholder.getScope()
}

/**
 * Determines if a placeholder corresponds to a template attribute
 * defined within its enclosing class. This predicate verifies
 * whether the placeholder's identifier is defined in the
 * import-time scope of its enclosing class.
 */
predicate isClassTemplateAttribute(PlaceHolder uninitPlaceholder) {
  exists(ImportTimeScope classScope |
    classScope = enclosingClassOf(uninitPlaceholder) and
    classScope.definesName(uninitPlaceholder.getId())
  )
}

/**
 * Ensures that a placeholder is neither a global variable,
 * monkey-patched builtin, nor globally defined name. This predicate
 * verifies the placeholder is not defined as an attribute in
 * the enclosing module, not a globally defined name, and not a
 * monkey-patched builtin.
 */
predicate isNonGlobalVar(PlaceHolder uninitPlaceholder) {
  // Verify the placeholder is not defined as an attribute in the enclosing module
  not exists(PythonModuleObject mod |
    mod.hasAttribute(uninitPlaceholder.getId()) and
    mod.getModule() = uninitPlaceholder.getEnclosingModule()
  ) and
  // Verify the placeholder is not a globally defined name
  not globallyDefinedName(uninitPlaceholder.getId()) and
  // Verify the placeholder is not a monkey-patched builtin
  not monkey_patched_builtin(uninitPlaceholder.getId())
}

// Main query identifying undefined placeholder variables
// This query finds placeholders that are:
// 1. Not initialized as local variables
// 2. Not template attributes in their enclosing class
// 3. Not global variables, monkey-patched builtins, or globally defined names
from PlaceHolder uninitPlaceholder
where
  not initializedAsLocalVar(uninitPlaceholder) and
  not isClassTemplateAttribute(uninitPlaceholder) and
  isNonGlobalVar(uninitPlaceholder)
select uninitPlaceholder, "This use of place-holder variable '" + uninitPlaceholder.getId() + "' may be undefined."