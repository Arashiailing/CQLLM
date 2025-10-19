/**
 * @name Missing docstring
 * @description Identifies public classes, functions, or methods that lack documentation strings.
 *              Missing docstrings can significantly reduce code maintainability and make it
 *              difficult for other developers to understand the purpose and functionality
 *              of the code elements.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: This query has 'medium' precision because the requirement for docstrings
 * can be subjective. The necessity of a docstring often depends on the specific
 * context, project conventions, and intended audience of the code.
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
  // 1. It doesn't override a base method that doesn't require a docstring
  // 2. It's not a lambda function
  // 3. Its code length (excluding decorators) exceeds 2 lines
  // 4. It's not a property getter or setter method
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = targetFunction |
    not function_requires_docstring(baseFunc.getScope())
  ) and
  targetFunction.getName() != "lambda" and
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = targetFunction or
    property.getSetter().getFunction() = targetFunction
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