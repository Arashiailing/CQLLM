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

/**
 * Determines if a scope requires a docstring.
 * A scope requires a docstring if it is public and either:
 * - It is not a function, or
 * - It is a function that meets specific criteria.
 */
predicate requires_docstring(Scope targetScope) {
  targetScope.isPublic() and
  (
    not targetScope instanceof Function
    or
    function_requires_docstring(targetScope)
  )
}

/**
 * Determines if a function requires a docstring.
 * A function requires a docstring if:
 * - It is not a lambda function,
 * - It has more than 2 lines of code (excluding decorators),
 * - It is not a property getter or setter, and
 * - It does not override a base function that doesn't require a docstring.
 */
predicate function_requires_docstring(Function targetFunction) {
  // Exclude lambda functions
  targetFunction.getName() != "lambda" and
  // Check if function has more than 2 lines of code (excluding decorators)
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  // Exclude property getters and setters
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = targetFunction or
    propertyObj.getSetter().getFunction() = targetFunction
  ) and
  // Exclude functions that override a base function without a docstring
  not exists(FunctionValue overridingFunction, FunctionValue baseFunction | 
    overridingFunction.overrides(baseFunction) and overridingFunction.getScope() = targetFunction |
    not function_requires_docstring(baseFunction.getScope())
  )
}

/**
 * Returns the type of a scope as a string.
 * Possible types are "Module", "Class", or "Function".
 */
string get_scope_type(Scope targetScope) {
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  or
  result = "Class" and targetScope instanceof Class
  or
  result = "Function" and targetScope instanceof Function
}

/**
 * Selects scopes that require a docstring but do not have one.
 * The result includes the scope and a message indicating the missing docstring.
 */
from Scope targetScope
where requires_docstring(targetScope) and not exists(targetScope.getDocString())
select targetScope, get_scope_type(targetScope) + " " + targetScope.getName() + " does not have a docstring."