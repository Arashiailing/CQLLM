/**
 * @name Redundant comparison
 * @description The result of a comparison is implied by a previous comparison.
 * @kind problem
 * @tags useless-code
 *       external/cwe/cwe-561
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/redundant-comparison
 */

import python
import semmle.python.Comparisons

/*
 * Holds if the comparison `comp` is of the complex form `a op b op c` and not of
 * the simple form `a op b`.
 */
private predicate is_complex(Expr comp) {
  // 检查比较表达式是否包含多个操作符，即复杂形式
  exists(comp.(Compare).getOp(1))
  or
  // 递归检查一元表达式的操作数是否为复杂形式
  is_complex(comp.(UnaryExpr).getOperand())
}

/**
 * A test is useless if for every block that it controls there is another test that is at least as
 * strict and also controls that block.
 */
private predicate useless_test(Comparison comp, ComparisonControlBlock controls, boolean isTrue) {
  // 检查控制块是否由更严格的测试控制
  controls.impliesThat(comp.getBasicBlock(), comp, isTrue) and
  /* Exclude complex comparisons of form `a < x < y`, as we do not (yet) have perfect flow control for those */
  // 排除复杂形式的比较，因为目前对这些比较没有完美的流控制
  not is_complex(controls.getTest().getNode())
}

private predicate useless_test_ast(AstNode comp, AstNode previous, boolean isTrue) {
  // 遍历所有符合条件的比较节点和条件块，检查是否存在无用的测试
  forex(Comparison compnode, ConditionBlock block |
    compnode.getNode() = comp and
    block.getLastNode().getNode() = previous
  |
    useless_test(compnode, block, isTrue)
  )
}

from Expr test, Expr other, boolean isTrue
where
  // 查找无用的测试，并确保其子节点不是无用的测试
  useless_test_ast(test, other, isTrue) and not useless_test_ast(test.getAChildNode+(), other, _)
select test, "Test is always " + isTrue + ", because of $@.", other, "this condition"
// 选择测试表达式、结果描述、其他表达式以及相关条件
