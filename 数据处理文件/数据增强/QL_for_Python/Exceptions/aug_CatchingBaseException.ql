/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits and keyboard interrupts.
 * @kind problem
 * @tags reliability
 *       readability
 *       convention
 *       external/cwe/cwe-396
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/catch-base-exception
 */

import python
import semmle.python.ApiGraphs

// 判断异常处理块是否不重新抛出异常
predicate doesNotReraise(ExceptStmt exceptBlock) { 
  // 获取异常处理块的流节点，检查其基本块是否到达程序退出点
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// 判断异常处理块是否捕获了BaseException
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // 检查异常类型是否为BaseException或未指定类型
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptBlock.getType())
}

// 主查询：找出捕获BaseException且不重新抛出的异常处理块
from ExceptStmt exceptBlock
where
  catchesBaseException(exceptBlock) and // 条件：捕获BaseException
  doesNotReraise(exceptBlock)           // 条件：不重新抛出异常
select exceptBlock, "Except block directly handles BaseException." // 选择结果并添加描述信息