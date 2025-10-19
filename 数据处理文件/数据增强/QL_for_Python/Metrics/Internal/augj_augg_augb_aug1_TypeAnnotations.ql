/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Core Python built-in types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or 
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign annotatedAssignment) { exists(annotatedAssignment.getAnnotation()) }

// Base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr functionExpr;
  AnnotatedFunction() { this = TAnnotatedFunction(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign annotatedAssignment;
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

/** Check if annotation is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Check if annotation represents a complex type structure */
predicate is_complex_type(Expr annotationExpr) {
  annotationExpr instanceof Subscript and not is_optional_type(annotationExpr)
  or
  annotationExpr instanceof Tuple
  or
  annotationExpr instanceof List
}

/** Check if annotation is an Optional type */
predicate is_optional_type(Subscript annotationExpr) { annotationExpr.getObject().(Name).getId() = "Optional" }

/** Check if annotation is a simple user-defined type */
predicate is_simple_type(Expr annotationExpr) {
  annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType
  or
  is_simple_type(annotationExpr.(Attribute).getObject())
}

/** Check if annotation is a built-in type */
predicate is_builtin_type(Expr annotationExpr) { annotationExpr instanceof BuiltinType }

// Calculate type annotation metrics for different categories
predicate type_metrics(
  string category, int totalCount, int builtinCount, int forwardCount, 
  int simpleCount, int complexCount, int optionalCount
) {
  // Parameter annotations
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter annotatedParameter) and
  builtinCount = count(AnnotatedParameter annotatedParameter | is_builtin_type(annotatedParameter.getAnnotation())) and
  forwardCount = count(AnnotatedParameter annotatedParameter | is_forward_declaration(annotatedParameter.getAnnotation())) and
  simpleCount = count(AnnotatedParameter annotatedParameter | is_simple_type(annotatedParameter.getAnnotation())) and
  complexCount = count(AnnotatedParameter annotatedParameter | is_complex_type(annotatedParameter.getAnnotation())) and
  optionalCount = count(AnnotatedParameter annotatedParameter | is_optional_type(annotatedParameter.getAnnotation()))
  or
  // Return type annotations
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction annotatedFunction) and
  builtinCount = count(AnnotatedFunction annotatedFunction | is_builtin_type(annotatedFunction.getAnnotation())) and
  forwardCount = count(AnnotatedFunction annotatedFunction | is_forward_declaration(annotatedFunction.getAnnotation())) and
  simpleCount = count(AnnotatedFunction annotatedFunction | is_simple_type(annotatedFunction.getAnnotation())) and
  complexCount = count(AnnotatedFunction annotatedFunction | is_complex_type(annotatedFunction.getAnnotation())) and
  optionalCount = count(AnnotatedFunction annotatedFunction | is_optional_type(annotatedFunction.getAnnotation()))
  or
  // Annotated assignments
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment annotatedAssignment) and
  builtinCount = count(AnnotatedAssignment annotatedAssignment | is_builtin_type(annotatedAssignment.getAnnotation())) and
  forwardCount = count(AnnotatedAssignment annotatedAssignment | is_forward_declaration(annotatedAssignment.getAnnotation())) and
  simpleCount = count(AnnotatedAssignment annotatedAssignment | is_simple_type(annotatedAssignment.getAnnotation())) and
  complexCount = count(AnnotatedAssignment annotatedAssignment | is_complex_type(annotatedAssignment.getAnnotation())) and
  optionalCount = count(AnnotatedAssignment annotatedAssignment | is_optional_type(annotatedAssignment.getAnnotation()))
}

// Query execution and result projection
from
  string category, int totalCount, int builtinCount, int forwardCount, 
  int simpleCount, int complexCount, int optionalCount
where type_metrics(category, totalCount, builtinCount, forwardCount, simpleCount, complexCount, optionalCount)
select category, totalCount, builtinCount, forwardCount, simpleCount, complexCount, optionalCount