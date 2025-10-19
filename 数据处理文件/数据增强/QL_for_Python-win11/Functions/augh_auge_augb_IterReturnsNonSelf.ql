/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects iterator classes whose `__iter__` method does not return self instance,
 *              violating the Python iterator protocol requirements
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// Retrieve the `__iter__` method implementation from an iterator class
Function getIteratorMethod(ClassValue iteratorClass) { 
  result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

// Determine if a variable reference corresponds to the 'self' parameter of a method
predicate isSelfParameterReference(Name variableNode, Function methodDef) { 
  variableNode.getVariable() = methodDef.getArg(0).(Name).getVariable() 
}

// Check if an iterator method violates the return protocol
predicate hasInvalidReturnStatement(Function methodDef) {
  // Case 1: Method has execution paths without explicit return
  exists(methodDef.getFallthroughNode())
  or
  // Case 2: Method contains return statements without values (implicitly returns None)
  exists(Return returnStatement | 
    returnStatement.getScope() = methodDef and 
    not exists(returnStatement.getValue())
  )
  or
  // Case 3: Method contains return statements with non-self values
  exists(Return returnStatement | 
    returnStatement.getScope() = methodDef and 
    exists(returnStatement.getValue()) and 
    not isSelfParameterReference(returnStatement.getValue(), methodDef)
  )
}

// Identify classes that violate the iterator protocol
from ClassValue iteratorClass, Function iteratorMethod
where 
  // Verify the class is an iterator
  iteratorClass.isIterator() and 
  // Obtain the class's __iter__ method
  iteratorMethod = getIteratorMethod(iteratorClass) and 
  // Check if the method violates the return protocol
  hasInvalidReturnStatement(iteratorMethod)
// Output detection results
select iteratorClass, 
  "Iterator class " + iteratorClass.getName() + " has a $@ method that does not return 'self' instance, violating iterator protocol.",
  iteratorMethod, iteratorMethod.getName()