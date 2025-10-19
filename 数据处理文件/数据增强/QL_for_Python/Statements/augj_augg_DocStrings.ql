/**
 * @name Missing docstring
 * @description Public classes, functions or methods without documentation strings
 *              increase maintenance difficulty for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: Medium precision reflects the subjective nature of docstring requirements.
 * Documentation needs vary based on context and intended audience.
 */

import python

// Determines if a function requires documentation based on specific criteria
predicate requiresFunctionDocumentation(Function targetFunction) {
  // Exclude overridden functions (unless base requires docs)
  not exists(FunctionValue override, FunctionValue base | 
    override.overrides(base) and 
    override.getScope() = targetFunction |
    not requiresFunctionDocumentation(base.getScope())
  ) and
  // Exclude lambda functions
  targetFunction.getName() != "lambda" and
  // Require substantial implementation (excluding decorators)
  (targetFunction.getMetrics().getNumberOfLinesOfCode() - count(targetFunction.getADecorator())) > 2 and
  // Exclude property getters/setters
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = targetFunction or
    prop.getSetter().getFunction() = targetFunction
  )
}

// Determines if a scope requires documentation
predicate needsDocumentation(Scope targetScope) {
  targetScope.isPublic() and
  (
    // Non-function scopes always require documentation
    not targetScope instanceof Function
    or
    // Functions require docs if they meet specific criteria
    requiresFunctionDocumentation(targetScope)
  )
}

// Classifies scope type for reporting
string classifyScopeType(Scope targetScope) {
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  or
  result = "Class" and targetScope instanceof Class
  or
  result = "Function" and targetScope instanceof Function
}

// Main query: Identifies scopes requiring documentation but missing docstrings
from Scope targetScope
where 
  needsDocumentation(targetScope) and 
  not exists(targetScope.getDocString())
select 
  targetScope, 
  classifyScopeType(targetScope) + " " + targetScope.getName() + " does not have a docstring."