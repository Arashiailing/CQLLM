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

// Helper predicate to check if a scope is publicly accessible
predicate is_publicly_accessible(Scope codeScope) {
  codeScope.isPublic()
}

// Helper predicate to identify non-function scopes (classes or modules)
predicate is_non_function_entity(Scope codeScope) {
  not codeScope instanceof Function
}

// Determines if a function requires documentation based on specific criteria
// A function needs documentation if it:
// 1. Doesn't override a base method that doesn't require documentation
// 2. Is not a lambda function
// 3. Has more than 2 lines of code (excluding decorators)
// 4. Is not a property getter or setter
predicate function_requires_documentation(Function targetFunction) {
  not exists(FunctionValue overridingFunc, FunctionValue baseFunction | 
    overridingFunc.overrides(baseFunction) and overridingFunc.getScope() = targetFunction |
    not function_requires_documentation(baseFunction.getScope())
  ) and
  targetFunction.getName() != "lambda" and
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = targetFunction or
    propertyObj.getSetter().getFunction() = targetFunction
  )
}

// Main predicate to determine if a scope should have documentation
// A scope requires documentation if it's public and either:
// - It's not a function (e.g., a class or module)
// - It's a function that meets the documentation requirements
predicate should_have_documentation(Scope codeScope) {
  is_publicly_accessible(codeScope) and
  (
    is_non_function_entity(codeScope)
    or
    function_requires_documentation(codeScope)
  )
}

// Returns a descriptive string for the type of scope being analyzed
string get_scope_description(Scope codeScope) {
  // Non-package module
  result = "Module" and codeScope instanceof Module and not codeScope.(Module).isPackage()
  // Class scope
  or
  result = "Class" and codeScope instanceof Class
  // Function scope
  or
  result = "Function" and codeScope instanceof Function
}

// Main query to find public scopes that lack required documentation
from Scope codeScope
where should_have_documentation(codeScope) and not exists(codeScope.getDocString())
select codeScope, get_scope_description(codeScope) + " " + codeScope.getName() + " does not have a docstring."