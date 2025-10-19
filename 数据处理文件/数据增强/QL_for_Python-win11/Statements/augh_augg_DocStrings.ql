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

// Helper predicate to determine if a function requires documentation
predicate functionRequiresDocstring(Function targetFunction) {
  // Check if the function is not an overridden function with no docstring requirement in the base
  not exists(FunctionValue overridingFunc, FunctionValue baseFunc | 
    overridingFunc.overrides(baseFunc) and 
    overridingFunc.getScope() = targetFunction |
    not functionRequiresDocstring(baseFunc.getScope())
  ) and
  // Check if the function is not a lambda
  targetFunction.getName() != "lambda" and
  // Check if the function has substantial implementation (excluding decorators)
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  // Check if the function is not a property getter/setter
  not exists(PythonPropertyObject propertyObj |
    propertyObj.getGetter().getFunction() = targetFunction or
    propertyObj.getSetter().getFunction() = targetFunction
  )
}

// Helper predicate to determine if a scope requires documentation
predicate requiresDocstring(Scope targetScope) {
  targetScope.isPublic() and
  (
    // Non-function scopes always require docs
    not targetScope instanceof Function
    or
    // Functions require docs if they meet specific criteria
    functionRequiresDocstring(targetScope)
  )
}

// Helper function to classify scope type
string getScopeType(Scope targetScope) {
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  or
  result = "Class" and targetScope instanceof Class
  or
  result = "Function" and targetScope instanceof Function
}

// Main query: Find scopes requiring documentation but missing docstrings
from Scope targetScope
where 
  requiresDocstring(targetScope) and 
  not exists(targetScope.getDocString())
select 
  targetScope, 
  getScopeType(targetScope) + " " + targetScope.getName() + " does not have a docstring."