/**
 * @name Type metrics
 * @description Provides counts of different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python, such as int, float, str, etc.
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr function) { exists(function.getReturns()) } or
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign statement) { exists(statement.getAnnotation()) }

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
  Parameter parameter;

  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignmentStmt;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
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
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleCount, int complexCount, int optionalCount
) {
  // Parameter annotation metrics
  (
    category = "Parameter annotation" and
    totalCount = count(AnnotatedParameter paramItem) and
    builtinCount = count(AnnotatedParameter paramItem | isBuiltinType(paramItem.getAnnotation())) and
    forwardDeclCount = count(AnnotatedParameter paramItem | isForwardDeclaration(paramItem.getAnnotation())) and
    simpleCount = count(AnnotatedParameter paramItem | isSimpleType(paramItem.getAnnotation())) and
    complexCount = count(AnnotatedParameter paramItem | isComplexType(paramItem.getAnnotation())) and
    optionalCount = count(AnnotatedParameter paramItem | isOptionalType(paramItem.getAnnotation()))
  )
  or
  // Return type annotation metrics
  (
    category = "Return type annotation" and
    totalCount = count(AnnotatedFunction funcItem) and
    builtinCount = count(AnnotatedFunction funcItem | isBuiltinType(funcItem.getAnnotation())) and
    forwardDeclCount = count(AnnotatedFunction funcItem | isForwardDeclaration(funcItem.getAnnotation())) and
    simpleCount = count(AnnotatedFunction funcItem | isSimpleType(funcItem.getAnnotation())) and
    complexCount = count(AnnotatedFunction funcItem | isComplexType(funcItem.getAnnotation())) and
    optionalCount = count(AnnotatedFunction funcItem | isOptionalType(funcItem.getAnnotation()))
  )
  or
  // Annotated assignment metrics
  (
    category = "Annotated assignment" and
    totalCount = count(AnnotatedAssignment assignItem) and
    builtinCount = count(AnnotatedAssignment assignItem | isBuiltinType(assignItem.getAnnotation())) and
    forwardDeclCount = count(AnnotatedAssignment assignItem | isForwardDeclaration(assignItem.getAnnotation())) and
    simpleCount = count(AnnotatedAssignment assignItem | isSimpleType(assignItem.getAnnotation())) and
    complexCount = count(AnnotatedAssignment assignItem | isComplexType(assignItem.getAnnotation())) and
    optionalCount = count(AnnotatedAssignment assignItem | isOptionalType(assignItem.getAnnotation()))
  )
}

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleCount, int complexCount, int optionalCount
where 
  computeTypeMetrics(category, totalCount, builtinCount, forwardDeclCount, simpleCount, complexCount, optionalCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, simpleCount, complexCount, optionalCount