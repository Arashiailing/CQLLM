/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings
 *              hinder code maintainability for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The 'medium' precision is due to the subjective nature of docstring requirements.
 * Whether a function requires a docstring often depends on its intended audience.
 */

import python

/**
 * Determines whether a scope requires a docstring.
 * A scope needs a docstring if it's public and either:
 * 1. It's not a function, or
 * 2. It's a function that meets the criteria for needing a docstring.
 */
predicate requires_docstring(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_requires_docstring(scope)
  )
}

/**
 * Checks if a function requires a docstring based on specific criteria:
 * - It's not overriding a function that doesn't need a docstring
 * - It's not a lambda function
 * - It has more than 2 lines of code (excluding decorators)
 * - It's not a property getter or setter
 */
predicate function_requires_docstring(Function func) {
  // Ensure the function isn't overriding a base function that doesn't need a docstring
  not exists(FunctionValue overriding, FunctionValue base | 
    overriding.overrides(base) and overriding.getScope() = func |
    not function_requires_docstring(base.getScope())
  ) and
  // Exclude lambda functions
  func.getName() != "lambda" and
  // Check if the function has substantial code (more than 2 lines excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Exclude property getters and setters
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = func or
    prop.getSetter().getFunction() = func
  )
}

/**
 * Returns the type of a scope as a string.
 * Possible values: "Module", "Class", or "Function".
 */
string get_scope_type(Scope scope) {
  // Check if it's a module (but not a package)
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  // Check if it's a class
  or
  result = "Class" and scope instanceof Class
  // Check if it's a function
  or
  result = "Function" and scope instanceof Function
}

// Find all scopes that require a docstring but don't have one
from Scope scope
where requires_docstring(scope) and not exists(scope.getDocString())
select scope, get_scope_type(scope) + " " + scope.getName() + " does not have a docstring."