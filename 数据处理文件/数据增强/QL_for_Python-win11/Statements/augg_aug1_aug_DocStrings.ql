/**
 * @name Missing docstring
 * @description The absence of documentation strings in public classes, functions, 
 *              or methods hinders code maintainability, as it makes it challenging 
 *              for other developers to comprehend the code's intent and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: This query has medium precision because determining the need for a docstring 
 * is inherently subjective. The requirement often varies based on the code's context 
 * and its intended audience.
 */

import python

// Determines if a scope requires documentation
predicate requires_documentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_needs_documentation(scope)
  )
}

// Determines if a function requires documentation
predicate function_needs_documentation(Function func) {
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
    not function_needs_documentation(baseFunc.getScope())
  )
}

// Returns the type name of a scope (Module, Class, or Function)
string get_scope_type_name(Scope scope) {
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
where requires_documentation(scope) and not exists(scope.getDocString())
select scope, get_scope_type_name(scope) + " " + scope.getName() + " does not have a docstring."