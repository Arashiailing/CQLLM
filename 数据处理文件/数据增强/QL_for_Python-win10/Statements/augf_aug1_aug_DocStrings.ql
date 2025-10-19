/**
 * @name Missing docstring
 * @description Identifies public classes, functions, or methods that lack documentation strings.
 *              Such absence can hinder code maintainability by making it challenging for 
 *              developers to understand the code's purpose, functionality, and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: This query has medium precision because determining when a docstring is necessary 
 * can be subjective. The requirement often depends on the code's context and the intended 
 * audience (e.g., internal team vs. public API).
 */

import python

// Determines whether a scope requires documentation
predicate requiresDocumentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    functionRequiresDocumentation(scope)
  )
}

// Determines whether a function requires documentation
predicate functionRequiresDocumentation(Function func) {
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = func or
    property.getSetter().getFunction() = func
  ) and
  not exists(FunctionValue override, FunctionValue base | 
    override.overrides(base) and override.getScope() = func |
    not functionRequiresDocumentation(base.getScope())
  )
}

// Returns the type name of a scope (Module, Class, or Function)
string getScopeTypeName(Scope scope) {
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  result = "Class" and scope instanceof Class
  or
  result = "Function" and scope instanceof Function
}

// Identifies scopes that require documentation but lack it
from Scope scope
where requiresDocumentation(scope) and not exists(scope.getDocString())
select scope, getScopeTypeName(scope) + " " + scope.getName() + " does not have a docstring."