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
predicate requires_docstring(Scope targetScope) {
  // The scope must be public and meet one of the following criteria:
  // - It's not a function
  // - It's a function that meets docstring requirements
  targetScope.isPublic() and
  (
    not targetScope instanceof Function
    or
    function_requires_docstring(targetScope)
  )
}

// Evaluates whether a function requires a documentation string
predicate function_requires_docstring(Function targetFunction) {
  // A function requires a docstring if it meets all these conditions:
  // 1. It's not a lambda function
  // 2. It's not a property getter or setter method
  // 3. Its code length (excluding decorators) exceeds 2 lines
  // 4. It doesn't override a base method that doesn't require a docstring
  targetFunction.getName() != "lambda" and
  not exists(PythonPropertyObject propertyInstance |
    propertyInstance.getGetter().getFunction() = targetFunction or
    propertyInstance.getSetter().getFunction() = targetFunction
  ) and
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  not exists(FunctionValue derivedFunction, FunctionValue ancestorFunction | 
    derivedFunction.overrides(ancestorFunction) and derivedFunction.getScope() = targetFunction |
    not function_requires_docstring(ancestorFunction.getScope())
  )
}

// Provides a type description for the given code scope
string get_scope_type(Scope targetScope) {
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
where requires_docstring(targetScope) and not exists(targetScope.getDocString())
select targetScope, get_scope_type(targetScope) + " " + targetScope.getName() + " does not have a docstring."