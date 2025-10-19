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
predicate requires_docstring(Scope codeScope) {
  // The scope must be public and meet one of the following criteria:
  // - It's not a function
  // - It's a function that meets docstring requirements
  codeScope.isPublic() and
  (
    not codeScope instanceof Function
    or
    function_requires_docstring(codeScope)
  )
}

// Evaluates whether a function requires a documentation string
predicate function_requires_docstring(Function function) {
  // A function requires a docstring if it meets all these conditions:
  // 1. It doesn't override a base method that doesn't require a docstring
  // 2. It's not a lambda function
  // 3. Its code length (excluding decorators) exceeds 2 lines
  // 4. It's not a property getter or setter method
  not exists(FunctionValue overridingFunction, FunctionValue baseFunction | 
    overridingFunction.overrides(baseFunction) and overridingFunction.getScope() = function |
    not function_requires_docstring(baseFunction.getScope())
  ) and
  function.getName() != "lambda" and
  (function.getMetrics().getNumberOfLinesOfCode() - count(function.getADecorator())) > 2 and
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = function or
    propertyObj.getSetter().getFunction() = function
  )
}

// Provides a type description for the given code scope
string get_scope_type(Scope codeScope) {
  // Returns "Module" for non-package modules
  result = "Module" and codeScope instanceof Module and not codeScope.(Module).isPackage()
  // Returns "Class" for class scopes
  or
  result = "Class" and codeScope instanceof Class
  // Returns "Function" for function scopes
  or
  result = "Function" and codeScope instanceof Function
}

// Identifies public scopes that lack required documentation strings
from Scope codeScope
where requires_docstring(codeScope) and not exists(codeScope.getDocString())
select codeScope, get_scope_type(codeScope) + " " + codeScope.getName() + " does not have a docstring."