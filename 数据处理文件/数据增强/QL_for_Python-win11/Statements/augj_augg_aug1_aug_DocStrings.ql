/**
 * @name Missing docstring
 * @description Lack of documentation strings in public classes, functions, 
 *              or methods impedes code maintainability, as it becomes difficult 
 *              for other developers to understand the code's purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: This query exhibits medium precision since the necessity of a docstring 
 * is inherently subjective. The requirement frequently depends on the code's context 
 * and its target audience.
 */

import python

// Determines if a scope requires documentation
predicate needsDocumentation(Scope currentScope) {
  currentScope.isPublic() and
  (
    not currentScope instanceof Function
    or
    functionRequiresDoc(currentScope)
  )
}

// Determines if a function requires documentation
predicate functionRequiresDoc(Function functionObj) {
  // Exclude lambda functions
  functionObj.getName() != "lambda" and
  // Calculate actual code lines (excluding decorators)
  (functionObj.getMetrics().getNumberOfLinesOfCode() - count(functionObj.getADecorator())) > 2 and
  // Ensure it's not a property getter/setter
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = functionObj or
    prop.getSetter().getFunction() = functionObj
  ) and
  // Validate override documentation requirements
  not exists(FunctionValue overrideFunc, FunctionValue baseFuncObj | 
    overrideFunc.overrides(baseFuncObj) and overrideFunc.getScope() = functionObj |
    not functionRequiresDoc(baseFuncObj.getScope())
  )
}

// Returns the type name of a scope (Module, Class, or Function)
string getScopeTypeName(Scope currentScope) {
  // Handle non-package modules
  result = "Module" and currentScope instanceof Module and not currentScope.(Module).isPackage()
  or
  // Handle classes
  result = "Class" and currentScope instanceof Class
  or
  // Handle functions
  result = "Function" and currentScope instanceof Function
}

// Identifies scopes requiring documentation but missing it
from Scope currentScope
where needsDocumentation(currentScope) and not exists(currentScope.getDocString())
select currentScope, getScopeTypeName(currentScope) + " " + currentScope.getName() + " does not have a docstring."