/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings 
 *              can hinder code maintenance by other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: Medium precision reflects the inherent subjectivity in docstring requirements.
 * The need for docstrings is context-dependent and varies based on the intended audience.
 */

import python

// Helper predicate to determine if a function requires documentation
predicate functionRequiresDocstring(Function func) {
  // Check if the function is not a lambda
  func.getName() != "lambda" and
  // Check if the function has substantial implementation (excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Check if the function is not a property getter/setter
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = func or
    prop.getSetter().getFunction() = func
  ) and
  // Check if the function is not an overridden function with no docstring requirement in the base
  not exists(FunctionValue overriding, FunctionValue base | 
    overriding.overrides(base) and 
    overriding.getScope() = func |
    not functionRequiresDocstring(base.getScope())
  )
}

// Helper predicate to determine if a scope requires documentation
predicate requiresDocstring(Scope scope) {
  scope.isPublic() and
  (
    // Non-function scopes always require docs
    not scope instanceof Function
    or
    // Functions require docs if they meet specific criteria
    functionRequiresDocstring(scope)
  )
}

// Helper function to classify scope type
string getScopeType(Scope scope) {
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  result = "Class" and scope instanceof Class
  or
  result = "Function" and scope instanceof Function
}

// Main query: Find scopes requiring documentation but missing docstrings
from Scope scope
where 
  requiresDocstring(scope) and 
  not exists(scope.getDocString())
select 
  scope, 
  getScopeType(scope) + " " + scope.getName() + " does not have a docstring."