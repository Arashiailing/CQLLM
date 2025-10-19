/**
 * @name Missing docstring
 * @description Identifies public classes, functions, or methods that lack documentation strings.
 *              Such omissions can impede code maintainability and comprehension for developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The 'medium' precision acknowledges the contextual nature of docstring requirements.
 * Whether a docstring is necessary often depends on the specific context and intended audience.
 */

import python

// Determines if a code scope requires documentation
// A scope must be public and meet one of the following conditions:
// - It is not a function (e.g., a class or module)
// - It is a function that meets documentation requirements
predicate requiresDocumentation(Scope codeScope) {
  codeScope.isPublic() and
  (
    not codeScope instanceof Function
    or
    functionRequiresDocumentation(codeScope)
  )
}

// Determines if a function requires documentation
// Must satisfy all of the following conditions:
// 1. Does not override a base method that doesn't need documentation
// 2. Is not a lambda function
// 3. Code length (excluding decorators) exceeds 2 lines
// 4. Is not a property getter or setter method
predicate functionRequiresDocumentation(Function func) {
  not exists(FunctionValue overrideFunc, FunctionValue baseFunc | 
    overrideFunc.overrides(baseFunc) and overrideFunc.getScope() = func |
    not functionRequiresDocumentation(baseFunc.getScope())
  ) and
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  )
}

// Returns the type description of a code scope
string getScopeTypeDescription(Scope codeScope) {
  // Non-package module
  result = "Module" and codeScope instanceof Module and not codeScope.(Module).isPackage()
  // Class scope
  or
  result = "Class" and codeScope instanceof Class
  // Function scope
  or
  result = "Function" and codeScope instanceof Function
}

// Find public scopes that require documentation but lack it
from Scope codeScope
where requiresDocumentation(codeScope) and not exists(codeScope.getDocString())
select codeScope, getScopeTypeDescription(codeScope) + " " + codeScope.getName() + " does not have a docstring."