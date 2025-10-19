/**
 * @name Type metrics
 * @description Analyzes and counts various type annotation patterns in Python code,
 *              focusing on parameters, return types, and variable annotations.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a native type in Python (e.g., int, str, bool)
class NativeType extends Name {
  NativeType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr func) { exists(func.getReturns()) } or
  TParameterWithType(Parameter param) { exists(param.getAnnotation()) } or
  TAssignmentWithType(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotatedElement extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatedElement {
  FunctionExpr func;

  FunctionWithReturnType() { this = TFunctionWithReturnType(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Parameters with type annotations
class ParameterWithType extends TParameterWithType, TypeAnnotatedElement {
  Parameter param;

  ParameterWithType() { this = TParameterWithType(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithType extends TAssignmentWithType, TypeAnnotatedElement {
  AnnAssign assign;

  AssignmentWithType() { this = TAssignmentWithType(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

// Type classification predicates

/** Holds if `expr` is a forward declaration (string literal) of a type. */
predicate isStringLiteralType(Expr expr) { expr instanceof StringLiteral }

/** Holds if `expr` is a type that may be difficult to analyze. */
predicate isComplexTypeAnnotation(Expr expr) {
  (expr instanceof Subscript and not isOptionalTypeAnnotation(expr)) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Holds if `expr` is a type of the form `Optional[...]`. */
predicate isOptionalTypeAnnotation(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Holds if `expr` is a simple type (non-built-in identifier or attribute chain). */
predicate isSimpleTypeAnnotation(Expr expr) {
  (expr instanceof Name and not expr instanceof NativeType) or
  isSimpleTypeAnnotation(expr.(Attribute).getObject())
}

/** Holds if `expr` is a built-in type. */
predicate isNativeTypeAnnotation(Expr expr) { expr instanceof NativeType }

// Computes type annotation metrics for different annotation categories
predicate calculateTypeMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    // Parameter annotation metrics
    category = "Parameter annotation" and
    totalCount = count(ParameterWithType param) and
    builtinCount = count(ParameterWithType param | isNativeTypeAnnotation(param.getAnnotation())) and
    forwardDeclCount = count(ParameterWithType param | isStringLiteralType(param.getAnnotation())) and
    simpleTypeCount = count(ParameterWithType param | isSimpleTypeAnnotation(param.getAnnotation())) and
    complexTypeCount = count(ParameterWithType param | isComplexTypeAnnotation(param.getAnnotation())) and
    optionalTypeCount = count(ParameterWithType param | isOptionalTypeAnnotation(param.getAnnotation()))
  )
  or
  (
    // Return type annotation metrics
    category = "Return type annotation" and
    totalCount = count(FunctionWithReturnType func) and
    builtinCount = count(FunctionWithReturnType func | isNativeTypeAnnotation(func.getAnnotation())) and
    forwardDeclCount = count(FunctionWithReturnType func | isStringLiteralType(func.getAnnotation())) and
    simpleTypeCount = count(FunctionWithReturnType func | isSimpleTypeAnnotation(func.getAnnotation())) and
    complexTypeCount = count(FunctionWithReturnType func | isComplexTypeAnnotation(func.getAnnotation())) and
    optionalTypeCount = count(FunctionWithReturnType func | isOptionalTypeAnnotation(func.getAnnotation()))
  )
  or
  (
    // Annotated assignment metrics
    category = "Annotated assignment" and
    totalCount = count(AssignmentWithType assign) and
    builtinCount = count(AssignmentWithType assign | isNativeTypeAnnotation(assign.getAnnotation())) and
    forwardDeclCount = count(AssignmentWithType assign | isStringLiteralType(assign.getAnnotation())) and
    simpleTypeCount = count(AssignmentWithType assign | isSimpleTypeAnnotation(assign.getAnnotation())) and
    complexTypeCount = count(AssignmentWithType assign | isComplexTypeAnnotation(assign.getAnnotation())) and
    optionalTypeCount = count(AssignmentWithType assign | isOptionalTypeAnnotation(assign.getAnnotation()))
  )
}

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateTypeMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount