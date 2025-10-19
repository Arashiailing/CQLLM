/**
 * @name Type metrics
 * @description Analyzes and counts various type annotation patterns in Python code,
 *              focusing on parameters, return types, and variable annotations.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a native type in Python (e.g., int, str, bool)
class NativeType extends Name {
  NativeType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TParameterWithType(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAssignmentWithType(AnnAssign annotatedAssignment) { exists(annotatedAssignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotatedElement extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatedElement {
  FunctionExpr functionExpr;

  FunctionWithReturnType() { this = TFunctionWithReturnType(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithType extends TParameterWithType, TypeAnnotatedElement {
  Parameter parameter;

  ParameterWithType() { this = TParameterWithType(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithType extends TAssignmentWithType, TypeAnnotatedElement {
  AnnAssign annotatedAssignment;

  AssignmentWithType() { this = TAssignmentWithType(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

// Type classification predicates

/** Holds if `expr` is a forward declaration (string literal) of a type. */
predicate isStringLiteralType(Expr expr) { expr instanceof StringLiteral }

/** Holds if `expr` is a type that may be difficult to analyze. */
predicate isComplexTypeAnnotation(Expr expr) {
  (expr instanceof Subscript and not isOptionalTypeAnnotation(expr)) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Holds if `expr` is a type of the form `Optional[...]`. */
predicate isOptionalTypeAnnotation(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Holds if `expr` is a simple type (non-built-in identifier or attribute chain). */
predicate isSimpleTypeAnnotation(Expr expr) {
  (expr instanceof Name and not expr instanceof NativeType) or
  isSimpleTypeAnnotation(expr.(Attribute).getObject())
}

/** Holds if `expr` is a built-in type. */
predicate isNativeTypeAnnotation(Expr expr) { expr instanceof NativeType }

// Computes type annotation metrics for different annotation categories
predicate calculateTypeMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    // Parameter annotation metrics
    category = "Parameter annotation" and
    totalCount = count(ParameterWithType parameter) and
    builtinCount = count(ParameterWithType parameter | isNativeTypeAnnotation(parameter.getAnnotation())) and
    forwardDeclCount = count(ParameterWithType parameter | isStringLiteralType(parameter.getAnnotation())) and
    simpleTypeCount = count(ParameterWithType parameter | isSimpleTypeAnnotation(parameter.getAnnotation())) and
    complexTypeCount = count(ParameterWithType parameter | isComplexTypeAnnotation(parameter.getAnnotation())) and
    optionalTypeCount = count(ParameterWithType parameter | isOptionalTypeAnnotation(parameter.getAnnotation()))
  )
  or
  (
    // Return type annotation metrics
    category = "Return type annotation" and
    totalCount = count(FunctionWithReturnType functionExpr) and
    builtinCount = count(FunctionWithReturnType functionExpr | isNativeTypeAnnotation(functionExpr.getAnnotation())) and
    forwardDeclCount = count(FunctionWithReturnType functionExpr | isStringLiteralType(functionExpr.getAnnotation())) and
    simpleTypeCount = count(FunctionWithReturnType functionExpr | isSimpleTypeAnnotation(functionExpr.getAnnotation())) and
    complexTypeCount = count(FunctionWithReturnType functionExpr | isComplexTypeAnnotation(functionExpr.getAnnotation())) and
    optionalTypeCount = count(FunctionWithReturnType functionExpr | isOptionalTypeAnnotation(functionExpr.getAnnotation()))
  )
  or
  (
    // Annotated assignment metrics
    category = "Annotated assignment" and
    totalCount = count(AssignmentWithType annotatedAssignment) and
    builtinCount = count(AssignmentWithType annotatedAssignment | isNativeTypeAnnotation(annotatedAssignment.getAnnotation())) and
    forwardDeclCount = count(AssignmentWithType annotatedAssignment | isStringLiteralType(annotatedAssignment.getAnnotation())) and
    simpleTypeCount = count(AssignmentWithType annotatedAssignment | isSimpleTypeAnnotation(annotatedAssignment.getAnnotation())) and
    complexTypeCount = count(AssignmentWithType annotatedAssignment | isComplexTypeAnnotation(annotatedAssignment.getAnnotation())) and
    optionalTypeCount = count(AssignmentWithType annotatedAssignment | isOptionalTypeAnnotation(annotatedAssignment.getAnnotation()))
  )
}

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateTypeMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount