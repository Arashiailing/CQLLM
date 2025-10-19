/**
 * @name Missing docstring
 * @description Omitting documentation strings from public classes, functions or methods
 *              makes it more difficult for other developers to maintain the code.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: The 'medium' precision reflects the imprecision in the underlying rule.
 * Whether a function should have a docstring often depends on the reader of that docstring.
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
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = func or
    prop.getSetter().getFunction() = func
  ) and
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = func |
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

// Select scopes requiring docstrings but missing them
from Scope scope
where requires_docstring(scope) and not exists(scope.getDocString())
select scope, get_scope_type(scope) + " " + scope.getName() + " does not have a docstring."