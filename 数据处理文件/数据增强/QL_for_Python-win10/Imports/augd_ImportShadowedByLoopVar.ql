/**
 * @name Import shadowed by loop variable
 * @description A loop variable shadows an import.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// 导入Python代码分析库
import python

/**
 * 检查变量是否遮蔽了导入的模块名
 * @param loopVariable - 待检查的循环变量
 */
predicate variableShadowsImport(Variable loopVariable) {
  // 存在导入语句和对应的模块别名
  exists(Import importDeclaration, Name moduleAlias |
    // 模块别名来源于导入语句
    moduleAlias = importDeclaration.getAName().getAsname() and
    // 循环变量与模块别名同名
    moduleAlias.getId() = loopVariable.getId() and
    // 导入声明的作用域包含循环变量的作用域
    importDeclaration.getScope() = loopVariable.getScope().getScope*()
  )
}

// 查找遮蔽导入的循环变量及其定义位置
from Variable loopVariable, Name variableDefinition
where 
  // 循环变量遮蔽了导入
  variableShadowsImport(loopVariable) and
  // 名称节点定义了该循环变量
  variableDefinition.defines(loopVariable) and
  // 该定义是for循环的目标变量
  exists(For forLoop | variableDefinition = forLoop.getTarget())
// 选择定义点并生成警告信息
select variableDefinition, "Loop variable '" + loopVariable.getId() + "' shadows an import."