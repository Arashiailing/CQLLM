/**
 * @name Type metrics
 * @description Computes metrics for Python type annotations across parameters, 
 *              return types, and annotated assignments, categorizing them by 
 *              complexity and usage patterns.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents fundamental Python built-in types (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
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

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignment;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

// =====================================================================
// Type Classification Predicates
// =====================================================================

/** Detects forward-declared types (string literals) */
predicate is_forward_declaration(Expr typeExpr) { 
  typeExpr instanceof StringLiteral 
}

/** Identifies complex types (subscripts, tuples, lists) excluding Optional */
predicate is_complex_type(Expr typeExpr) {
  (typeExpr instanceof Subscript and not is_optional_type(typeExpr)) or
  typeExpr instanceof Tuple or
  typeExpr instanceof List
}

/** Detects Optional[...] type patterns for nullable types */
predicate is_optional_type(Subscript typeExpr) { 
  typeExpr.getObject().(Name).getId() = "Optional" 
}

/** Identifies simple types (non-built-in identifiers or attribute chains) */
predicate is_simple_type(Expr typeExpr) {
  (typeExpr instanceof Name and not typeExpr instanceof BuiltinType) or
  is_simple_type(typeExpr.(Attribute).getObject())
}

/** Detects built-in types (int, float, str, bool, bytes, None) */
predicate is_builtin_type(Expr typeExpr) { 
  typeExpr instanceof BuiltinType 
}

// =====================================================================
// Metrics Computation
// =====================================================================

// Computes type annotation metrics for different categories
predicate type_annotation_metrics(
  string category, int totalAnnotations, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalAnnotations = count(AnnotatedParameter parameter) and
  builtinTypeCount = count(AnnotatedParameter parameter | is_builtin_type(parameter.getAnnotation())) and
  forwardDeclarationCount = count(AnnotatedParameter parameter | is_forward_declaration(parameter.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter parameter | is_simple_type(parameter.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter parameter | is_complex_type(parameter.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter parameter | is_optional_type(parameter.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalAnnotations = count(AnnotatedFunction functionExpr) and
  builtinTypeCount = count(AnnotatedFunction functionExpr | is_builtin_type(functionExpr.getAnnotation())) and
  forwardDeclarationCount = count(AnnotatedFunction functionExpr | is_forward_declaration(functionExpr.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction functionExpr | is_simple_type(functionExpr.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction functionExpr | is_complex_type(functionExpr.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction functionExpr | is_optional_type(functionExpr.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalAnnotations = count(AnnotatedAssignment assignment) and
  builtinTypeCount = count(AnnotatedAssignment assignment | is_builtin_type(assignment.getAnnotation())) and
  forwardDeclarationCount = count(AnnotatedAssignment assignment | is_forward_declaration(assignment.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment assignment | is_simple_type(assignment.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment assignment | is_complex_type(assignment.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment assignment | is_optional_type(assignment.getAnnotation()))
}

// =====================================================================
// Query Execution
// =====================================================================

// Query execution and result projection
from 
  string category, int totalAnnotations, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalAnnotations, builtinTypeCount, forwardDeclarationCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalAnnotations, builtinTypeCount, forwardDeclarationCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount