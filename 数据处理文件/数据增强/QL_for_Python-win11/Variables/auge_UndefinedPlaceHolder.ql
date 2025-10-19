/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are initialized, which can cause runtime exceptions.
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
 * Determines if a placeholder variable is properly initialized as a local variable
 * within its function scope by checking SSA variable definitions.
 */
predicate isInitializedAsLocal(PlaceHolder varUse) {
  exists(SsaVariable ssaVar, Function funcScope |
    funcScope = varUse.getScope() and
    ssaVar.getAUse() = varUse.getAFlowNode() and
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

/**
 * Retrieves the class that encloses the scope where the placeholder variable is used.
 * This identifies the class context by matching method scopes.
 */
Class getEnclosingClass(PlaceHolder varUse) {
  result.getAMethod() = varUse.getScope()
}

/**
 * Checks if the placeholder variable represents a template attribute within its enclosing class.
 * Template attributes are names defined in the class's import-time scope.
 */
predicate isTemplateAttribute(PlaceHolder varUse) {
  exists(ImportTimeScope classScope |
    classScope = getEnclosingClass(varUse) and
    classScope.definesName(varUse.getId())
  )
}

/**
 * Verifies that the placeholder variable is not a global variable by excluding:
 * - Module attributes
 * - Globally defined names
 * - Monkey-patched builtins
 */
predicate isNotGlobalVariable(PlaceHolder varUse) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(varUse.getId()) and
    moduleObj.getModule() = varUse.getEnclosingModule()
  ) and
  not globallyDefinedName(varUse.getId()) and
  not monkey_patched_builtin(varUse.getId())
}

// Main query that identifies potentially undefined placeholder variables
from PlaceHolder placeholderVar
where
  not isInitializedAsLocal(placeholderVar) and  // Not initialized as local variable
  not isTemplateAttribute(placeholderVar) and  // Not a template attribute
  isNotGlobalVariable(placeholderVar)          // Not a global variable
select placeholderVar, "This use of place-holder variable '" + placeholderVar.getId() + "' may be undefined."