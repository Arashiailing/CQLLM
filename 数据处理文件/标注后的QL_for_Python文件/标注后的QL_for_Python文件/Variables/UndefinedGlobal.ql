/**
 * @name Use of an undefined global variable
 * @description Using a global variable before it is initialized causes an exception.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision low
 * @id py/undefined-global-variable
 */

import python  // 导入Python库，用于分析Python代码
import Variables.MonkeyPatched  // 导入处理猴子补丁的变量库
import Loop  // 导入循环处理库
import semmle.python.pointsto.PointsTo  // 导入指向分析库

// 定义一个谓词，判断是否对NameError进行了防护
predicate guarded_against_name_error(Name u) {
  // 检查是否存在一个Try块，其内部包含u，并且异常处理器捕获了NameError
  exists(Try t | t.getBody().getAnItem().contains(u) |
    t.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // 或者检查是否存在一个条件块，其控制了一个基本块，该基本块包含全局变量的使用
  exists(ConditionBlock guard, BasicBlock controlled, Call globals |
    guard.getLastNode().getNode().contains(globals) or
    guard.getLastNode().getNode() = globals
  |
    globals.getFunc().(Name).getId() = "globals" and
    guard.controls(controlled, _) and
    controlled.contains(u.getAFlowNode())
  )
}

// 定义一个谓词，判断模块中是否包含未知的星号导入
predicate contains_unknown_import_star(Module m) {
  // 检查是否存在一个星号导入，其作用域为m，并且导入的模块没有完整的导出信息
  exists(ImportStar imp | imp.getScope() = m |
    exists(ModuleValue imported | imported.importedAs(imp.getImportedModuleName()) |
      not imported.hasCompleteExportInfo()
    )
  )
}

// 定义一个谓词，判断在函数中是否使用了未定义的全局变量
predicate undefined_use_in_function(Name u) {
  // 检查是否存在一个函数f，其作用域包含u，并且u在该函数或其封闭作用域中没有被定义
  exists(Function f |
    u.getScope().getScope*() = f and
    // 函数是一个方法或内部函数，或者它在模块作用域结束时是活跃的
    (
      not f.getScope() = u.getEnclosingModule() or
      u.getEnclosingModule().(ImportTimeScope).definesName(f.getName())
    ) and
    // 存在对全局变量v的使用，但在函数或封闭作用域中没有定义
    exists(GlobalVariable v | u.uses(v) |
      not exists(Assign a, Scope defnScope |
        a.getATarget() = v.getAnAccess() and a.getScope() = defnScope
      |
        defnScope = f
        or
        // 排除模块，因为下面会更准确处理这种情况
        defnScope = f.getScope().getScope*() and not defnScope instanceof Module
      )
    )
  ) and
  // 确保u在其封闭模块中没有被定义，并且没有通过模块值属性进行定义
  not u.getEnclosingModule().(ImportTimeScope).definesName(u.getId()) and
  not exists(ModuleValue m | m.getScope() = u.getEnclosingModule() | m.hasAttribute(u.getId())) and
  not globallyDefinedName(u.getId()) and
  not exists(SsaVariable var | var.getAUse().getNode() = u and not var.maybeUndefined()) and
  not guarded_against_name_error(u) and
  not (u.getEnclosingModule().isPackageInit() and u.getId() = "__path__")
}

// 定义一个谓词，判断在类或模块中是否使用了未定义的全局变量
predicate undefined_use_in_class_or_module(Name u) {
  // 检查是否存在一个全局变量v，其使用包含u，并且u的作用域不是函数
  exists(GlobalVariable v | u.uses(v)) and
  not u.getScope().getScope*() instanceof Function and
  exists(SsaVariable var | var.getAUse().getNode() = u | var.maybeUndefined()) and
  not guarded_against_name_error(u) and
  not exists(ModuleValue m | m.getScope() = u.getEnclosingModule() | m.hasAttribute(u.getId())) and
  not (u.getEnclosingModule().isPackageInit() and u.getId() = "__path__") and
  not globallyDefinedName(u.getId())
}

// 定义一个谓词，判断模块中是否使用了exec函数
predicate use_of_exec(Module m) {
  // 检查是否存在一个Exec节点，其作用域为m，或者存在一个名为exec或execfile的函数调用
  exists(Exec exec | exec.getScope() = m)
  or
  exists(CallNode call, FunctionValue exec | exec.getACall() = call and call.getScope() = m |
    exec = Value::named("exec") or
    exec = Value::named("execfile")
  )
}

// 定义一个谓词，判断是否使用了未定义的全局变量
predicate undefined_use(Name u) {
  // 检查在类或模块中或在函数中是否使用了未定义的全局变量，并且没有通过猴子补丁、星号导入、exec函数等方式定义
  (
    undefined_use_in_class_or_module(u)
    or
    undefined_use_in_function(u)
  ) and
  not monkey_patched_builtin(u.getId()) and
  not contains_unknown_import_star(u.getEnclosingModule()) and
  not use_of_exec(u.getEnclosingModule()) and
  not exists(u.getVariable().getAStore()) and
  not u.pointsTo(_) and
  not probably_defined_in_loop(u)
}

// 定义一个私有谓词，判断是否是基本块中的第一个使用
private predicate first_use_in_a_block(Name use) {
  // 检查是否存在一个全局变量v和一个基本块b，使得b中的最小加载节点是use
  exists(GlobalVariable v, BasicBlock b, int i |
    i = min(int j | b.getNode(j).getNode() = v.getALoad()) and b.getNode(i) = use.getAFlowNode()
  )
}

// 定义一个谓词，判断是否是第一个未定义的使用
predicate first_undefined_use(Name use) {
  // 检查是否是未定义的使用，并且是基本块中的第一个使用，且没有其他控制流节点严格支配它
  undefined_use(use) and
  exists(GlobalVariable v | v.getALoad() = use |
    first_use_in_a_block(use) and
    not exists(ControlFlowNode other |
      other.getNode() = v.getALoad() and
      other.getBasicBlock().strictlyDominates(use.getAFlowNode().getBasicBlock())
    )
  )
}

// 查询语句：选择所有第一个未定义使用的全局变量，并输出警告信息
from Name u
where first_undefined_use(u)
select u, "This use of global variable '" + u.getId() + "' may be undefined."
