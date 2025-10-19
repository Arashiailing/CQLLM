/**
 * @name Type metrics
 * @description Counts of various kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// 定义一个类，用于表示Python中的内建类型。
class BuiltinType extends Name {
  // 构造函数，判断当前实例是否为内建类型之一。
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// 定义一个新的类型TAnnotatable，它可以是以下三种情况之一：
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr f) { exists(f.getReturns()) } or // 有返回类型的函数表达式
  TAnnotatedParameter(Parameter p) { exists(p.getAnnotation()) } or // 有注解的参数
  TAnnotatedAssignment(AnnAssign a) { exists(a.getAnnotation()) } // 有注解的赋值语句

// 抽象类Annotatable，继承自TAnnotatable，用于表示可注解的元素。
abstract class Annotatable extends TAnnotatable {
  // 将对象转换为字符串表示形式。
  string toString() { result = "Annotatable" }

  // 抽象方法，获取注解表达式。
  abstract Expr getAnnotation();
}

// 类AnnotatedFunction，继承自TAnnotatable和Annotatable，用于表示有返回类型注解的函数。
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr function; // 函数表达式

  // 构造函数，初始化function属性。
  AnnotatedFunction() { this = TAnnotatedFunction(function) }

  // 重写getAnnotation方法，返回函数的返回类型注解。
  override Expr getAnnotation() { result = function.getReturns() }
}

// 类AnnotatedParameter，继承自TAnnotatable和Annotatable，用于表示有注解的参数。
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter; // 参数

  // 构造函数，初始化parameter属性。
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }

  // 重写getAnnotation方法，返回参数的注解。
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// 类AnnotatedAssignment，继承自TAnnotatable和Annotatable，用于表示有注解的赋值语句。
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignment; // 赋值语句

  // 构造函数，初始化assignment属性。
  AnnotatedAssignment() { this = TAnnotatedAssignment(assignment) }

  // 重写getAnnotation方法，返回赋值语句的注解。
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** Holds if `e` is a forward declaration of a type. */
predicate is_forward_declaration(Expr e) { e instanceof StringLiteral }

/** Holds if `e` is a type that may be difficult to analyze. */
predicate is_complex_type(Expr e) {
  e instanceof Subscript and not is_optional_type(e) // 如果e是下标访问且不是可选类型
  or
  e instanceof Tuple // 如果e是元组类型
  or
  e instanceof List // 如果e是列表类型
}

/** Holds if `e` is a type of the form `Optional[...]`. */
predicate is_optional_type(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** Holds if `e` is a simple type, that is either an identifier (excluding built-in types) or an attribute of a simple type. */
predicate is_simple_type(Expr e) {
  e instanceof Name and not e instanceof BuiltinType // 如果e是名称且不是内建类型
  or
  is_simple_type(e.(Attribute).getObject()) // 如果e是属性且其对象是简单类型
}

/** Holds if `e` is a built-in type. */
predicate is_builtin_type(Expr e) { e instanceof BuiltinType }

// 定义一个谓词，用于计算不同类型的注解数量。
predicate type_count(
  string kind, int total, int built_in_count, int forward_declaration_count, int simple_type_count,
  int complex_type_count, int optional_type_count
) {
  kind = "Parameter annotation" and // 如果kind是“参数注解”
  total = count(AnnotatedParameter p) and // 计算总的参数注解数量
  built_in_count = count(AnnotatedParameter p | is_builtin_type(p.getAnnotation())) and // 计算内建类型的参数注解数量
  forward_declaration_count = count(AnnotatedParameter p | is_forward_declaration(p.getAnnotation())) and // 计算前向声明的参数注解数量
  simple_type_count = count(AnnotatedParameter p | is_simple_type(p.getAnnotation())) and // 计算简单类型的参数注解数量
  complex_type_count = count(AnnotatedParameter p | is_complex_type(p.getAnnotation())) and // 计算复杂类型的参数注解数量
  optional_type_count = count(AnnotatedParameter p | is_optional_type(p.getAnnotation())) // 计算可选类型的参数注解数量
  or
  kind = "Return type annotation" and // 如果kind是“返回类型注解”
  total = count(AnnotatedFunction f) and // 计算总的返回类型注解数量
  built_in_count = count(AnnotatedFunction f | is_builtin_type(f.getAnnotation())) and // 计算内建类型的返回类型注解数量
  forward_declaration_count = count(AnnotatedFunction f | is_forward_declaration(f.getAnnotation())) and // 计算前向声明的返回类型注解数量
  simple_type_count = count(AnnotatedFunction f | is_simple_type(f.getAnnotation())) and // 计算简单类型的返回类型注解数量
  complex_type_count = count(AnnotatedFunction f | is_complex_type(f.getAnnotation())) and // 计算复杂类型的返回类型注解数量
  optional_type_count = count(AnnotatedFunction f | is_optional_type(f.getAnnotation())) // 计算可选类型的返回类型注解数量
  or
  kind = "Annotated assignment" and // 如果kind是“注解赋值”
  total = count(AnnotatedAssignment a) and // 计算总的注解赋值数量
  built_in_count = count(AnnotatedAssignment a | is_builtin_type(a.getAnnotation())) and // 计算内建类型的注解赋值数量
  forward_declaration_count = count(AnnotatedAssignment a | is_forward_declaration(a.getAnnotation())) and // 计算前向声明的注解赋值数量
  simple_type_count = count(AnnotatedAssignment a | is_simple_type(a.getAnnotation())) and // 计算简单类型的注解赋值数量
  complex_type_count = count(AnnotatedAssignment a | is_complex_type(a.getAnnotation())) and // 计算复杂类型的注解赋值数量
  optional_type_count = count(AnnotatedAssignment a | is_optional_type(a.getAnnotation())) // 计算可选类型的注解赋值数量
}

// 查询语句，从数据库中选择满足type_count谓词的数据。
from
  string message, int total, int built_in, int forward_decl, int simple, int complex, int optional
where type_count(message, total, built_in, forward_decl, simple, complex, optional)
select message, total, built_in, forward_decl, simple, complex, optional
