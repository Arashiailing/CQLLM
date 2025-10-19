/**
 * @name Type metrics
 * @description Provides counts of different kinds of type annotations in Python code, including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python.
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr function) { exists(function.getReturns()) } or
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
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
  Parameter parameterVar;

  AnnotatedParameter() { this = TAnnotatedParameter(parameterVar) }
  override Expr getAnnotation() { result = parameterVar.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignmentStmt;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
}

/** Holds if `expr` is a forward declaration (string literal) of a type. */
predicate is_forward_declaration(Expr expr) { expr instanceof StringLiteral }

/** Holds if `expr` is a type that may be difficult to analyze. */
predicate is_complex_type(Expr expr) {
  (expr instanceof Subscript and not is_optional_type(expr)) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Holds if `expr` is a type of the form `Optional[...]`. */
predicate is_optional_type(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Holds if `expr` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr expr) {
  (expr instanceof Name and not expr instanceof BuiltinType) or
  is_simple_type(expr.(Attribute).getObject())
}

/** Holds if `expr` is a built-in type. */
predicate is_builtin_type(Expr expr) { expr instanceof BuiltinType }

// Computes type annotation metrics for different annotation categories
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter parameter) and
  builtinCount = count(AnnotatedParameter parameter | is_builtin_type(parameter.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter parameter | is_forward_declaration(parameter.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter parameter | is_simple_type(parameter.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter parameter | is_complex_type(parameter.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter parameter | is_optional_type(parameter.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction function) and
  builtinCount = count(AnnotatedFunction function | is_builtin_type(function.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction function | is_forward_declaration(function.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction function | is_simple_type(function.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction function | is_complex_type(function.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction function | is_optional_type(function.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment assignment) and
  builtinCount = count(AnnotatedAssignment assignment | is_builtin_type(assignment.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment assignment | is_forward_declaration(assignment.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment assignment | is_simple_type(assignment.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment assignment | is_complex_type(assignment.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment assignment | is_optional_type(assignment.getAnnotation()))
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