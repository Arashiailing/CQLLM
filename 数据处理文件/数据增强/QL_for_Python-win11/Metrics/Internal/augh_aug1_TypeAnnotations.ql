/**
 * @name Type metrics
 * @description Counts of various kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types like int, float, str, etc.
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type definition for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr function) { exists(function.getReturns()) } or 
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for all elements that can have type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr functionExpr;
  AnnotatedFunction() { this = TAnnotatedFunction(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignmentStmt;
  AnnotatedAssignment() { this = TAnnotatedAssignment(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
}

// Helper predicates to classify type annotations

/** Determines if an expression is a forward-declared type (string literal) */
predicate isForwardDeclaration(Expr expr) { expr instanceof StringLiteral }

/** Determines if an expression represents a complex type structure */
predicate isComplexType(Expr expr) {
  expr instanceof Subscript and not isOptionalType(expr)
  or
  expr instanceof Tuple
  or
  expr instanceof List
}

/** Determines if an expression is an Optional type */
predicate isOptionalType(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Determines if an expression is a simple user-defined type */
predicate isSimpleType(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType
  or
  isSimpleType(expr.(Attribute).getObject())
}

/** Determines if an expression is a built-in type */
predicate isBuiltinType(Expr expr) { expr instanceof BuiltinType }

// Computes type annotation metrics for different categories
predicate computeTypeMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Metrics for parameter annotations
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter annotatedParam) and
  builtinCount = count(AnnotatedParameter annotatedParam | isBuiltinType(annotatedParam.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter annotatedParam | isForwardDeclaration(annotatedParam.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter annotatedParam | isSimpleType(annotatedParam.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter annotatedParam | isComplexType(annotatedParam.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter annotatedParam | isOptionalType(annotatedParam.getAnnotation()))
  or
  // Metrics for return type annotations
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction annotatedFunc) and
  builtinCount = count(AnnotatedFunction annotatedFunc | isBuiltinType(annotatedFunc.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction annotatedFunc | isForwardDeclaration(annotatedFunc.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction annotatedFunc | isSimpleType(annotatedFunc.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction annotatedFunc | isComplexType(annotatedFunc.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction annotatedFunc | isOptionalType(annotatedFunc.getAnnotation()))
  or
  // Metrics for annotated assignments
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment annotatedAssign) and
  builtinCount = count(AnnotatedAssignment annotatedAssign | isBuiltinType(annotatedAssign.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment annotatedAssign | isForwardDeclaration(annotatedAssign.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment annotatedAssign | isSimpleType(annotatedAssign.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment annotatedAssign | isComplexType(annotatedAssign.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment annotatedAssign | isOptionalType(annotatedAssign.getAnnotation()))
}

// Query execution and result selection
from
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  computeTypeMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                    simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount