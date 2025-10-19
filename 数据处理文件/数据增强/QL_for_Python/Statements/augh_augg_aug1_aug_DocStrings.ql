/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings 
 *              reduce code maintainability by making it difficult for developers 
 *              to understand the code's purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: This query has medium precision because determining docstring necessity 
 * is subjective. Requirements vary based on code context and intended audience.
 */

import python

// Determines if a scope requires documentation
predicate needsDocumentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    functionRequiresDoc(scope)
  )
}

// Determines if a function requires documentation
predicate functionRequiresDoc(Function func) {
  // Exclude lambda functions
  func.getName() != "lambda" and
  // Calculate actual code lines (excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Ensure it's not a property getter/setter
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = func or
    property.getSetter().getFunction() = func
  ) and
  // Validate override documentation requirements
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = func |
    not functionRequiresDoc(baseFunc.getScope())
  )
}

// Returns the type name of a scope (Module, Class, or Function)
string getScopeTypeName(Scope scope) {
  // Handle non-package modules
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  // Handle classes
  result = "Class" and scope instanceof Class
  or
  // Handle functions
  result = "Function" and scope instanceof Function
}

// Identifies scopes requiring documentation but missing it
from Scope scope
where needsDocumentation(scope) and not exists(scope.getDocString())
select scope, getScopeTypeName(scope) + " " + scope.getName() + " does not have a docstring."