/**
 * @name Unguarded next in generator
 * @description Calling next() in a generator may cause unintended early termination of an iteration.
 * @kind problem
 * @tags maintainability
 *       portability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unguarded-next-in-generator
 */

import python
private import semmle.python.ApiGraphs

// 定义内置函数 iter() 的 API 节点
API::Node iter() { result = API::builtin("iter") }

// 定义内置函数 next() 的 API 节点
API::Node next() { result = API::builtin("next") }

// 定义内置异常 StopIteration 的 API 节点
API::Node stopIteration() { result = API::builtin("StopIteration") }

// 谓词：检查是否调用了 iter() 函数，并且传入的参数是 sequence
predicate call_to_iter(CallNode call, EssaVariable sequence) {
  call = iter().getACall().asCfgNode() and
  call.getArg(0) = sequence.getAUse()
}

// 谓词：检查是否调用了 next() 函数，并且传入的参数是迭代器 iter
predicate call_to_next(CallNode call, ControlFlowNode iter) {
  call = next().getACall().asCfgNode() and
  call.getArg(0) = iter
}

// 谓词：检查调用 next() 时是否提供了默认值
predicate call_to_next_has_default(CallNode call) {
  exists(call.getArg(1)) or exists(call.getArgByName("default"))
}

// 谓词：检查序列是否被保护且不为空
predicate guarded_not_empty_sequence(EssaVariable sequence) {
  sequence.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if `iterator` is not exhausted.
 *
 * The pattern `next(iter(x))` is often used where `x` is known not be empty. Check for that.
 */
// 谓词：检查迭代器是否未耗尽
predicate iter_not_exhausted(EssaVariable iterator) {
  exists(EssaVariable sequence |
    call_to_iter(iterator.getDefinition().(AssignmentDefinition).getValue(), sequence) and
    guarded_not_empty_sequence(sequence)
  )
}

// 谓词：检查 StopIteration 异常是否被处理
predicate stop_iteration_handled(CallNode call) {
  exists(Try t |
    t.containsInScope(call.getNode()) and
    t.getAHandler().getType() = stopIteration().getAValueReachableFromSource().asExpr()
  )
}

// 查询：查找在生成器中调用 next() 的情况，但没有提供默认值，也没有处理 StopIteration 异常，并且 Python 版本为 2
from CallNode call
where
  // 检查是否调用了 next() 函数
  call_to_next(call, _) and
  // 检查调用 next() 时没有提供默认值
  not call_to_next_has_default(call) and
  // 检查迭代器是否已经耗尽
  not exists(EssaVariable iterator |
    call_to_next(call, iterator.getAUse()) and
    iter_not_exhausted(iterator)
  ) and
  // 检查当前作用域是否为生成器函数
  call.getNode().getScope().(Function).isGenerator() and
  // 检查调用是否在 comprehension 中
  not exists(Comp comp | comp.contains(call.getNode())) and
  // 检查 StopIteration 异常是否被处理
  not stop_iteration_handled(call) and
  // PEP 479 removes this concern from 3.7 onwards
  // see: https://peps.python.org/pep-0479/
  //
  // However, we do not know the minor version of the analyzed code (only of the extractor),
  // so we only alert on Python 2.
  // 仅在 Python 2 中发出警告
  major_version() = 2
select call, "Call to 'next()' in a generator."
