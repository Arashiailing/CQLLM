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
 * Determines whether a code scope requires a docstring.
 * A scope needs documentation if it's public and either:
 * 1. It's not a function, or
 * 2. It's a function meeting specific docstring criteria.
 */
predicate requires_docstring(Scope codeScope) {
  codeScope.isPublic() and
  (
    not codeScope instanceof Function
    or
    function_needs_docstring(codeScope)
  )
}

/**
 * Checks if a function requires a docstring based on:
 * - Not overriding a base function without a docstring
 * - Not being a lambda function
 * - Having substantial code (>2 lines excluding decorators)
 * - Not being a property getter/setter
 */
predicate function_needs_docstring(Function function) {
  // Ensure function doesn't override a base function lacking docstring
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = function |
    not function_needs_docstring(baseFunc.getScope())
  ) and
  // Exclude lambda functions
  function.getName() != "lambda" and
  // Verify substantial code content (excluding decorators)
  (function.getMetrics().getNumberOfLinesOfCode() - count(function.getADecorator())) > 2 and
  // Exclude property accessors
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = function or
    propertyObj.getSetter().getFunction() = function
  )
}

/**
 * Classifies scope type as "Module", "Class", or "Function".
 */
string classify_scope_type(Scope codeScope) {
  // Module classification (excluding packages)
  result = "Module" and codeScope instanceof Module and not codeScope.(Module).isPackage()
  // Class classification
  or
  result = "Class" and codeScope instanceof Class
  // Function classification
  or
  result = "Function" and codeScope instanceof Function
}

// Identify scopes requiring docstrings but lacking them
from Scope codeScope
where requires_docstring(codeScope) and not exists(codeScope.getDocString())
select codeScope, classify_scope_type(codeScope) + " " + codeScope.getName() + " does not have a docstring."