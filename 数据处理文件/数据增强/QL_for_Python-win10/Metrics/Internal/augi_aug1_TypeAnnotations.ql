/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Describes built-in Python types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines union type for elements that can be annotated
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr func) { exists(func.getReturns()) } or 
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements that can have type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents function expressions that have return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr func;
  AnnotatedFunction() { this = TAnnotatedFunction(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Represents parameters that have type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments that have type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignment;
  AnnotatedAssignment() { this = TAnnotatedAssignment(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** Determines if an expression is a forward-declared type (i.e., a string literal) */
predicate is_forward_declaration(Expr expr) { expr instanceof StringLiteral }

/** Determines if an expression represents a complex type structure */
predicate is_complex_type(Expr expr) {
  expr instanceof Subscript and not is_optional_type(expr)
  or
  expr instanceof Tuple
  or
  expr instanceof List
}

/** Determines if an expression is an Optional type */
predicate is_optional_type(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Determines if an expression is a simple user-defined type */
predicate is_simple_type(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType
  or
  is_simple_type(expr.(Attribute).getObject())
}

/** Determines if an expression is a built-in type */
predicate is_builtin_type(Expr expr) { expr instanceof BuiltinType }

// Computes metrics for type annotations in different categories
predicate type_count(
  string category, int total, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  category = "Parameter annotation" and
  total = count(AnnotatedParameter param) and
  builtinCount = count(AnnotatedParameter param | is_builtin_type(param.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter param | is_forward_declaration(param.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter param | is_simple_type(param.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter param | is_complex_type(param.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter param | is_optional_type(param.getAnnotation()))
  or
  category = "Return type annotation" and
  total = count(AnnotatedFunction func) and
  builtinCount = count(AnnotatedFunction func | is_builtin_type(func.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction func | is_forward_declaration(func.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction func | is_simple_type(func.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction func | is_complex_type(func.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction func | is_optional_type(func.getAnnotation()))
  or
  category = "Annotated assignment" and
  total = count(AnnotatedAssignment assign) and
  builtinCount = count(AnnotatedAssignment assign | is_builtin_type(assign.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment assign | is_forward_declaration(assign.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment assign | is_simple_type(assign.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment assign | is_complex_type(assign.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment assign | is_optional_type(assign.getAnnotation()))
}

// Query execution and result selection
from
  string message, int total, int built_in, int forward_decl, int simple, int complex, int optional
where type_count(message, total, built_in, forward_decl, simple, complex, optional)
select message, total, built_in, forward_decl, simple, complex, optional