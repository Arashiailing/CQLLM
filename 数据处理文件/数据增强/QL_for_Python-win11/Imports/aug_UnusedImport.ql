/**
 * @name Unused import
 * @description Import is not required as it is not used
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unused-import */

import python
import Variables.Definition
import semmle.python.ApiGraphs

/**
 * 判断导入是否为pytest的fixture装饰器
 * 检测通过pytest.fixture装饰的函数，这些导入不应被视为未使用
 */
private predicate is_pytest_fixture(Import imp, Variable importedName) {
  exists(Alias alias, API::Node fixtureNode, API::Node decoratorNode |
    // 获取pytest.fixture装饰器节点
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // 处理直接使用fixture和使用其返回值的两种情况
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // 获取导入别名
    alias = imp.getAName() and
    // 关联导入的变量名
    alias.getAsname().(Name).getVariable() = importedName and
    // 验证别名值与装饰器返回值匹配
    alias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

/**
 * 检查模块中全局名称是否被使用
 * 包括直接使用的全局变量和在非函数作用域中使用的局部变量
 */
predicate global_name_used(Module moduleScope, string nameStr) {
  // 检查直接使用的全局变量
  exists(Name usageNode, GlobalVariable globalVar |
    usageNode.uses(globalVar) and
    globalVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope
  )
  or
  // 检查在非函数作用域中使用的局部变量（实际会引用全局变量）
  exists(Name usageNode, LocalVariable localVar |
    usageNode.uses(localVar) and
    localVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope and
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/**
 * 检测模块中是否存在无法静态分析的`__all__`定义
 * 如果`__all__`不是简单列表或被动态修改，则无法确定导入是否被使用
 */
predicate all_not_understood(Module moduleScope) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleScope and
    (
      // `__all__`不是静态定义的简单列表
      not moduleScope.declaredInAll(_)
      or
      // `__all__`在代码中被动态修改
      exists(Call modifyCall | 
        modifyCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

/**
 * 检查导入的模块是否在doctest中被使用
 * 如果导入的名称出现在doctest示例中，则不应被视为未使用
 */
predicate imported_module_used_in_doctest(Import importStmt) {
  exists(string importedName, string docstringContent |
    // 获取导入的名称
    importStmt.getAName().getAsname().(Name).getId() = importedName and
    // 检查doctest中是否引用了该导入
    docstringContent = doctest_in_scope(importStmt.getScope()) and
    docstringContent.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + importedName + "[\\s\\S]*")
  )
}

/**
 * 获取指定作用域中的doctest字符串内容
 * 标记为noinline以避免函数内联，保持查询性能
 */
pragma[noinline]
private string doctest_in_scope(Scope scope) {
  exists(StringLiteral docLiteral |
    docLiteral.getEnclosingModule() = scope and
    docLiteral.isDocString() and
    result = docLiteral.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

/**
 * 获取模块中作为字符串出现的类型提示注释
 * 这些通常用于前向引用，标记为noinline以优化性能
 */
pragma[noinline]
private string typehint_annotation_in_module(Module moduleScope) {
  exists(StringLiteral typeAnnotation |
    (
      // 检查函数参数的类型注释
      typeAnnotation = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      // 检查变量注解的类型注释
      typeAnnotation = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      // 检查函数返回值的类型注释
      typeAnnotation = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    typeAnnotation.pointsTo(Value::forString(result)) and
    typeAnnotation.getEnclosingModule() = moduleScope
  )
}

/**
 * 获取文件中的类型提示注释
 * 这些是以"# type:"开头的注释，标记为noinline以优化性能
 */
pragma[noinline]
private string typehint_comment_in_file(File file) {
  exists(Comment typeComment |
    file = typeComment.getLocation().getFile() and
    result = typeComment.getText() and
    result.matches("# type:%")
  )
}

/**
 * 检查导入的别名是否在类型提示中被使用
 * 包括类型注释和字符串形式的类型提示（用于前向引用）
 */
predicate imported_alias_used_in_typehint(Import importStmt, Variable importedVar) {
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  exists(File file, Module moduleScope |
    moduleScope = importStmt.getEnclosingModule() and
    file = moduleScope.getFile()
  |
    // 检查类型注释中是否使用了该导入
    typehint_comment_in_file(file).regexpMatch("# type:.*" + importedVar.getId() + ".*")
    or
    // 检查字符串形式的类型提示中是否使用了该导入
    typehint_annotation_in_module(moduleScope).regexpMatch(".*\\b" + importedVar.getId() + "\\b.*")
  )
}

/**
 * 判断导入是否未被使用
 * 综合多种条件排除特殊情况，确保只报告真正未使用的导入
 */
predicate unused_import(Import importStmt, Variable importedVar) {
  // 基本条件：导入的变量存在且不是__future__导入
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  not importStmt.getAnImportedModuleName() = "__future__" and
  
  // 作用域条件：导入在模块级别
  importStmt.getScope() = importStmt.getEnclosingModule() and
  
  // 使用条件：变量未被全局使用
  not global_name_used(importStmt.getScope(), importedVar.getId()) and
  
  // 排除特殊情况：
  // 1. 在__all__中声明的导入
  not importStmt.getEnclosingModule().declaredInAll(importedVar.getId()) and
  // 2. __init__.py中的导入用于强制模块加载
  not importStmt.getEnclosingModule().isPackageInit() and
  // 3. epytext文档中使用的导入
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVar.getId() + "}%") and
    docComment.getLocation().getFile() = importStmt.getLocation().getFile()
  ) and
  // 4. 符合未使用变量命名约定的变量（如_或__）
  not name_acceptable_for_unused_variable(importedVar) and
  // 5. 模块有不透明的__all__定义
  not all_not_understood(importStmt.getEnclosingModule()) and
  // 6. 在doctest中使用的导入
  not imported_module_used_in_doctest(importStmt) and
  // 7. 在类型提示中使用的导入
  not imported_alias_used_in_typehint(importStmt, importedVar) and
  // 8. pytest fixture导入
  not is_pytest_fixture(importStmt, importedVar) and
  
  // 确保导入实际指向某个值（可能是未知模块）
  importStmt.getAName().getValue().pointsTo(_)
}

/**
 * 主查询：查找并报告未使用的导入语句
 * 输出未使用的导入语句及其名称
 */
from Import importStmt, Variable importedVar
where unused_import(importStmt, importedVar)
select importStmt, "Import of '" + importedVar.getId() + "' is not used."