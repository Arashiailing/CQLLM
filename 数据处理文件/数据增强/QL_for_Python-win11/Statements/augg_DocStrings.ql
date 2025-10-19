/**
 * @name Missing docstring
 * @description Omitting documentation strings from public classes, functions or methods
 *              makes it more difficult for other developers to maintain the code.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: Precision of 'medium' reflects the inherent subjectivity in docstring requirements.
 * The necessity of docstrings often depends on the context and intended audience.
 */

import python

// Helper function to determine if a function requires documentation
predicate functionRequiresDocstring(Function func) {
  // Exclude overridden functions (unless base function requires docs)
  not exists(FunctionValue override, FunctionValue base | 
    override.overrides(base) and 
    override.getScope() = func |
    not functionRequiresDocstring(base.getScope())
  ) and
  // Exclude lambda functions
  func.getName() != "lambda" and
  // Require substantial implementation (excluding decorators)
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // Exclude property getters/setters
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = func or
    prop.getSetter().getFunction() = func
  )
}

// Helper function to determine if a scope requires documentation
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