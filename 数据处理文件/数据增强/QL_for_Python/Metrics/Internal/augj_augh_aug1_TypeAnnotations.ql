/**
 * @name Type metrics
 * @description Provides comprehensive metrics on type annotation usage patterns in Python codebase,
 *              categorizing annotations by their structure (simple, complex, optional, forward-declared)
 *              and context (parameters, return types, assignments).
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types like int, float, str, etc.
class PythonBuiltinType extends Name {
  PythonBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type definition for elements that can have type annotations
newtype TypeAnnotatableElement =
  TFunctionWithAnnotation(FunctionExpr function) { exists(function.getReturns()) } or 
  TParameterWithAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAssignmentWithAnnotation(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for all elements that can have type annotations
abstract class TypeAnnotatedElement extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class FunctionWithTypeAnnotation extends TFunctionWithAnnotation, TypeAnnotatedElement {
  FunctionExpr functionExpr;
  FunctionWithTypeAnnotation() { this = TFunctionWithAnnotation(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents parameters with type annotations
class ParameterWithTypeAnnotation extends TParameterWithAnnotation, TypeAnnotatedElement {
  Parameter parameter;
  ParameterWithTypeAnnotation() { this = TParameterWithAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments with type annotations
class AssignmentWithTypeAnnotation extends TAssignmentWithAnnotation, TypeAnnotatedElement {
  AnnAssign assignmentStmt;
  AssignmentWithTypeAnnotation() { this = TAssignmentWithAnnotation(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
}

// Helper predicates to classify type annotations

/** Determines if an expression is a forward-declared type (string literal) */
predicate isForwardDeclaredType(Expr expr) { expr instanceof StringLiteral }

/** Determines if an expression represents a complex type structure */
predicate isComplexTypeStructure(Expr expr) {
  expr instanceof Subscript and not isOptionalTypeAnnotation(expr)
  or
  expr instanceof Tuple
  or
  expr instanceof List
}

/** Determines if an expression is an Optional type */
predicate isOptionalTypeAnnotation(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Determines if an expression is a simple user-defined type */
predicate isSimpleUserDefinedType(Expr expr) {
  expr instanceof Name and not expr instanceof PythonBuiltinType
  or
  isSimpleUserDefinedType(expr.(Attribute).getObject())
}

/** Determines if an expression is a built-in type */
predicate isPythonBuiltinType(Expr expr) { expr instanceof PythonBuiltinType }

// Computes type annotation metrics for different categories
predicate calculateTypeAnnotationMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Metrics for parameter annotations
  category = "Parameter annotation" and
  totalCount = count(ParameterWithTypeAnnotation annotatedParam) and
  builtinCount = count(ParameterWithTypeAnnotation annotatedParam | isPythonBuiltinType(annotatedParam.getAnnotation())) and
  forwardDeclCount = count(ParameterWithTypeAnnotation annotatedParam | isForwardDeclaredType(annotatedParam.getAnnotation())) and
  simpleTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isSimpleUserDefinedType(annotatedParam.getAnnotation())) and
  complexTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isComplexTypeStructure(annotatedParam.getAnnotation())) and
  optionalTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isOptionalTypeAnnotation(annotatedParam.getAnnotation()))
  or
  // Metrics for return type annotations
  category = "Return type annotation" and
  totalCount = count(FunctionWithTypeAnnotation annotatedFunc) and
  builtinCount = count(FunctionWithTypeAnnotation annotatedFunc | isPythonBuiltinType(annotatedFunc.getAnnotation())) and
  forwardDeclCount = count(FunctionWithTypeAnnotation annotatedFunc | isForwardDeclaredType(annotatedFunc.getAnnotation())) and
  simpleTypeCount = count(FunctionWithTypeAnnotation annotatedFunc | isSimpleUserDefinedType(annotatedFunc.getAnnotation())) and
  complexTypeCount = count(FunctionWithTypeAnnotation annotatedFunc | isComplexTypeStructure(annotatedFunc.getAnnotation())) and
  optionalTypeCount = count(FunctionWithTypeAnnotation annotatedFunc | isOptionalTypeAnnotation(annotatedFunc.getAnnotation()))
  or
  // Metrics for annotated assignments
  category = "Annotated assignment" and
  totalCount = count(AssignmentWithTypeAnnotation annotatedAssign) and
  builtinCount = count(AssignmentWithTypeAnnotation annotatedAssign | isPythonBuiltinType(annotatedAssign.getAnnotation())) and
  forwardDeclCount = count(AssignmentWithTypeAnnotation annotatedAssign | isForwardDeclaredType(annotatedAssign.getAnnotation())) and
  simpleTypeCount = count(AssignmentWithTypeAnnotation annotatedAssign | isSimpleUserDefinedType(annotatedAssign.getAnnotation())) and
  complexTypeCount = count(AssignmentWithTypeAnnotation annotatedAssign | isComplexTypeStructure(annotatedAssign.getAnnotation())) and
  optionalTypeCount = count(AssignmentWithTypeAnnotation annotatedAssign | isOptionalTypeAnnotation(annotatedAssign.getAnnotation()))
}

// Query execution and result selection
from
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateTypeAnnotationMetrics(category, totalCount, builtinCount, forwardDeclCount, 
                    simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount