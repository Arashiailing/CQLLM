/**
 * @name Type metrics
 * @description Computes metrics for different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types commonly used in type annotations
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that support type annotations
newtype TTypeAnnotatedElement =
  TFunctionWithReturnAnnotation(FunctionExpr func) { exists(func.getReturns()) } or
  TParameterWithAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TAssignmentWithAnnotation(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotatedElement extends TTypeAnnotatedElement {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnAnnotation extends TFunctionWithReturnAnnotation, TypeAnnotatedElement {
  FunctionExpr func;

  FunctionWithReturnAnnotation() { this = TFunctionWithReturnAnnotation(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Parameters with type annotations
class ParameterWithAnnotation extends TParameterWithAnnotation, TypeAnnotatedElement {
  Parameter param;

  ParameterWithAnnotation() { this = TParameterWithAnnotation(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithAnnotation extends TAssignmentWithAnnotation, TypeAnnotatedElement {
  AnnAssign assign;

  AssignmentWithAnnotation() { this = TAssignmentWithAnnotation(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

// Helper predicates for type annotation classification

/** 
 * Holds if `e` is a forward declaration using string literal.
 * This pattern is commonly used when referencing types that are not yet defined.
 */
predicate isForwardDeclaration(Expr e) { e instanceof StringLiteral }

/** 
 * Holds if `e` represents a complex type construct.
 * Complex types include subscripted types (like List[int]), tuples, and lists.
 */
predicate isComplexType(Expr e) {
  e instanceof Subscript and not isOptionalType(e) or
  e instanceof Tuple or
  e instanceof List
}

/** 
 * Holds if `e` is an Optional type annotation.
 * Optional[T] is equivalent to Union[T, None] in type hints.
 */
predicate isOptionalType(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** 
 * Holds if `e` is a simple non-built-in type identifier.
 * Simple types are user-defined or imported types that are not built-in.
 */
predicate isSimpleType(Expr e) {
  e instanceof Name and not e instanceof BuiltinType or
  isSimpleType(e.(Attribute).getObject())
}

/** 
 * Holds if `e` is a built-in type.
 * Built-in types are the fundamental types provided by Python.
 */
predicate isBuiltinType(Expr e) { e instanceof BuiltinType }

// Main predicate for calculating type annotation metrics
predicate calculateTypeAnnotationMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(ParameterWithAnnotation p) and
  builtinCount = count(ParameterWithAnnotation p | isBuiltinType(p.getAnnotation())) and
  forwardDeclCount = count(ParameterWithAnnotation p | isForwardDeclaration(p.getAnnotation())) and
  simpleTypeCount = count(ParameterWithAnnotation p | isSimpleType(p.getAnnotation())) and
  complexTypeCount = count(ParameterWithAnnotation p | isComplexType(p.getAnnotation())) and
  optionalTypeCount = count(ParameterWithAnnotation p | isOptionalType(p.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(FunctionWithReturnAnnotation f) and
  builtinCount = count(FunctionWithReturnAnnotation f | isBuiltinType(f.getAnnotation())) and
  forwardDeclCount = count(FunctionWithReturnAnnotation f | isForwardDeclaration(f.getAnnotation())) and
  simpleTypeCount = count(FunctionWithReturnAnnotation f | isSimpleType(f.getAnnotation())) and
  complexTypeCount = count(FunctionWithReturnAnnotation f | isComplexType(f.getAnnotation())) and
  optionalTypeCount = count(FunctionWithReturnAnnotation f | isOptionalType(f.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AssignmentWithAnnotation a) and
  builtinCount = count(AssignmentWithAnnotation a | isBuiltinType(a.getAnnotation())) and
  forwardDeclCount = count(AssignmentWithAnnotation a | isForwardDeclaration(a.getAnnotation())) and
  simpleTypeCount = count(AssignmentWithAnnotation a | isSimpleType(a.getAnnotation())) and
  complexTypeCount = count(AssignmentWithAnnotation a | isComplexType(a.getAnnotation())) and
  optionalTypeCount = count(AssignmentWithAnnotation a | isOptionalType(a.getAnnotation()))
}

// Main query execution
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateTypeAnnotationMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount