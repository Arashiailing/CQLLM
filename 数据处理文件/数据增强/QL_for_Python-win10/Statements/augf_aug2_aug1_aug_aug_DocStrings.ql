/**
 * @name Missing docstring
 * @description Detects public classes, functions, or methods that lack documentation strings.
 *              Such omissions can impede code maintainability and comprehension for developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The precision is set to 'medium' because docstring requirements are subjective.
 * Whether a docstring is necessary often depends on context and intended audience.
 */

import python

// Determines if a function requires a docstring
// All conditions must be satisfied:
// 1. Does not override a base method that doesn't require a docstring
// 2. Is not a lambda function
// 3. Has more than 2 lines of code (excluding decorators)
// 4. Is not a property getter or setter method
predicate function_requires_documentation(Function func) {
  not exists(FunctionValue overrideFunc, FunctionValue baseFunc | 
    overrideFunc.overrides(baseFunc) and overrideFunc.getScope() = func |
    not function_requires_documentation(baseFunc.getScope())
  ) and
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  )
}

// Provides a textual description of a code scope's type
string describe_scope_type(Scope scope) {
  // Non-package module
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  // Class scope
  or
  result = "Class" and scope instanceof Class
  // Function scope
  or
  result = "Function" and scope instanceof Function
}

// Determines if a code scope requires a docstring
// The scope must be public and meet at least one of these conditions:
// - Not a function (e.g., a class or module)
// - Is a function that meets docstring requirements
predicate scope_needs_documentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_requires_documentation(scope)
  )
}

// Find public scopes that need docstrings but lack them
from Scope scope
where 
  scope_needs_documentation(scope) and 
  not exists(scope.getDocString())
select 
  scope, 
  describe_scope_type(scope) + " " + scope.getName() + " does not have a docstring."