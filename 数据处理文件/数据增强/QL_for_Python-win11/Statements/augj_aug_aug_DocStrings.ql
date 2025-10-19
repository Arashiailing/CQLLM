/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings
 *              hinder code maintainability and understanding for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The 'medium' precision reflects the subjective nature of docstring requirements.
 * The necessity of a docstring often depends on the context and intended audience.
 */

import python

// Determines if a code entity requires documentation based on its visibility and type
predicate requires_docstring(Scope targetScope) {
  // The scope must be publicly accessible and either not a function or a function that needs documentation
  targetScope.isPublic() and
  (
    not targetScope instanceof Function
    or
    function_requires_docstring(targetScope)
  )
}

// Evaluates if a function should have a docstring based on specific criteria
predicate function_requires_docstring(Function func) {
  // Check that the function doesn't override a parent method without a docstring requirement
  not exists(FunctionValue derivedFunc, FunctionValue parentFunc | 
    derivedFunc.overrides(parentFunc) and derivedFunc.getScope() = func |
    not function_requires_docstring(parentFunc.getScope())
  ) and
  // Ensure it's not a lambda function
  func.getName() != "lambda" and
  // Verify the function has substantial code (more than 2 lines, excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Confirm it's not a property getter or setter method
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  )
}

// Provides a descriptive type name for the given code scope
string get_scope_type(Scope targetScope) {
  // Check if the scope is a non-package module
  if targetScope instanceof Module and not targetScope.(Module).isPackage()
  then result = "Module"
  // Check if the scope is a class
  else if targetScope instanceof Class
  then result = "Class"
  // Otherwise, assume it's a function
  else result = "Function"
}

// Main query that identifies public code entities missing required documentation
from Scope targetScope
where requires_docstring(targetScope) and not exists(targetScope.getDocString())
select targetScope, get_scope_type(targetScope) + " " + targetScope.getName() + " does not have a docstring."