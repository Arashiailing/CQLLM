/**
 * @name Missing docstring
 * @description Identifies public classes, functions, or methods lacking documentation strings,
 *              which hinders code maintainability by obscuring the intended purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: This query exhibits medium precision since determining docstring necessity 
 * involves subjective judgment. Documentation requirements differ based on codebase 
 * context and target audience.
 */

import python

// Evaluates whether a code scope necessitates documentation
predicate requiresDocumentation(Scope codeScope) {
  codeScope.isPublic() and
  (
    not codeScope instanceof Function
    or
    functionShouldHaveDoc(codeScope)
  )
}

// Determines if a function should include documentation
predicate functionShouldHaveDoc(Function function) {
  // Exclude lambda functions from documentation requirement
  function.getName() != "lambda" and
  // Compute actual lines of code (excluding decorators)
  (function.getMetrics().getNumberOfLinesOfCode() - count(function.getADecorator())) > 2 and
  // Exclude property getter/setter methods
  not exists(PythonPropertyObject pyProperty |
    pyProperty.getGetter().getFunction() = function or
    pyProperty.getSetter().getFunction() = function
  ) and
  // Check documentation requirements for overridden functions
  not exists(FunctionValue derivedFunc, FunctionValue parentFunc | 
    derivedFunc.overrides(parentFunc) and derivedFunc.getScope() = function |
    not functionShouldHaveDoc(parentFunc.getScope())
  )
}

// Provides the type name of a code scope (Module, Class, or Function)
string determineScopeType(Scope codeScope) {
  // Handle non-package modules
  result = "Module" and codeScope instanceof Module and not codeScope.(Module).isPackage()
  or
  // Handle class definitions
  result = "Class" and codeScope instanceof Class
  or
  // Handle function definitions
  result = "Function" and codeScope instanceof Function
}

// Locates code scopes that require documentation but lack docstrings
from Scope codeScope
where requiresDocumentation(codeScope) and not exists(codeScope.getDocString())
select codeScope, determineScopeType(codeScope) + " " + codeScope.getName() + " does not have a docstring."