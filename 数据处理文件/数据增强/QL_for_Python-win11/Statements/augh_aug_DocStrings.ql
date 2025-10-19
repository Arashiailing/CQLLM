/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without docstrings reduce code maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: The 'medium' precision reflects the imprecision in the underlying rule.
 * The requirement for a docstring often depends on the intended audience.
 */

import python

// Determines if a scope requires a docstring
predicate requires_docstring(Scope currentScope) {
  currentScope.isPublic() and
  (
    not currentScope instanceof Function
    or
    function_requires_docstring(currentScope)
  )
}

// Determines if a function requires a docstring
predicate function_requires_docstring(Function functionObj) {
  functionObj.getName() != "lambda" and
  (functionObj.getMetrics().getNumberOfLinesOfCode() - count(functionObj.getADecorator())) > 2 and
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = functionObj or
    propertyObj.getSetter().getFunction() = functionObj
  ) and
  not exists(FunctionValue overridingFunction, FunctionValue baseFunction | 
    overridingFunction.overrides(baseFunction) and overridingFunction.getScope() = functionObj |
    not function_requires_docstring(baseFunction.getScope())
  )
}

// Returns the type of a scope (Module, Class, or Function)
string get_scope_type(Scope currentScope) {
  result = "Module" and currentScope instanceof Module and not currentScope.(Module).isPackage()
  or
  result = "Class" and currentScope instanceof Class
  or
  result = "Function" and currentScope instanceof Function
}

// Select scopes requiring docstrings but missing them
from Scope currentScope
where requires_docstring(currentScope) and not exists(currentScope.getDocString())
select currentScope, get_scope_type(currentScope) + " " + currentScope.getName() + " does not have a docstring."