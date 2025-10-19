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

// Check if a class is decorated with @total_ordering from functools module
predicate hasTotalOrderingDecorator(Class cls) {
  exists(Attribute decoratorNode | decoratorNode = cls.getADecorator() | decoratorNode.getName() = "total_ordering") // Check decorator attribute
  or
  exists(Name decoratorNameNode | decoratorNameNode = cls.getADecorator() | decoratorNameNode.getId() = "total_ordering") // Check decorator name
}

// Map an index to its corresponding comparison method name
string comparisonMethodNameForIndex(int idx) {
  result = "__lt__" and idx = 1 // Less than method
  or
  result = "__le__" and idx = 2 // Less than or equal method
  or
  result = "__gt__" and idx = 3 // Greater than method
  or
  result = "__ge__" and idx = 4 // Greater than or equal method
}

// Determine if a class or its superclass hierarchy implements a specific comparison method
predicate classImplementsComparisonMethod(ClassValue classObj, string methodName) {
  methodName = comparisonMethodNameForIndex(_) and ( // Validate comparison method name
    classObj.declaresAttribute(methodName) // Direct implementation in the class
    or
    exists(ClassValue superClass | superClass = classObj.getASuperType() and not superClass = Value::named("object") | // Check inheritance chain
      superClass.declaresAttribute(methodName)
    )
  )
}

// Find a comparison method that is not implemented by the specified class
string missingComparisonMethod(ClassValue classObj, int idx) {
  not classObj = Value::named("object") and // Exclude the base object class
  not classImplementsComparisonMethod(classObj, result) and // Method must be missing
  result = comparisonMethodNameForIndex(idx) // Get method name by index
}

// Build a formatted string listing all missing comparison methods
string formatMissingMethodsList(ClassValue classObj, int idx) {
  idx = 0 and result = "" and exists(missingComparisonMethod(classObj, _)) // Initialize and verify missing methods exist
  or
  exists(string accumulatedStr, int prevIdx | idx = prevIdx + 1 and accumulatedStr = formatMissingMethodsList(classObj, prevIdx) | // Recursive construction
    accumulatedStr = "" and result = missingComparisonMethod(classObj, idx) // First missing method
    or
    result = accumulatedStr and not exists(missingComparisonMethod(classObj, idx)) and idx < 5 // Skip implemented methods
    or
    accumulatedStr != "" and result = accumulatedStr + " or " + missingComparisonMethod(classObj, idx) // Append with separator
  )
}

// Retrieve a comparison method that is directly declared by the class (not inherited)
Value getDirectlyDeclaredComparisonMethod(ClassValue classObj, string methodName) {
  /* Only report methods directly declared by this class to avoid duplicate warnings for inherited methods */
  methodName = comparisonMethodNameForIndex(_) and result = classObj.declaredAttribute(methodName) // Return declared method
}

// Main query logic: identify classes with incomplete ordering implementations
from ClassValue classObj, Value declaredMethod, string methodName
where
  not classObj.failedInference(_) and // Exclude classes with inference failures
  not hasTotalOrderingDecorator(classObj.getScope()) and // Exclude classes using total_ordering decorator
  declaredMethod = getDirectlyDeclaredComparisonMethod(classObj, methodName) and // Get a declared comparison method
  exists(missingComparisonMethod(classObj, _)) // Ensure at least one method is missing
select classObj,
  "Class " + classObj.getName() + " implements $@, but does not implement " + // Format the warning message
    formatMissingMethodsList(classObj, 4) + ".", declaredMethod, methodName // Include missing methods in output