/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings
 *              can make code harder to maintain and understand for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The precision is set to 'medium' because the need for a docstring can be subjective.
 * It often depends on the context and the intended audience of the code.
 */

import python

// Determines if a function requires documentation based on specific criteria:
// - Doesn't override a base method that doesn't require documentation
// - Is not a lambda function
// - Has more than 2 lines of code (excluding decorators)
// - Is not a property getter or setter
predicate function_requires_documentation(Function function) {
  not exists(FunctionValue overridingFunction, FunctionValue baseFunction | 
    overridingFunction.overrides(baseFunction) and overridingFunction.getScope() = function |
    not function_requires_documentation(baseFunction.getScope())
  ) and
  function.getName() != "lambda" and
  (function.getMetrics().getNumberOfLinesOfCode() - count(function.getADecorator())) > 2 and
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = function or
    property.getSetter().getFunction() = function
  )
}

// Main predicate to determine if a scope should have documentation
// A scope requires documentation if it's public and either:
// - It's not a function (e.g., a class or module)
// - It's a function that meets the documentation requirements
predicate should_have_documentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_requires_documentation(scope)
  )
}

// Returns a descriptive string for the type of scope being analyzed
string get_scope_description(Scope scope) {
  // Non-package module
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  // Class scope
  or
  result = "Class" and scope instanceof Class
  // Function scope
  or
  result = "Function" and scope instanceof Function
}

// Main query to find public scopes that lack required documentation
from Scope scope
where should_have_documentation(scope) and not exists(scope.getDocString())
select scope, get_scope_description(scope) + " " + scope.getName() + " does not have a docstring."