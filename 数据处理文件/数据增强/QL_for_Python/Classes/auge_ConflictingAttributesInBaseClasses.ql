/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits from multiple base classes that define the same attribute, potentially causing unexpected behavior due to attribute resolution ambiguity.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

// Determines if a function contains only pass statements or docstrings
predicate isEmptyFunction(PyFunctionObject f) {
  // Verify function body contains no operational statements beyond pass or docstring
  not exists(Stmt s | s.getScope() = f.getFunction() |
    not s instanceof Pass and not s.(ExprStmt).getValue() = f.getFunction().getDocString()
  )
}

/* Methods using super() calls are exempt as they explicitly handle method resolution */
// Checks if a function contains a super() call to its own method
predicate invokesSuper(FunctionObject f) {
  // Identify super() calls targeting the current method name
  exists(Call sup, Call meth, Attribute attr, GlobalVariable v |
    meth.getScope() = f.getFunction() and
    meth.getFunc() = attr and
    attr.getObject() = sup and
    attr.getName() = f.getName() and
    sup.getFunc() = v.getAnAccess() and
    v.getId() = "super"
  )
}

/** Identifies names explicitly permitted to have conflicts */
predicate isPermittedName(string name) {
  /*
   * Exception for socketserver's recommended pattern:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  name = "process_request"
}

from
  ClassObject derivedClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attributeName, int baseIndex1, int baseIndex2, 
  Object attribute1, Object attribute2
where
  // Establish inheritance relationships
  derivedClass.getBaseType(baseIndex1) = baseClass1 and
  derivedClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  attribute1 != attribute2 and
  
  // Resolve conflicting attributes in base classes
  attribute1 = baseClass1.lookupAttribute(attributeName) and
  attribute2 = baseClass2.lookupAttribute(attributeName) and
  
  // Filter out special methods and permitted names
  not attributeName.matches("\\_\\_%\\_\\_") and
  not isPermittedName(attributeName) and
  
  // Exclude methods that properly handle inheritance
  not invokesSuper(attribute1) and
  not isEmptyFunction(attribute2) and
  
  // Verify no overriding relationship exists
  not attribute1.overrides(attribute2) and
  not attribute2.overrides(attribute1) and
  
  // Confirm conflict isn't resolved in derived class
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attribute1, attribute1.toString(), attribute2, attribute2.toString()