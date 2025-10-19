/**
 * @name Function returning tuples of inconsistent lengths
 * @description Detects functions that return tuples with varying lengths, which can lead to errors
 *              when consumers of these functions expect a consistent tuple structure.
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

// 定义谓词函数，判断函数是否返回特定大小的元组
predicate returns_tuple_of_size(Function targetFunction, int tupleSize, Tuple returnedTuple) {
  // 检查函数的返回语句和相关的数据流
  exists(Return returnStmt, DataFlow::Node returnValueNode |
    // 返回值的数据流节点与返回语句的值对应
    returnValueNode.asExpr() = returnStmt.getValue() and
    // 确保返回语句属于目标函数
    returnStmt.getScope() = targetFunction and
    // 检查从元组到返回值的数据流
    any(DataFlow::LocalSourceNode sourceNode | sourceNode.asExpr() = returnedTuple).flowsTo(returnValueNode)
  |
    // 计算元组中元素的数量
    tupleSize = count(int idx | exists(returnedTuple.getElt(idx)))
  )
}

// 查找返回不同大小元组的函数
from Function targetFunction, int smallerSize, int largerSize, AstNode smallerTuple, AstNode largerTuple
where
  // 函数返回较小大小的元组
  returns_tuple_of_size(targetFunction, smallerSize, smallerTuple) and
  // 函数返回较大大小的元组
  returns_tuple_of_size(targetFunction, largerSize, largerTuple) and
  // 确保两个元组大小不同
  smallerSize < largerSize and
  // 排除有返回类型注解的函数
  not exists(targetFunction.getDefinition().(FunctionExpr).getReturns())
// 选择结果，包括函数、函数名和两个不同大小的元组信息
select targetFunction, targetFunction.getQualifiedName() + " returns $@ and $@.", smallerTuple, 
  "tuple of size " + smallerSize, largerTuple, "tuple of size " + largerSize