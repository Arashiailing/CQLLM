/**
 * @name Except block handles 'BaseException'
 * @description Handling 'BaseException' means that system exits and keyboard interrupts may be mis-handled.
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

// 定义一个谓词函数，用于判断异常处理块是否重新抛出异常。
predicate doesnt_reraise(ExceptStmt ex) { 
  // 获取异常处理块的基本块，并检查其是否到达退出点。
  ex.getAFlowNode().getBasicBlock().reachesExit() 
}

// 定义另一个谓词函数，用于判断异常处理块是否捕获了BaseException。
predicate catches_base_exception(ExceptStmt ex) {
  // 检查异常类型是否为BaseException或未指定异常类型。
  ex.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(ex.getType())
}

// 查询语句，从所有异常处理块中选择那些捕获了BaseException且不重新抛出的块。
from ExceptStmt ex
where
  catches_base_exception(ex) and // 条件1：捕获了BaseException
  doesnt_reraise(ex)            // 条件2：不重新抛出异常
select ex, "Except block directly handles BaseException." // 选择结果并附加描述信息
