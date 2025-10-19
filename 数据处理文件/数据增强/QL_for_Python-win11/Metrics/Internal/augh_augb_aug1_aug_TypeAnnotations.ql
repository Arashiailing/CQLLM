/**
 * @name Type annotation metrics analyzer
 * @description Quantifies various categories of type annotations in Python codebase, 
 *              covering function parameters, return types, and variable assignments.
 *              Classifies annotations as built-in, forward declarations, simple types,
 *              complex types, or optional types.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python's primitive types (e.g., int, str, bool)
class CoreType extends Name {
  CoreType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotationTarget =
  TTypedFunction(FunctionExpr function) { exists(function.getReturns()) } or
  TTypedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TTypedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Base abstraction for type annotation targets
abstract class AnnotationTarget extends TAnnotationTarget {
  string toString() { result = "AnnotationTarget" }
  abstract Expr getTypeAnnotation();
}

// Functions with explicit return type annotations
class TypedFunction extends TTypedFunction, AnnotationTarget {
  FunctionExpr function;

  TypedFunction() { this = TTypedFunction(function) }
  override Expr getTypeAnnotation() { result = function.getReturns() }
}

// Parameters with type annotations
class TypedParameter extends TTypedParameter, AnnotationTarget {
  Parameter parameter;

  TypedParameter() { this = TTypedParameter(parameter) }
  override Expr getTypeAnnotation() { result = parameter.getAnnotation() }
}

// Variable assignments with type annotations
class TypedAssignment extends TTypedAssignment, AnnotationTarget {
  AnnAssign assignment;

  TypedAssignment() { this = TTypedAssignment(assignment) }
  override Expr getTypeAnnotation() { result = assignment.getAnnotation() }
}

/** Identifies forward-declared types (string literals) */
predicate is_forward_declared(Expr typeExpr) { typeExpr instanceof StringLiteral }

/** Identifies complex type structures requiring deeper analysis */
predicate is_complex_type_structure(Expr typeExpr) {
  (typeExpr instanceof Subscript and not is_optional_type(typeExpr)) or
  typeExpr instanceof Tuple or
  typeExpr instanceof List
}

/** Identifies Optional[...] type patterns */
predicate is_optional_type(Subscript typeExpr) { typeExpr.getObject().(Name).getId() = "Optional" }

/** Identifies simple custom types (non-built-in identifiers or attribute chains) */
predicate is_simple_custom_type(Expr typeExpr) {
  (typeExpr instanceof Name and not typeExpr instanceof CoreType) or
  is_simple_custom_type(typeExpr.(Attribute).getObject())
}

/** Identifies built-in type annotations */
predicate is_core_type(Expr typeExpr) { typeExpr instanceof CoreType }

// Aggregates type annotation statistics by category
predicate calculate_annotation_metrics(
  string category, int totalAnnotations, int coreTypeCount, int forwardDeclaredCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation statistics
  category = "Parameter annotation" and
  totalAnnotations = count(TypedParameter parameter) and
  coreTypeCount = count(TypedParameter parameter | is_core_type(parameter.getTypeAnnotation())) and
  forwardDeclaredCount = count(TypedParameter parameter | is_forward_declared(parameter.getTypeAnnotation())) and
  simpleTypeCount = count(TypedParameter parameter | is_simple_custom_type(parameter.getTypeAnnotation())) and
  complexTypeCount = count(TypedParameter parameter | is_complex_type_structure(parameter.getTypeAnnotation())) and
  optionalTypeCount = count(TypedParameter parameter | is_optional_type(parameter.getTypeAnnotation()))
  or
  // Return type annotation statistics
  category = "Return type annotation" and
  totalAnnotations = count(TypedFunction function) and
  coreTypeCount = count(TypedFunction function | is_core_type(function.getTypeAnnotation())) and
  forwardDeclaredCount = count(TypedFunction function | is_forward_declared(function.getTypeAnnotation())) and
  simpleTypeCount = count(TypedFunction function | is_simple_custom_type(function.getTypeAnnotation())) and
  complexTypeCount = count(TypedFunction function | is_complex_type_structure(function.getTypeAnnotation())) and
  optionalTypeCount = count(TypedFunction function | is_optional_type(function.getTypeAnnotation()))
  or
  // Annotated assignment statistics
  category = "Annotated assignment" and
  totalAnnotations = count(TypedAssignment assignment) and
  coreTypeCount = count(TypedAssignment assignment | is_core_type(assignment.getTypeAnnotation())) and
  forwardDeclaredCount = count(TypedAssignment assignment | is_forward_declared(assignment.getTypeAnnotation())) and
  simpleTypeCount = count(TypedAssignment assignment | is_simple_custom_type(assignment.getTypeAnnotation())) and
  complexTypeCount = count(TypedAssignment assignment | is_complex_type_structure(assignment.getTypeAnnotation())) and
  optionalTypeCount = count(TypedAssignment assignment | is_optional_type(assignment.getTypeAnnotation()))
}

// Query execution and result formatting
from 
  string category, int totalAnnotations, int coreTypeCount, int forwardDeclaredCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculate_annotation_metrics(category, totalAnnotations, coreTypeCount, forwardDeclaredCount, 
                               simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalAnnotations, coreTypeCount, forwardDeclaredCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount