/**
 * @name Missing docstring
 * @description Public entities (modules, classes, functions) without documentation strings
 *              reduce code maintainability and hinder developer understanding.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: Precision is 'medium' because docstring necessity is context-dependent.
 * Different teams/projects may have varying documentation standards.
 */

import python

// Determines if a scope requires documentation based on visibility and type
predicate requires_documentation(Scope entity) {
  entity.isPublic() and
  (
    not entity instanceof Function
    or
    function_requires_documentation(entity)
  )
}

// Evaluates if a function requires documentation based on complexity and usage
predicate function_requires_documentation(Function func) {
  // Excludes functions that override methods without docstrings
  not exists(FunctionValue derivedFunc, FunctionValue baseFunc | 
    derivedFunc.overrides(baseFunc) and 
    derivedFunc.getScope() = func and
    not function_requires_documentation(baseFunc.getScope())
  ) and
  // Excludes lambda functions and trivial implementations
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Excludes property getter/setter methods
  not exists(PythonPropertyObject property |
    property.getGetter().getFunction() = func or
    property.getSetter().getFunction() = func
  )
}

// Classifies scope type for result reporting
string get_scope_classification(Scope entity) {
  result = "Module" and entity instanceof Module and not entity.(Module).isPackage()
  or
  result = "Class" and entity instanceof Class
  or
  result = "Function" and entity instanceof Function
}

// Identifies public entities missing documentation strings
from Scope entity
where 
  requires_documentation(entity) and 
  not exists(entity.getDocString())
select entity, 
  get_scope_classification(entity) + " " + entity.getName() + " does not have a docstring."