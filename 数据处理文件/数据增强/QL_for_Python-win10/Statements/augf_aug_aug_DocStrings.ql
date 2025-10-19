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

// Determines if a given code scope should have a documentation string
predicate should_have_docstring(Scope targetScope) {
  // The scope must be public and meet one of the following criteria:
  // - It's not a function
  // - It's a function that meets docstring requirements
  targetScope.isPublic() and
  (
    not targetScope instanceof Function
    or
    function_needs_docstring(targetScope)
  )
}

// Evaluates whether a function requires a documentation string
predicate function_needs_docstring(Function targetFunction) {
  // A function requires a docstring if it meets all these conditions:
  // 1. It doesn't override a base method that doesn't require a docstring
  // 2. It's not a lambda function
  // 3. Its code length (excluding decorators) exceeds 2 lines
  // 4. It's not a property getter or setter method
  not exists(FunctionValue overridingFunction, FunctionValue baseFunction | 
    overridingFunction.overrides(baseFunction) and overridingFunction.getScope() = targetFunction |
    not function_needs_docstring(baseFunction.getScope())
  ) and
  targetFunction.getName() != "lambda" and
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = targetFunction or
    propertyObj.getSetter().getFunction() = targetFunction
  )
}

// Provides a type description for the given code scope
string describe_scope_type(Scope targetScope) {
  // Returns "Module" for non-package modules
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  // Returns "Class" for class scopes
  or
  result = "Class" and targetScope instanceof Class
  // Returns "Function" for function scopes
  or
  result = "Function" and targetScope instanceof Function
}

// Identifies public scopes that lack required documentation strings
from Scope targetScope
where should_have_docstring(targetScope) and not exists(targetScope.getDocString())
select targetScope, describe_scope_type(targetScope) + " " + targetScope.getName() + " does not have a docstring."