/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents core Python built-in types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or 
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign annotatedAssign) { exists(annotatedAssign.getAnnotation()) }

// Base class for elements that can have type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr functionExpression;
  AnnotatedFunction() { this = TAnnotatedFunction(functionExpression) }
  override Expr getAnnotation() { result = functionExpression.getReturns() }
}

// Represents parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign annotatedAssignment;
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

/** Determines if an annotation is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Determines if an annotation represents a complex type structure */
predicate is_complex_type(Expr annotationExpr) {
  annotationExpr instanceof Subscript and not is_optional_type(annotationExpr)
  or
  annotationExpr instanceof Tuple
  or
  annotationExpr instanceof List
}

/** Determines if an annotation is an Optional type */
predicate is_optional_type(Subscript annotationExpr) { annotationExpr.getObject().(Name).getId() = "Optional" }

/** Determines if an annotation is a simple user-defined type */
predicate is_simple_type(Expr annotationExpr) {
  annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType
  or
  is_simple_type(annotationExpr.(Attribute).getObject())
}

/** Determines if an annotation is a built-in type */
predicate is_builtin_type(Expr annotationExpr) { annotationExpr instanceof BuiltinType }

// Computes type annotation metrics for different annotation categories
predicate type_count(
  string kind, int total, int built_in_count, int forward_declaration_count, 
  int simple_type_count, int complex_type_count, int optional_type_count
) {
  kind = "Parameter annotation" and
  total = count(AnnotatedParameter annotatedParameter) and
  built_in_count = count(AnnotatedParameter annotatedParameter | is_builtin_type(annotatedParameter.getAnnotation())) and
  forward_declaration_count = count(AnnotatedParameter annotatedParameter | is_forward_declaration(annotatedParameter.getAnnotation())) and
  simple_type_count = count(AnnotatedParameter annotatedParameter | is_simple_type(annotatedParameter.getAnnotation())) and
  complex_type_count = count(AnnotatedParameter annotatedParameter | is_complex_type(annotatedParameter.getAnnotation())) and
  optional_type_count = count(AnnotatedParameter annotatedParameter | is_optional_type(annotatedParameter.getAnnotation()))
  or
  kind = "Return type annotation" and
  total = count(AnnotatedFunction annotatedFunction) and
  built_in_count = count(AnnotatedFunction annotatedFunction | is_builtin_type(annotatedFunction.getAnnotation())) and
  forward_declaration_count = count(AnnotatedFunction annotatedFunction | is_forward_declaration(annotatedFunction.getAnnotation())) and
  simple_type_count = count(AnnotatedFunction annotatedFunction | is_simple_type(annotatedFunction.getAnnotation())) and
  complex_type_count = count(AnnotatedFunction annotatedFunction | is_complex_type(annotatedFunction.getAnnotation())) and
  optional_type_count = count(AnnotatedFunction annotatedFunction | is_optional_type(annotatedFunction.getAnnotation()))
  or
  kind = "Annotated assignment" and
  total = count(AnnotatedAssignment annotatedAssignment) and
  built_in_count = count(AnnotatedAssignment annotatedAssignment | is_builtin_type(annotatedAssignment.getAnnotation())) and
  forward_declaration_count = count(AnnotatedAssignment annotatedAssignment | is_forward_declaration(annotatedAssignment.getAnnotation())) and
  simple_type_count = count(AnnotatedAssignment annotatedAssignment | is_simple_type(annotatedAssignment.getAnnotation())) and
  complex_type_count = count(AnnotatedAssignment annotatedAssignment | is_complex_type(annotatedAssignment.getAnnotation())) and
  optional_type_count = count(AnnotatedAssignment annotatedAssignment | is_optional_type(annotatedAssignment.getAnnotation()))
}

// Query execution and result projection
from
  string message, int total, int built_in, int forward_decl, int simple, int complex, int optional
where type_count(message, total, built_in, forward_decl, simple, complex, optional)
select message, total, built_in, forward_decl, simple, complex, optional