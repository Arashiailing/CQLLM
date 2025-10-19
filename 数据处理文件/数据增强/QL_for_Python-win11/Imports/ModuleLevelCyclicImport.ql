/**
 * @name Module-level cyclic import
 * @description 模块使用了循环导入的模块成员，这可能导致在导入时失败。
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @comprehension 0.5
 * @id py/unsafe-cyclic-import
 */

// 导入Python库和Cyclic模块
import python
import Cyclic

// 这是一个潜在的崩溃错误，如果满足以下条件：
// 1. 整个循环中的导入语句在def之外（因此在导入时执行）
// 2. 有一个使用('M.foo'或'from M import foo')导入模块的成员，且该使用语句在def之外
// 3. 'foo'是在完成循环的M模块中定义的，并且在导入之后。
// 那么如果我们导入'used'模块，我们会到达循环导入，开始导入'using'模块，遇到'use'，然后由于导入的符号尚未定义而崩溃。
from ModuleValue m1, Stmt imp, ModuleValue m2, string attr, Expr use, ControlFlowNode defn
where failing_import_due_to_cycle(m1, m2, imp, defn, use, attr)
select use,
  "'" + attr + "' may not be defined if module $@ is imported before module $@, as the $@ of " +
    attr + " occurs after the cyclic $@ of " + m2.getName() + ".",
  // 上述消息中占位符的参数：
  m1, m1.getName(), m2, m2.getName(), defn, "definition", imp, "import"
