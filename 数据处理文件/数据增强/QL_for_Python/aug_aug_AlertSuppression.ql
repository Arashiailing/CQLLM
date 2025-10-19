/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入 CodeQL 工具库中的 AlertSuppression 模块，用于处理抑制逻辑
private import codeql.util.suppression.AlertSuppression as SuppressionHelper
// 导入 Python 注释处理模块，用于处理代码注释
private import semmle.python.Comment as CommentHandler

// 定义代码节点类，表示 Python 代码中的抽象语法树节点
class CodeNode instanceof CommentHandler::AstNode {
  /** 检查节点是否具有指定的位置信息 */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 调用父类的位置检查方法获取节点的位置信息
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** 返回节点的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 定义单行注释类，表示 Python 代码中的单行注释
class LineComment instanceof CommentHandler::Comment {
  /** 检查注释是否具有指定的位置信息 */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 调用父类的位置检查方法获取注释的位置信息
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** 获取注释的文本内容 */
  string getText() { result = super.getContents() }

  /** 返回注释的字符串表示形式 */
  string toString() { result = super.toString() }
}

// 使用模板生成代码节点和单行注释间的抑制关系
import SuppressionHelper::Make<CodeNode, LineComment>

/**
 * Pylint 和 Pyflakes 兼容的 noqa 抑制注释
 * LGTM 分析器应识别此类注释
 */
class NoqaSuppressor extends SuppressionComment instanceof LineComment {
  /** 构造函数：验证注释是否符合 noqa 格式 */
  NoqaSuppressor() {
    // 检查注释文本是否符合 noqa 格式（不区分大小写，允许前后有空格）
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** 返回注解标识符 "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** 定义注释覆盖的代码范围 */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 确保注释位于行首且位置信息匹配
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}