/**
 * @name Type metrics
 * @description Analyzes and counts different types of type annotations in Python code,
 *              including parameter types, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python's built-in types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr annotatedElement) { exists(annotatedElement.getReturns()) } or
  TAnnotatedParameter(Parameter annotatedElement) { exists(annotatedElement.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign annotatedElement) { exists(annotatedElement.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr annotatedElement;

  AnnotatedFunction() { this = TAnnotatedFunction(annotatedElement) }
  override Expr getAnnotation() { result = annotatedElement.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter annotatedElement;

  AnnotatedParameter() { this = TAnnotatedParameter(annotatedElement) }
  override Expr getAnnotation() { result = annotatedElement.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign annotatedElement;

  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedElement) }
  override Expr getAnnotation() { result = annotatedElement.getAnnotation() }
}

/** Checks if an expression is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr typeExpr) { typeExpr instanceof StringLiteral }

/** Checks if an expression represents a complex type that's difficult to analyze. */
predicate is_complex_type(Expr typeExpr) {
  (typeExpr instanceof Subscript and not is_optional_type(typeExpr)) or
  typeExpr instanceof Tuple or
  typeExpr instanceof List
}

/** Checks if an expression is an Optional type (e.g., Optional[int]). */
predicate is_optional_type(Subscript typeExpr) { typeExpr.getObject().(Name).getId() = "Optional" }

/** Checks if an expression is a simple non-built-in type (identifier or attribute chain). */
predicate is_simple_type(Expr typeExpr) {
  (typeExpr instanceof Name and not typeExpr instanceof BuiltinType) or
  is_simple_type(typeExpr.(Attribute).getObject())
}

/** Checks if an expression is a built-in type. */
predicate is_builtin_type(Expr typeExpr) { typeExpr instanceof BuiltinType }

// Computes metrics for different annotation categories
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter annotatedElement) and
  builtinCount = count(AnnotatedParameter annotatedElement | is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter annotatedElement | is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter annotatedElement | is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter annotatedElement | is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter annotatedElement | is_optional_type(annotatedElement.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction annotatedElement) and
  builtinCount = count(AnnotatedFunction annotatedElement | is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction annotatedElement | is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction annotatedElement | is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction annotatedElement | is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction annotatedElement | is_optional_type(annotatedElement.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment annotatedElement) and
  builtinCount = count(AnnotatedAssignment annotatedElement | is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment annotatedElement | is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment annotatedElement | is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment annotatedElement | is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment annotatedElement | is_optional_type(annotatedElement.getAnnotation()))
}

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount