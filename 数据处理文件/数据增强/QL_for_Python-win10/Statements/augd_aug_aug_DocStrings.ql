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

// Identify scopes requiring documentation based on visibility and type
predicate should_have_documentation(Scope targetScope) {
  targetScope.isPublic() and (
    not targetScope instanceof Function
    or
    function_needs_documentation(targetScope)
  )
}

// Determine if a function requires documentation based on specific criteria
predicate function_needs_documentation(Function func) {
  // Skip if overriding a base method that doesn't require docs
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = func |
    not function_needs_documentation(baseFunc.getScope())
  ) and
  // Exclude lambda functions
  func.getName() != "lambda" and
  // Require docs for functions longer than 2 lines (excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Skip property getters/setters
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  )
}

// Categorize scope type for result reporting
string describe_scope_type(Scope targetScope) {
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  or
  result = "Class" and targetScope instanceof Class
  or
  result = "Function" and targetScope instanceof Function
}

// Find public scopes missing required documentation
from Scope targetScope
where should_have_documentation(targetScope) and not exists(targetScope.getDocString())
select targetScope, describe_scope_type(targetScope) + " " + targetScope.getName() + " does not have a docstring."