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
  FunctionExpr funcExpr;

  AnnotatedFunction() { this = TAnnotatedFunction(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter paramVar;

  AnnotatedParameter() { this = TAnnotatedParameter(paramVar) }
  override Expr getAnnotation() { result = paramVar.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignStmt;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignStmt) }
  override Expr getAnnotation() { result = assignStmt.getAnnotation() }
}

// Helper predicates to categorize type annotations

/** 
 * Determines if an expression is a forward declaration of a type.
 * Forward declarations are represented as string literals.
 */
predicate isForwardDeclaration(Expr expr) { expr instanceof StringLiteral }

/** 
 * Determines if an expression represents a complex type.
 * Complex types include subscripts (excluding Optional), tuples, and lists.
 */
predicate isComplexType(Expr expr) {
  (expr instanceof Subscript and not isOptionalType(expr)) or
  expr instanceof Tuple or
  expr instanceof List
}

/** 
 * Determines if an expression represents an Optional type.
 * Optional types have the form `Optional[...]`.
 */
predicate isOptionalType(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** 
 * Determines if an expression represents a simple type.
 * Simple types are non-built-in identifiers or attribute chains.
 */
predicate isSimpleType(Expr expr) {
  (expr instanceof Name and not expr instanceof BuiltinType) or
  isSimpleType(expr.(Attribute).getObject())
}

/** 
 * Determines if an expression represents a built-in type.
 */
predicate isBuiltinType(Expr expr) { expr instanceof BuiltinType }

// Computes type annotation metrics for different annotation categories
predicate computeTypeMetrics(
  string category, int total, int builtin, int forwardDecl, 
  int simple, int complex, int optional
) {
  // Parameter annotation metrics
  (
    category = "Parameter annotation" and
    total = count(AnnotatedParameter param) and
    builtin = count(AnnotatedParameter param | isBuiltinType(param.getAnnotation())) and
    forwardDecl = count(AnnotatedParameter param | isForwardDeclaration(param.getAnnotation())) and
    simple = count(AnnotatedParameter param | isSimpleType(param.getAnnotation())) and
    complex = count(AnnotatedParameter param | isComplexType(param.getAnnotation())) and
    optional = count(AnnotatedParameter param | isOptionalType(param.getAnnotation()))
  )
  or
  // Return type annotation metrics
  (
    category = "Return type annotation" and
    total = count(AnnotatedFunction func) and
    builtin = count(AnnotatedFunction func | isBuiltinType(func.getAnnotation())) and
    forwardDecl = count(AnnotatedFunction func | isForwardDeclaration(func.getAnnotation())) and
    simple = count(AnnotatedFunction func | isSimpleType(func.getAnnotation())) and
    complex = count(AnnotatedFunction func | isComplexType(func.getAnnotation())) and
    optional = count(AnnotatedFunction func | isOptionalType(func.getAnnotation()))
  )
  or
  // Annotated assignment metrics
  (
    category = "Annotated assignment" and
    total = count(AnnotatedAssignment assign) and
    builtin = count(AnnotatedAssignment assign | isBuiltinType(assign.getAnnotation())) and
    forwardDecl = count(AnnotatedAssignment assign | isForwardDeclaration(assign.getAnnotation())) and
    simple = count(AnnotatedAssignment assign | isSimpleType(assign.getAnnotation())) and
    complex = count(AnnotatedAssignment assign | isComplexType(assign.getAnnotation())) and
    optional = count(AnnotatedAssignment assign | isOptionalType(assign.getAnnotation()))
  )
}

// Query execution and output
from 
  string category, int total, int builtin, int forwardDecl, 
  int simple, int complex, int optional
where 
  computeTypeMetrics(category, total, builtin, forwardDecl, simple, complex, optional)
select 
  category, total, builtin, forwardDecl, simple, complex, optional