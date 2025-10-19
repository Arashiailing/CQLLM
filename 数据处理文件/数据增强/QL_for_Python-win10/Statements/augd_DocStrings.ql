/**
 * @name Missing docstring
 * @description Public classes, functions or methods without documentation strings
 *              make the code harder to maintain for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The medium precision reflects the inherent ambiguity of this rule.
 * Whether a function should have a docstring often depends on the intended audience.
 */

import python

// Determines if a scope requires a docstring
predicate requires_docstring(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_requires_docstring(scope)
  )
}

// Determines if a function requires a docstring
predicate function_requires_docstring(Function func) {
  // Exclude lambda functions
  func.getName() != "lambda" and
  // Check function length (excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Exclude property getters/setters
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = func or
    prop.getSetter().getFunction() = func
  ) and
  // Validate override chain
  not exists(FunctionValue derivedFunc, FunctionValue baseFunc |
    derivedFunc.overrides(baseFunc) and
    derivedFunc.getScope() = func and
    not function_requires_docstring(baseFunc.getScope())
  )
}

// Returns the type of a scope (Module, Class, or Function)
string get_scope_type(Scope scope) {
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  result = "Class" and scope instanceof Class
  or
  result = "Function" and scope instanceof Function
}

from Scope scope
where requires_docstring(scope) and not exists(scope.getDocString())
select scope, get_scope_type(scope) + " " + scope.getName() + " does not have a docstring."