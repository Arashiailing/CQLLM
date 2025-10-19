/**
 * @name Unused import
 * @description Import is not required as it is not used
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unused-import
 */

// 导入Python库和相关模块
import python
import Variables.Definition
import semmle.python.ApiGraphs

// 私有谓词，用于判断是否为pytest的fixture
private predicate is_pytest_fixture(Import imp, Variable name) {
  // 存在别名a、pytest_fixture装饰器和装饰器节点
  exists(Alias a, API::Node pytest_fixture, API::Node decorator |
    // 获取pytest.fixture成员
    pytest_fixture = API::moduleImport("pytest").getMember("fixture") and
    // 处理两种不同的装饰器形式
    decorator in [pytest_fixture, pytest_fixture.getReturn()] and
    // 获取导入的名称
    a = imp.getAName() and
    // 获取变量名称
    a.getAsname().(Name).getVariable() = name and
    // 获取装饰器的值
    a.getValue() = decorator.getReturn().getAValueReachableFromSource().asExpr()
  )
}

// 谓词，用于判断全局名称是否被使用
predicate global_name_used(Module m, string name) {
  // 存在使用全局变量的名称和使用点
  exists(Name u, GlobalVariable v |
    u.uses(v) and
    v.getId() = name and
    u.getEnclosingModule() = m
  )
  or
  // 使用未定义的类局部变量时，将使用全局变量
  exists(Name u, LocalVariable v |
    u.uses(v) and
    v.getId() = name and
    u.getEnclosingModule() = m and
    not v.getScope().getEnclosingScope*() instanceof Function
  )
}

/** 如果模块有`__all__`但我们不理解它，则保持 */
predicate all_not_understood(Module m) {
  // 存在全局变量`__all__`且其作用域为模块m
  exists(GlobalVariable a | a.getId() = "__all__" and a.getScope() = m |
    // `__all__`不是定义为简单列表
    not m.declaredInAll(_)
    or
    // `__all__`被修改
    exists(Call c | c.getFunc().(Attribute).getObject() = a.getALoad())
  )
}

// 谓词，用于判断导入的模块是否在doctest中使用
predicate imported_module_used_in_doctest(Import imp) {
  exists(string modname, string docstring |
    // 获取导入模块的名称
    imp.getAName().getAsname().(Name).getId() = modname and
    // 查找包含特定模式的doctest
    docstring = doctest_in_scope(imp.getScope()) and
    docstring.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + modname + "[\\s\\S]*")
  )
}

// pragma指令，不内联函数，用于获取范围内的doctest字符串
pragma[noinline]
private string doctest_in_scope(Scope scope) {
  exists(StringLiteral doc |
    doc.getEnclosingModule() = scope and
    doc.isDocString() and
    result = doc.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

// pragma指令，不内联函数，用于获取模块中的类型提示注释
pragma[noinline]
private string typehint_annotation_in_module(Module module_scope) {
  exists(StringLiteral annotation |
    annotation = any(Arguments a).getAnAnnotation().getASubExpression*()
    or
    annotation = any(AnnAssign a).getAnnotation().getASubExpression*()
    or
    annotation = any(FunctionExpr f).getReturns().getASubExpression*()
  |
    annotation.pointsTo(Value::forString(result)) and
    annotation.getEnclosingModule() = module_scope
  )
}

// pragma指令，不内联函数，用于获取文件中的类型提示注释
pragma[noinline]
private string typehint_comment_in_file(File file) {
  exists(Comment typehint |
    file = typehint.getLocation().getFile() and
    result = typehint.getText() and
    result.matches("# type:%")
  )
}

/** 如果从`imp`导入的别名`name`在同一文件中的类型提示中使用，则保持 */
predicate imported_alias_used_in_typehint(Import imp, Variable name) {
  imp.getAName().getAsname().(Name).getVariable() = name and
  exists(File file, Module module_scope |
    module_scope = imp.getEnclosingModule() and
    file = module_scope.getFile()
  |
    // 查找包含特定模式的类型提示注释
    typehint_comment_in_file(file).regexpMatch("# type:.*" + name.getId() + ".*")
    or
    // 类型提示在字符串注释中，用于前向引用
    typehint_annotation_in_module(module_scope).regexpMatch(".*\\b" + name.getId() + "\\b.*")
  )
}

// 谓词，用于判断导入是否未使用
predicate unused_import(Import imp, Variable name) {
  imp.getAName().getAsname().(Name).getVariable() = name and
  not imp.getAnImportedModuleName() = "__future__" and
  not imp.getEnclosingModule().declaredInAll(name.getId()) and
  imp.getScope() = imp.getEnclosingModule() and
  not global_name_used(imp.getScope(), name.getId()) and
  // `__init__.py`中的导入用于强制模块加载
  not imp.getEnclosingModule().isPackageInit() and
  // 名称可能为epytext文档中的使用而导入
  not exists(Comment cmt | cmt.getText().matches("%L{" + name.getId() + "}%") |
    cmt.getLocation().getFile() = imp.getLocation().getFile()
  ) and
  not name_acceptable_for_unused_variable(name) and
  // 假设不透明的`__all__`包括导入的模块
  not all_not_understood(imp.getEnclosingModule()) and
  not imported_module_used_in_doctest(imp) and
  not imported_alias_used_in_typehint(imp, name) and
  not is_pytest_fixture(imp, name) and
  // 仅考虑实际指向某物的导入语句（可能是未知模块）。如果不是这种情况，则导入语句可能从未执行。
  imp.getAName().getValue().pointsTo(_)
}

// 查询语句，选择未使用的导入语句和相关信息
from Stmt s, Variable name
where unused_import(s, name)
select s, "Import of '" + name.getId() + "' is not used."
