/**
 * @name Misnamed function
 * @description Identifies functions whose names begin with an uppercase letter, 
 *              which violates Python naming conventions and decreases code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // 导入Python库，用于分析Python代码

// 定义谓词函数，用于检测函数名是否违反命名规范（以大写字母开头）
predicate isMisnamedFunction(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // 提取函数名的首字符
    not initialChar = initialChar.toLowerCase()  // 检查首字符是否为大写字母
  )
}

// 主查询：识别所有违反命名规范的函数
from Function targetFunction
where
  // 确保函数存在于源代码中
  targetFunction.inSource() and
  
  // 检查函数名是否以大写字母开头
  isMisnamedFunction(targetFunction) and
  
  // 排除同一文件中的同名函数（避免重复报告）
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // 确保不是同一个函数
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // 确保在同一文件中
    isMisnamedFunction(otherFunction)  // 确保也违反命名规范
  )
select targetFunction, "Function names should start in lowercase."  // 输出结果并给出改进建议