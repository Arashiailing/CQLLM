/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入 CodeQL 工具库中的 AlertSuppression 模块，用于处理警告抑制机制
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// 导入 Python 注释处理模块，用于解析和操作代码注释
private import semmle.python.Comment as CommentProcessor

// 定义抽象语法树节点类，表示 Python 代码中的语法结构元素
class PythonAstNode instanceof CommentProcessor::AstNode {
  /** 获取节点的位置信息（源文件路径和行列范围） */
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // 通过父类方法获取节点的精确位置信息
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  /** 返回节点的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 定义单行注释类，表示 Python 代码中的单行注释元素
class SingleLineComment instanceof CommentProcessor::Comment {
  /** 获取注释的位置信息（源文件路径和行列范围） */
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // 通过父类方法获取注释的精确位置信息
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  /** 获取注释的文本内容 */
  string getText() { result = super.getContents() }

  /** 返回注释的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 应用模板生成 AST 节点和单行注释之间的抑制关系
import SuppressionUtil::Make<PythonAstNode, SingleLineComment>

/**
 * Pylint 和 Pyflakes 兼容的 noqa 抑制注释
 * LGTM 分析器应识别此类注释
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** 构造函数：验证注释是否符合 noqa 格式 */
  NoqaStyleSuppressor() {
    // 检查注释文本是否符合 noqa 格式（不区分大小写，允许前后有空格）
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** 返回注解标识符 "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** 定义注释覆盖的代码范围 */
  override predicate covers(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // 确保注释位于行首且位置信息匹配
    this.hasLocationInfo(sourcePath, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}