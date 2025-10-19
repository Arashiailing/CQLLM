/**
 * @name Incomplete ordering
 * @description Class defines one or more ordering method but does not define all 4 ordering comparison methods
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/incomplete-ordering
 */

import python

// Determines if a class is decorated with total_ordering
predicate usesTotalOrderingDecorator(Class cls) {
  exists(Attribute decorator | decorator = cls.getADecorator() | decorator.getName() = "total_ordering") // Check for decorator attribute
  or
  exists(Name decoratorName | decoratorName = cls.getADecorator() | decoratorName.getId() = "total_ordering") // Check for decorator name
}

// Maps an index to the corresponding comparison method name
string getComparisonMethodName(int index) {
  result = "__lt__" and index = 1 // Less than method
  or
  result = "__le__" and index = 2 // Less than or equal method
  or
  result = "__gt__" and index = 3 // Greater than method
  or
  result = "__ge__" and index = 4 // Greater than or equal method
}

// Checks if a class or its superclass implements a specific comparison method
predicate implementsComparisonMethod(ClassValue targetClass, string methodName) {
  methodName = getComparisonMethodName(_) and ( // Verify valid comparison method name
    targetClass.declaresAttribute(methodName) // Check if class directly implements the method
    or
    exists(ClassValue ancestor | ancestor = targetClass.getASuperType() and not ancestor = Value::named("object") | // Check superclass (excluding object)
      ancestor.declaresAttribute(methodName)
    )
  )
}

// Retrieves the name of a comparison method not implemented by the class
string findMissingComparisonMethod(ClassValue targetClass, int index) {
  not targetClass = Value::named("object") and // Exclude the base object class
  not implementsComparisonMethod(targetClass, result) and // Ensure method is not implemented
  result = getComparisonMethodName(index) // Get method name for the index
}

// Constructs a string listing all missing comparison methods
string buildMissingMethodsString(ClassValue targetClass, int index) {
  index = 0 and result = "" and exists(findMissingComparisonMethod(targetClass, _)) // Initialize and check for missing methods
  or
  exists(string accumulated, int prevIndex | index = prevIndex + 1 and accumulated = buildMissingMethodsString(targetClass, prevIndex) | // Recursively build string
    accumulated = "" and result = findMissingComparisonMethod(targetClass, index) // First method in list
    or
    result = accumulated and not exists(findMissingComparisonMethod(targetClass, index)) and index < 5 // Skip implemented methods
    or
    accumulated != "" and result = accumulated + " or " + findMissingComparisonMethod(targetClass, index) // Add separator and next method
  )
}

// Retrieves a comparison method declared by the class
Value getDeclaredComparisonMethod(ClassValue targetClass, string methodName) {
  /* If class doesn't declare a method then don't blame this class (the superclass will be blamed). */
  methodName = getComparisonMethodName(_) and result = targetClass.declaredAttribute(methodName) // Return declared method
}

// Main query to find classes with incomplete ordering methods
from ClassValue targetClass, Value comparisonMethod, string methodName
where
  not targetClass.failedInference(_) and // Exclude classes with inference failures
  not usesTotalOrderingDecorator(targetClass.getScope()) and // Exclude classes using total_ordering decorator
  comparisonMethod = getDeclaredComparisonMethod(targetClass, methodName) and // Get a declared comparison method
  exists(findMissingComparisonMethod(targetClass, _)) // Ensure there are missing methods
select targetClass,
  "Class " + targetClass.getName() + " implements $@, but does not implement " + // Report the issue
    buildMissingMethodsString(targetClass, 4) + ".", comparisonMethod, methodName // List missing methods