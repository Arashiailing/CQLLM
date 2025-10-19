/**
 * @name Alert suppression
 * @description Detects and analyzes alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入 CodeQL 抑制处理工具库，用于处理代码中的警告抑制逻辑
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// 导入 Python 注释处理模块，提供代码注释分析功能
private import semmle.python.Comment as CommentProcessor

// 使用模板创建代码节点与注释之间的抑制关系映射
import AlertSuppressionUtil::Make<CodeNode, LineComment>

/**
 * 表示 Python 代码中的抽象语法树节点
 * 作为抑制分析的基础代码单元
 */
class CodeNode instanceof CommentProcessor::AstNode {
  /** 返回节点的字符串表示形式 */
  string toString() { result = super.toString() }

  /** 获取节点的位置信息 */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

/**
 * 表示 Python 代码中的单行注释
 * 用于检测和处理抑制注释
 */
class LineComment instanceof CommentProcessor::Comment {
  /** 获取注释的文本内容 */
  string getText() { result = super.getContents() }

  /** 返回注释的字符串表示形式 */
  string toString() { result = super.toString() }

  /** 获取注释的位置信息 */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

/**
 * 处理 Pylint 和 Pyflakes 兼容的 noqa 抑制注释
 * LGTM 分析器会识别此类注释作为警告抑制标记
 */
class NoqaSuppressor extends SuppressionComment instanceof LineComment {
  /** 返回分析器标识符 "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** 定义注释覆盖的代码范围 */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 验证注释位于行首且位置信息匹配
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }

  /** 构造函数：验证注释是否符合 noqa 格式规范 */
  NoqaSuppressor() {
    // 检查注释文本是否匹配 noqa 格式（不区分大小写，允许前后空格）
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}