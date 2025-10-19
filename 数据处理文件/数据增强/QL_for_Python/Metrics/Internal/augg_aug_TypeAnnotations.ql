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
  TAnnotatedFunction(FunctionExpr item) { exists(item.getReturns()) } or
  TAnnotatedParameter(Parameter item) { exists(item.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign item) { exists(item.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr item;

  AnnotatedFunction() { this = TAnnotatedFunction(item) }
  override Expr getAnnotation() { result = item.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter item;

  AnnotatedParameter() { this = TAnnotatedParameter(item) }
  override Expr getAnnotation() { result = item.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign item;

  AnnotatedAssignment() { this = TAnnotatedAssignment(item) }
  override Expr getAnnotation() { result = item.getAnnotation() }
}

/** Checks if an expression is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr expr) { expr instanceof StringLiteral }

/** Checks if an expression represents a complex type that's difficult to analyze. */
predicate is_complex_type(Expr expr) {
  expr instanceof Subscript and not is_optional_type(expr) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Checks if an expression is an Optional type (e.g., Optional[int]). */
predicate is_optional_type(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Checks if an expression is a simple non-built-in type (identifier or attribute chain). */
predicate is_simple_type(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType or
  is_simple_type(expr.(Attribute).getObject())
}

/** Checks if an expression is a built-in type. */
predicate is_builtin_type(Expr expr) { expr instanceof BuiltinType }

// Computes metrics for different annotation categories
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter item) and
  builtinCount = count(AnnotatedParameter item | is_builtin_type(item.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter item | is_forward_declaration(item.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter item | is_simple_type(item.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter item | is_complex_type(item.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter item | is_optional_type(item.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction item) and
  builtinCount = count(AnnotatedFunction item | is_builtin_type(item.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction item | is_forward_declaration(item.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction item | is_simple_type(item.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction item | is_complex_type(item.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction item | is_optional_type(item.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment item) and
  builtinCount = count(AnnotatedAssignment item | is_builtin_type(item.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment item | is_forward_declaration(item.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment item | is_simple_type(item.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment item | is_complex_type(item.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment item | is_optional_type(item.getAnnotation()))
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