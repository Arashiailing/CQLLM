/**
 * @name Global shadowed by local variable
 * @description Defining a local variable with the same name as a global variable
 *              makes the global variable unusable within the current scope and makes the code
 *              more difficult to read.
 * @kind problem
 * @tags maintainability
 *       readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/local-shadows-global
 */

import python
import Shadowing
import semmle.python.types.Builtins

// 定义一个谓词 shadows，用于判断局部变量是否遮蔽了全局变量
predicate shadows(Name d, GlobalVariable g, Function scope, int line) {
  // 检查全局变量的作用域是否与函数作用域相同
  g.getScope() = scope.getScope() and
  // 检查局部变量的定义是否在当前函数作用域内
  d.getScope() = scope and
  // 检查是否存在一个局部变量 l，其名称与全局变量 g 相同
  exists(LocalVariable l |
    d.defines(l) and
    l.getId() = g.getId()
  ) and
  // 确保全局变量不是通过导入语句引入的
  not exists(Import il, Import ig, Name gd | il.contains(d) and gd.defines(g) and ig.contains(gd)) and
  // 确保全局变量没有通过赋值操作被使用
  not exists(Assign a | a.getATarget() = d and a.getValue() = g.getAnAccess()) and
  // 确保全局变量不是内置函数或常量
  not exists(Builtin::builtin(g.getId())) and
  // 获取局部变量定义的行号
  d.getLocation().getStartLine() = line and
  // 确保全局变量的定义不在 if __name__ == "__main__" 块中
  exists(Name defn | defn.defines(g) | not exists(If i | i.isNameEqMain() | i.contains(defn))) and
  // 确保局部变量不是一个优化参数
  not optimizing_parameter(d)
}

/* pytest dynamically populates its namespace so, we cannot look directly for the pytest.fixture function */
// 定义一个属性节点，用于表示 pytest 的 fixture 属性
AttrNode pytest_fixture_attr() {
  // 检查对象 "fixture" 是否指向 pytest 模块
  exists(ModuleValue pytest | result.getObject("fixture").pointsTo(pytest))
}

// 定义一个值节点，用于表示 pytest 的 fixture 函数调用
Value pytest_fixture() {
  // 检查函数调用是否指向 pytest_fixture_attr 属性
  exists(CallNode call |
    call.getFunction() = pytest_fixture_attr()
    or
    call.getFunction().(CallNode).getFunction() = pytest_fixture_attr()
  |
    // 确保调用指向结果节点
    call.pointsTo(result)
  )
}

/* pytest fixtures require that the parameter name is also a global */
// 定义一个谓词 assigned_pytest_fixture，用于判断全局变量是否被分配为 pytest fixture
predicate assigned_pytest_fixture(GlobalVariable v) {
  // 检查全局变量的定义是否指向 pytest_fixture
  exists(NameNode def |
    def.defines(v) and def.(DefinitionNode).getValue().pointsTo(pytest_fixture())
  )
}

// 定义一个谓词 first_shadowing_definition，用于判断局部变量是否是第一个遮蔽全局变量的定义
predicate first_shadowing_definition(Name d, GlobalVariable g) {
  // 检查局部变量是否在最小行号处遮蔽了全局变量
  exists(int first, Scope scope |
    shadows(d, g, scope, first) and
    first = min(int line | shadows(_, g, scope, line))
  )
}

// 从 Name、GlobalVariable 和 Name 中选择数据
from Name d, GlobalVariable g, Name def
where
  // 检查局部变量是否是第一个遮蔽全局变量的定义
  first_shadowing_definition(d, g) and
  // 确保全局变量没有被删除
  not exists(Name n | n.deletes(g)) and
  // 确保全局变量被定义
  def.defines(g) and
  // 确保全局变量没有被分配为 pytest fixture
  not assigned_pytest_fixture(g) and
  // 确保全局变量的名称不是 "_"
  not g.getId() = "_"
// 选择局部变量、遮蔽信息、全局变量定义以及全局变量信息
select d, "Local variable '" + g.getId() + "' shadows a $@.", def, "global variable"
