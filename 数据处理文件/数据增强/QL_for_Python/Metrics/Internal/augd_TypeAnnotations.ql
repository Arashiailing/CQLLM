/**
 * @name Type metrics
 * @description Counts of various kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types
class BuiltinTypeName extends Name {
  BuiltinTypeName() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for all annotatable Python constructs
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr f) { exists(f.getReturns()) } or 
  TAnnotatedParameter(Parameter p) { exists(p.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign a) { exists(a.getAnnotation()) }

// Base class for all annotatable elements
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr func;
  AnnotatedFunction() { this = TAnnotatedFunction(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Represents parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter param;
  AnnotatedParameter() { this = TAnnotatedParameter(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Represents variable assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assign;
  AnnotatedAssignment() { this = TAnnotatedAssignment(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

/** Checks if an expression is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr expr) { expr instanceof StringLiteral }

/** Checks if an expression represents a complex type that's hard to analyze */
predicate is_complex_type(Expr expr) {
  expr instanceof Subscript and not is_optional_type(expr) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Checks if an expression is an Optional[...] type */
predicate is_optional_type(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Checks if an expression is a simple type (non-builtin identifier or attribute) */
predicate is_simple_type(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinTypeName or
  is_simple_type(expr.(Attribute).getObject())
}

/** Checks if an expression represents a built-in type */
predicate is_builtin_type(Expr expr) { expr instanceof BuiltinTypeName }

// Calculates type annotation metrics for different annotation categories
predicate type_count(
  string category, int total, int builtin, int forward, int simple, 
  int complex, int optional
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  total = count(AnnotatedParameter p) and
  builtin = count(AnnotatedParameter p | is_builtin_type(p.getAnnotation())) and
  forward = count(AnnotatedParameter p | is_forward_declaration(p.getAnnotation())) and
  simple = count(AnnotatedParameter p | is_simple_type(p.getAnnotation())) and
  complex = count(AnnotatedParameter p | is_complex_type(p.getAnnotation())) and
  optional = count(AnnotatedParameter p | is_optional_type(p.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  total = count(AnnotatedFunction f) and
  builtin = count(AnnotatedFunction f | is_builtin_type(f.getAnnotation())) and
  forward = count(AnnotatedFunction f | is_forward_declaration(f.getAnnotation())) and
  simple = count(AnnotatedFunction f | is_simple_type(f.getAnnotation())) and
  complex = count(AnnotatedFunction f | is_complex_type(f.getAnnotation())) and
  optional = count(AnnotatedFunction f | is_optional_type(f.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  total = count(AnnotatedAssignment a) and
  builtin = count(AnnotatedAssignment a | is_builtin_type(a.getAnnotation())) and
  forward = count(AnnotatedAssignment a | is_forward_declaration(a.getAnnotation())) and
  simple = count(AnnotatedAssignment a | is_simple_type(a.getAnnotation())) and
  complex = count(AnnotatedAssignment a | is_complex_type(a.getAnnotation())) and
  optional = count(AnnotatedAssignment a | is_optional_type(a.getAnnotation()))
}

from
  string category, int total, int builtin, int forward, int simple, int complex, int optional
where type_count(category, total, builtin, forward, simple, complex, optional)
select category, total, builtin, forward, simple, complex, optional