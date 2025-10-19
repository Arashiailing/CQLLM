/**
 * @name Returning tuples with varying lengths
 * @description A function that potentially returns tuples of different lengths may indicate a problem.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       quality
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-tuple-returns
 */

import python
import semmle.python.ApiGraphs

// 定义一个谓词函数，用于判断某个函数是否返回指定大小的元组
predicate returns_tuple_of_size(Function func, int size, Tuple tuple) {
  // 存在一个返回语句和一个数据流节点，满足以下条件：
  exists(Return return, DataFlow::Node value |
    // 数据流节点的表达式等于返回语句的值
    value.asExpr() = return.getValue() and
    // 返回语句的作用域是该函数
    return.getScope() = func and
    // 任意一个数据流的本地源节点，其表达式等于给定的元组，并且数据流到上述的数据流节点
    any(DataFlow::LocalSourceNode n | n.asExpr() = tuple).flowsTo(value)
  |
    // 计算元组的大小，即元组中元素的数量
    size = count(int n | exists(tuple.getElt(n)))
  )
}

// 从函数、两个整数和两个AST节点中选择数据
from Function func, int s1, int s2, AstNode t1, AstNode t2
where
  // 函数返回大小为s1的元组t1
  returns_tuple_of_size(func, s1, t1) and
  // 函数返回大小为s2的元组t2
  returns_tuple_of_size(func, s2, t2) and
  // s1小于s2，表示返回的元组大小不同
  s1 < s2 and
  // 不报告有返回类型注解的函数
  not exists(func.getDefinition().(FunctionExpr).getReturns())
// 选择函数、函数名、以及两个不同大小的元组信息
select func, func.getQualifiedName() + " returns $@ and $@.", t1, "tuple of size " + s1, t2,
  "tuple of size " + s2
