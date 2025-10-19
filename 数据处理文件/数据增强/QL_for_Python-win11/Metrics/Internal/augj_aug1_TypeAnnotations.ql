/**
 * @name Type metrics
 * @description Analyzes and counts different kinds of type annotations in Python code.
 *              This query provides metrics on built-in types, forward declarations,
 *              simple user-defined types, complex types, and optional types across
 *              parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types that are commonly used in type annotations
class BuiltinType extends Name {
  BuiltinType() { 
    this.getId() in ["int", "float", "str", "bool", "bytes", "None"] 
  }
}

// Union type definition for elements that can have type annotations
newtype TAnnotatableElement =
  TFunctionWithReturnAnnotation(FunctionExpr func) { exists(func.getReturns()) } or 
  TParameterWithAnnotation(Parameter param) { exists(param.getAnnotation()) } or 
  TAssignmentWithAnnotation(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for all elements that can have type annotations
abstract class AnnotatableElement extends TAnnotatableElement {
  string toString() { result = "AnnotatableElement" }
  abstract Expr getAnnotation();
}

// Represents function expressions that have return type annotations
class FunctionWithReturnAnnotation extends TFunctionWithReturnAnnotation, AnnotatableElement {
  FunctionExpr functionExpr;
  FunctionWithReturnAnnotation() { this = TFunctionWithReturnAnnotation(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents parameters that have type annotations
class ParameterWithAnnotation extends TParameterWithAnnotation, AnnotatableElement {
  Parameter parameter;
  ParameterWithAnnotation() { this = TParameterWithAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments that have type annotations
class AssignmentWithAnnotation extends TAssignmentWithAnnotation, AnnotatableElement {
  AnnAssign assignmentStmt;
  AssignmentWithAnnotation() { this = TAssignmentWithAnnotation(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
}

/** Determines if an expression is a forward-declared type (represented as a string literal) */
predicate isForwardDeclaredType(Expr expr) { 
  expr instanceof StringLiteral 
}

/** Determines if an expression represents a complex type structure such as generics, tuples, or lists */
predicate isComplexTypeStructure(Expr expr) {
  expr instanceof Subscript and not isOptionalType(expr)
  or
  expr instanceof Tuple
  or
  expr instanceof List
}

/** Determines if an expression is an Optional type (Union[T, None]) */
predicate isOptionalType(Subscript expr) { 
  expr.getObject().(Name).getId() = "Optional" 
}

/** Determines if an expression is a simple user-defined type (not built-in) */
predicate isSimpleUserDefinedType(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType
  or
  isSimpleUserDefinedType(expr.(Attribute).getObject())
}

/** Determines if an expression is a built-in type */
predicate isBuiltinType(Expr expr) { 
  expr instanceof BuiltinType 
}

// Computes type annotation metrics for different categories of code elements
predicate calculateTypeMetrics(
  string elementKind, int totalCount, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    elementKind = "Parameter annotation" and
    totalCount = count(ParameterWithAnnotation annotatedParam) and
    builtinTypeCount = count(ParameterWithAnnotation annotatedParam | isBuiltinType(annotatedParam.getAnnotation())) and
    forwardDeclarationCount = count(ParameterWithAnnotation annotatedParam | isForwardDeclaredType(annotatedParam.getAnnotation())) and
    simpleTypeCount = count(ParameterWithAnnotation annotatedParam | isSimpleUserDefinedType(annotatedParam.getAnnotation())) and
    complexTypeCount = count(ParameterWithAnnotation annotatedParam | isComplexTypeStructure(annotatedParam.getAnnotation())) and
    optionalTypeCount = count(ParameterWithAnnotation annotatedParam | isOptionalType(annotatedParam.getAnnotation()))
  )
  or
  (
    elementKind = "Return type annotation" and
    totalCount = count(FunctionWithReturnAnnotation annotatedFunc) and
    builtinTypeCount = count(FunctionWithReturnAnnotation annotatedFunc | isBuiltinType(annotatedFunc.getAnnotation())) and
    forwardDeclarationCount = count(FunctionWithReturnAnnotation annotatedFunc | isForwardDeclaredType(annotatedFunc.getAnnotation())) and
    simpleTypeCount = count(FunctionWithReturnAnnotation annotatedFunc | isSimpleUserDefinedType(annotatedFunc.getAnnotation())) and
    complexTypeCount = count(FunctionWithReturnAnnotation annotatedFunc | isComplexTypeStructure(annotatedFunc.getAnnotation())) and
    optionalTypeCount = count(FunctionWithReturnAnnotation annotatedFunc | isOptionalType(annotatedFunc.getAnnotation()))
  )
  or
  (
    elementKind = "Annotated assignment" and
    totalCount = count(AssignmentWithAnnotation annotatedAssign) and
    builtinTypeCount = count(AssignmentWithAnnotation annotatedAssign | isBuiltinType(annotatedAssign.getAnnotation())) and
    forwardDeclarationCount = count(AssignmentWithAnnotation annotatedAssign | isForwardDeclaredType(annotatedAssign.getAnnotation())) and
    simpleTypeCount = count(AssignmentWithAnnotation annotatedAssign | isSimpleUserDefinedType(annotatedAssign.getAnnotation())) and
    complexTypeCount = count(AssignmentWithAnnotation annotatedAssign | isComplexTypeStructure(annotatedAssign.getAnnotation())) and
    optionalTypeCount = count(AssignmentWithAnnotation annotatedAssign | isOptionalType(annotatedAssign.getAnnotation()))
  )
}

// Query execution and result selection
from
  string elementKind, int totalCount, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateTypeMetrics(elementKind, totalCount, builtinTypeCount, forwardDeclarationCount, 
                      simpleTypeCount, complexTypeCount, optionalTypeCount)
select elementKind, totalCount, builtinTypeCount, forwardDeclarationCount, 
       simpleTypeCount, complexTypeCount, optionalTypeCount