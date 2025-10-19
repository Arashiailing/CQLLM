/**
 * @name Python Type Annotation Statistics
 * @description Measures and categorizes different types of type annotations found in Python codebases
 * @kind metrics-table
 * @id py/annotation-stats
 */

import python

// Represents fundamental Python built-in types
class BasicPythonType extends Name {
  BasicPythonType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines union type for code elements that support type annotations
newtype AnnotatableCodeElement =
  ReturnTypeAnnotationEntity(FunctionExpr functionDef) { exists(functionDef.getReturns()) } or 
  ParamTypeAnnotationEntity(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  VariableTypeAnnotationEntity(AnnAssign annotatedVar) { exists(annotatedVar.getAnnotation()) }

// Base class for code elements that can contain type annotations
abstract class AnnotatedCodeElement extends AnnotatableCodeElement {
  string toString() { result = "AnnotatedCodeElement" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class ReturnTypeAnnotation extends ReturnTypeAnnotationEntity, AnnotatedCodeElement {
  FunctionExpr functionDef;
  ReturnTypeAnnotation() { this = ReturnTypeAnnotationEntity(functionDef) }
  override Expr getAnnotation() { result = functionDef.getReturns() }
}

// Represents parameters with type annotations
class ParamTypeAnnotation extends ParamTypeAnnotationEntity, AnnotatedCodeElement {
  Parameter parameter;
  ParamTypeAnnotation() { this = ParamTypeAnnotationEntity(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents variable assignments with type annotations
class VariableTypeAnnotation extends VariableTypeAnnotationEntity, AnnotatedCodeElement {
  AnnAssign annotatedVar;
  VariableTypeAnnotation() { this = VariableTypeAnnotationEntity(annotatedVar) }
  override Expr getAnnotation() { result = annotatedVar.getAnnotation() }
}

// Helper predicates to classify type annotations
/** Checks if an annotation is a forward-declared type (string literal) */
predicate isForwardDeclaredType(Expr typeExpr) { typeExpr instanceof StringLiteral }

/** Identifies if an annotation represents a nested or complex type structure */
predicate isNestedTypeAnnotation(Expr typeExpr) {
  typeExpr instanceof Subscript and not isNullableTypeAnnotation(typeExpr)
  or
  typeExpr instanceof Tuple
  or
  typeExpr instanceof List
}

/** Determines if an annotation is a nullable/Optional type */
predicate isNullableTypeAnnotation(Subscript typeExpr) { 
  typeExpr.getObject().(Name).getId() = "Optional" 
}

/** Checks if an annotation is a simple user-defined custom type */
predicate isCustomTypeAnnotation(Expr typeExpr) {
  typeExpr instanceof Name and not typeExpr instanceof BasicPythonType
  or
  isCustomTypeAnnotation(typeExpr.(Attribute).getObject())
}

/** Determines if an annotation is a primitive/built-in type */
predicate isPrimitiveTypeAnnotation(Expr typeExpr) { 
  typeExpr instanceof BasicPythonType 
}

// Computes statistics for type annotations across different code element categories
predicate computeTypeAnnotationStats(
  string elementCategory, int totalElements, int primitiveTypes, int forwardDeclarations, 
  int customTypes, int nestedTypes, int nullableTypes
) {
  (
    elementCategory = "Parameter annotation" and
    totalElements = count(ParamTypeAnnotation paramAnnotation) and
    primitiveTypes = count(ParamTypeAnnotation paramAnnotation | isPrimitiveTypeAnnotation(paramAnnotation.getAnnotation())) and
    forwardDeclarations = count(ParamTypeAnnotation paramAnnotation | isForwardDeclaredType(paramAnnotation.getAnnotation())) and
    customTypes = count(ParamTypeAnnotation paramAnnotation | isCustomTypeAnnotation(paramAnnotation.getAnnotation())) and
    nestedTypes = count(ParamTypeAnnotation paramAnnotation | isNestedTypeAnnotation(paramAnnotation.getAnnotation())) and
    nullableTypes = count(ParamTypeAnnotation paramAnnotation | isNullableTypeAnnotation(paramAnnotation.getAnnotation()))
  )
  or
  (
    elementCategory = "Return type annotation" and
    totalElements = count(ReturnTypeAnnotation returnAnnotation) and
    primitiveTypes = count(ReturnTypeAnnotation returnAnnotation | isPrimitiveTypeAnnotation(returnAnnotation.getAnnotation())) and
    forwardDeclarations = count(ReturnTypeAnnotation returnAnnotation | isForwardDeclaredType(returnAnnotation.getAnnotation())) and
    customTypes = count(ReturnTypeAnnotation returnAnnotation | isCustomTypeAnnotation(returnAnnotation.getAnnotation())) and
    nestedTypes = count(ReturnTypeAnnotation returnAnnotation | isNestedTypeAnnotation(returnAnnotation.getAnnotation())) and
    nullableTypes = count(ReturnTypeAnnotation returnAnnotation | isNullableTypeAnnotation(returnAnnotation.getAnnotation()))
  )
  or
  (
    elementCategory = "Annotated assignment" and
    totalElements = count(VariableTypeAnnotation varAnnotation) and
    primitiveTypes = count(VariableTypeAnnotation varAnnotation | isPrimitiveTypeAnnotation(varAnnotation.getAnnotation())) and
    forwardDeclarations = count(VariableTypeAnnotation varAnnotation | isForwardDeclaredType(varAnnotation.getAnnotation())) and
    customTypes = count(VariableTypeAnnotation varAnnotation | isCustomTypeAnnotation(varAnnotation.getAnnotation())) and
    nestedTypes = count(VariableTypeAnnotation varAnnotation | isNestedTypeAnnotation(varAnnotation.getAnnotation())) and
    nullableTypes = count(VariableTypeAnnotation varAnnotation | isNullableTypeAnnotation(varAnnotation.getAnnotation()))
  )
}

// Main query that retrieves and presents the type annotation statistics
from
  string elementCategory, int totalElements, int primitiveTypes, int forwardDeclarations, 
  int customTypes, int nestedTypes, int nullableTypes
where 
  computeTypeAnnotationStats(elementCategory, totalElements, primitiveTypes, forwardDeclarations, 
                             customTypes, nestedTypes, nullableTypes)
select elementCategory, totalElements, primitiveTypes, forwardDeclarations, customTypes, nestedTypes, nullableTypes