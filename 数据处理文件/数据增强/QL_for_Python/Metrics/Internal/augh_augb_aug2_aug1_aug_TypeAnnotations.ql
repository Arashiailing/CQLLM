/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code,
 *              including parameter annotations, return types, and annotated assignments.
 *              Metrics include total counts and breakdowns by annotation complexity.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class PythonBuiltinType extends Name {
  PythonBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class AnnotatableElement extends TypeAnnotatable {
  string toString() { result = "AnnotatableElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, AnnotatableElement {
  FunctionExpr functionExpr;

  AnnotatedFunction() { this = TAnnotatedFunction(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, AnnotatableElement {
  Parameter parameter;

  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, AnnotatableElement {
  AnnAssign assignment;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** Determines if `annotationExpr` is a forward-declared type (string literal). */
predicate isForwardDeclaration(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Determines if `annotationExpr` is a complex type that may be difficult to analyze. */
predicate isComplexType(Expr annotationExpr) {
  (annotationExpr instanceof Subscript and not isOptionalType(annotationExpr)) or
  annotationExpr instanceof Tuple or
  annotationExpr instanceof List
}

/** Determines if `annotationExpr` is an Optional type (e.g., Optional[...]). */
predicate isOptionalType(Subscript annotationExpr) { annotationExpr.getObject().(Name).getId() = "Optional" }

/** Determines if `annotationExpr` is a simple type (non-built-in identifier or attribute chain). */
predicate isSimpleType(Expr annotationExpr) {
  (annotationExpr instanceof Name and not annotationExpr instanceof PythonBuiltinType) or
  isSimpleType(annotationExpr.(Attribute).getObject())
}

/** Determines if `annotationExpr` is a built-in type. */
predicate isBuiltinType(Expr annotationExpr) { annotationExpr instanceof PythonBuiltinType }

// Computes metrics for different categories of type annotations
predicate typeAnnotationMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter annotatedParameter) and
  builtinCount = count(AnnotatedParameter annotatedParameter | isBuiltinType(annotatedParameter.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter annotatedParameter | isForwardDeclaration(annotatedParameter.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter annotatedParameter | isSimpleType(annotatedParameter.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter annotatedParameter | isComplexType(annotatedParameter.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter annotatedParameter | isOptionalType(annotatedParameter.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction annotatedFunction) and
  builtinCount = count(AnnotatedFunction annotatedFunction | isBuiltinType(annotatedFunction.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction annotatedFunction | isForwardDeclaration(annotatedFunction.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction annotatedFunction | isSimpleType(annotatedFunction.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction annotatedFunction | isComplexType(annotatedFunction.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction annotatedFunction | isOptionalType(annotatedFunction.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment annotatedAssignment) and
  builtinCount = count(AnnotatedAssignment annotatedAssignment | isBuiltinType(annotatedAssignment.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment annotatedAssignment | isForwardDeclaration(annotatedAssignment.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment annotatedAssignment | isSimpleType(annotatedAssignment.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment annotatedAssignment | isComplexType(annotatedAssignment.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment annotatedAssignment | isOptionalType(annotatedAssignment.getAnnotation()))
}

// Query execution and results output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  typeAnnotationMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount