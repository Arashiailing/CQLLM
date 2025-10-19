/**
 * @name Missing docstring
 * @description Public classes, functions or methods without documentation strings 
 *              reduce code maintainability by making it harder for developers 
 *              to understand the code's purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/* Note: Medium precision due to inherent subjectivity in determining docstring necessity.
 * The requirement often depends on code context and intended audience. */

import python

// Check if a scope requires documentation
predicate requires_documentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_needs_documentation(scope)
  )
}

// Check if a function requires documentation
predicate function_needs_documentation(Function func) {
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = func or
    property.getSetter().getFunction() = func
  ) and
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and overridingFunc.getScope() = func |
    not function_needs_documentation(baseFunc.getScope())
  )
}

// Get the type name of a scope (Module, Class, or Function)
string get_scope_type_name(Scope scope) {
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  result = "Class" and scope instanceof Class
  or
  result = "Function" and scope instanceof Function
}

// Find scopes requiring documentation but lacking it
from Scope scope
where requires_documentation(scope) and not exists(scope.getDocString())
select scope, get_scope_type_name(scope) + " " + scope.getName() + " does not have a docstring."