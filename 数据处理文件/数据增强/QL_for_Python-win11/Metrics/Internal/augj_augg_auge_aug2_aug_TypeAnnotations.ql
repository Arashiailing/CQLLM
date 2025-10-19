/**
 * @name Type Annotation Metrics
 * @description Calculates statistics for various type annotation patterns in Python code,
 *              covering parameter annotations, return type annotations, and variable type annotations.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types
class PythonBuiltinType extends Name {
  PythonBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr func) { exists(func.getReturns()) } or
  TParameterWithTypeAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TVariableWithTypeAnnotation(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for type-annotated elements
abstract class TypeAnnotatedElement extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatedElement {
  FunctionExpr funcExpr;

  FunctionWithReturnType() { this = TFunctionWithReturnType(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithTypeAnnotation extends TParameterWithTypeAnnotation, TypeAnnotatedElement {
  Parameter param;

  ParameterWithTypeAnnotation() { this = TParameterWithTypeAnnotation(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class VariableWithTypeAnnotation extends TVariableWithTypeAnnotation, TypeAnnotatedElement {
  AnnAssign annotatedAssign;

  VariableWithTypeAnnotation() { this = TVariableWithTypeAnnotation(annotatedAssign) }
  override Expr getAnnotation() { result = annotatedAssign.getAnnotation() }
}

// Type annotation classification predicates
predicate isStringForwardDeclaration(Expr annotationExpr) { 
  annotationExpr instanceof StringLiteral 
}

predicate isComplexTypeConstruct(Expr annotationExpr) {
  (annotationExpr instanceof Subscript and not isOptionalTypeAnnotation(annotationExpr)) or
  annotationExpr instanceof Tuple or
  annotationExpr instanceof List
}

predicate isOptionalTypeAnnotation(Subscript annotationExpr) { 
  annotationExpr.getObject().(Name).getId() = "Optional" 
}

predicate isSimpleNonBuiltinType(Expr annotationExpr) {
  (annotationExpr instanceof Name and not annotationExpr instanceof PythonBuiltinType) or
  (annotationExpr instanceof Attribute and isSimpleNonBuiltinType(annotationExpr.(Attribute).getObject()))
}

predicate isBuiltinPythonType(Expr annotationExpr) { 
  annotationExpr instanceof PythonBuiltinType 
}

// Helper predicate to determine the category of an annotated element
predicate getAnnotationCategory(TypeAnnotatedElement element, string category) {
  (element instanceof ParameterWithTypeAnnotation and category = "Parameter annotation")
  or
  (element instanceof FunctionWithReturnType and category = "Return type annotation")
  or
  (element instanceof VariableWithTypeAnnotation and category = "Annotated assignment")
}

// Calculates type annotation metrics for each annotation category
predicate calculateTypeAnnotationMetrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(ParameterWithTypeAnnotation annotatedParam) and
  builtinCount = count(ParameterWithTypeAnnotation annotatedParam | isBuiltinPythonType(annotatedParam.getAnnotation())) and
  forwardDeclCount = count(ParameterWithTypeAnnotation annotatedParam | isStringForwardDeclaration(annotatedParam.getAnnotation())) and
  simpleTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isSimpleNonBuiltinType(annotatedParam.getAnnotation())) and
  complexTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isComplexTypeConstruct(annotatedParam.getAnnotation())) and
  optionalTypeCount = count(ParameterWithTypeAnnotation annotatedParam | isOptionalTypeAnnotation(annotatedParam.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(FunctionWithReturnType annotatedFunc) and
  builtinCount = count(FunctionWithReturnType annotatedFunc | isBuiltinPythonType(annotatedFunc.getAnnotation())) and
  forwardDeclCount = count(FunctionWithReturnType annotatedFunc | isStringForwardDeclaration(annotatedFunc.getAnnotation())) and
  simpleTypeCount = count(FunctionWithReturnType annotatedFunc | isSimpleNonBuiltinType(annotatedFunc.getAnnotation())) and
  complexTypeCount = count(FunctionWithReturnType annotatedFunc | isComplexTypeConstruct(annotatedFunc.getAnnotation())) and
  optionalTypeCount = count(FunctionWithReturnType annotatedFunc | isOptionalTypeAnnotation(annotatedFunc.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(VariableWithTypeAnnotation annotatedAssign) and
  builtinCount = count(VariableWithTypeAnnotation annotatedAssign | isBuiltinPythonType(annotatedAssign.getAnnotation())) and
  forwardDeclCount = count(VariableWithTypeAnnotation annotatedAssign | isStringForwardDeclaration(annotatedAssign.getAnnotation())) and
  simpleTypeCount = count(VariableWithTypeAnnotation annotatedAssign | isSimpleNonBuiltinType(annotatedAssign.getAnnotation())) and
  complexTypeCount = count(VariableWithTypeAnnotation annotatedAssign | isComplexTypeConstruct(annotatedAssign.getAnnotation())) and
  optionalTypeCount = count(VariableWithTypeAnnotation annotatedAssign | isOptionalTypeAnnotation(annotatedAssign.getAnnotation()))
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