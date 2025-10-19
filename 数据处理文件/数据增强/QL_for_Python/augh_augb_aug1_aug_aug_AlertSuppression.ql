/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入 CodeQL 工具库中的 AlertSuppression 模块，用于处理抑制逻辑
private import codeql.util.suppression.AlertSuppression as AlertSupp
// 导入 Python 注释处理模块，用于处理代码注释
private import semmle.python.Comment as CommentUtil

// 定义抽象语法树节点类，表示 Python 代码中的语法结构元素
class PythonAstNode instanceof CommentUtil::AstNode {
  /** 获取节点的位置信息（文件路径和行列范围） */
  predicate hasLocationInfo(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    // 通过父类方法获取节点的精确位置
    super.getLocation().hasLocationInfo(fPath, sLine, sCol, eLine, eCol)
  }

  /** 返回节点的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 定义单行注释类，表示 Python 代码中的单行注释元素
class SingleLineComment instanceof CommentUtil::Comment {
  /** 获取注释的位置信息（文件路径和行列范围） */
  predicate hasLocationInfo(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    // 通过父类方法获取注释的精确位置
    super.getLocation().hasLocationInfo(fPath, sLine, sCol, eLine, eCol)
  }

  /** 获取注释的文本内容 */
  string getText() { result = super.getContents() }

  /** 返回注释的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 应用模板生成 AST 节点和单行注释之间的抑制关系
import AlertSupp::Make<PythonAstNode, SingleLineComment>

/**
 * Pylint 和 Pyflakes 兼容的 noqa 抑制注释
 * LGTM 分析器应识别此类注释
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** 构造函数：验证注释是否符合 noqa 格式 */
  NoqaStyleSuppressor() {
    // 检查注释文本是否符合 noqa 格式（不区分大小写，允许前后有空格）
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** 返回注解标识符 "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** 定义注释覆盖的代码范围 */
  override predicate covers(
    string fPath, int sLine, int sCol, int eLine, int eCol
  ) {
    // 确保注释位于行首且位置信息匹配
    hasLocationInfo(fPath, sLine, _, eLine, eCol) and
    sCol = 1
  }
}