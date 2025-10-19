/**
 * @name Type metrics
 * @description Provides counts of different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr func) { exists(func.getReturns()) } or
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr func;

  AnnotatedFunction() { this = TAnnotatedFunction(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter param;

  AnnotatedParameter() { this = TAnnotatedParameter(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assign;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
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
  totalCount = count(AnnotatedParameter p) and
  builtinCount = count(AnnotatedParameter p | is_builtin_type(p.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter p | is_forward_declaration(p.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter p | is_simple_type(p.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter p | is_complex_type(p.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter p | is_optional_type(p.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction f) and
  builtinCount = count(AnnotatedFunction f | is_builtin_type(f.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction f | is_forward_declaration(f.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction f | is_simple_type(f.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction f | is_complex_type(f.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction f | is_optional_type(f.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment a) and
  builtinCount = count(AnnotatedAssignment a | is_builtin_type(a.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment a | is_forward_declaration(a.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment a | is_simple_type(a.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment a | is_complex_type(a.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment a | is_optional_type(a.getAnnotation()))
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