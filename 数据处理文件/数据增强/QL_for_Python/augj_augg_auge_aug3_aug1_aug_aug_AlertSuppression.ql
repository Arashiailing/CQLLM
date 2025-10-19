/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入 CodeQL 工具库中的 AlertSuppression 模块，用于处理警告抑制机制
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// 导入 Python 注释处理模块，用于解析和操作代码注释
private import semmle.python.Comment as CommentProcessor

/**
 * 表示 Python 代码中的单行注释
 * 继承自 CommentProcessor::Comment，提供位置信息和内容访问功能
 */
class SingleLineComment instanceof CommentProcessor::Comment {
  /** 返回注释的文本表示 */
  string toString() { result = super.toString() }

  /**
   * 获取注释的详细位置信息
   * @param filePath - 源文件路径
   * @param startLine - 起始行号
   * @param startCol - 起始列号
   * @param endLine - 结束行号
   * @param endCol - 结束列号
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** 获取注释的完整文本内容 */
  string getText() { result = super.getContents() }
}

/**
 * 表示 Python 代码中的抽象语法树节点
 * 继承自 CommentProcessor::AstNode，提供位置信息和字符串表示功能
 */
class PythonAstNode instanceof CommentProcessor::AstNode {
  /** 返回节点的文本表示 */
  string toString() { result = super.toString() }

  /**
   * 获取节点的详细位置信息
   * @param filePath - 源文件路径
   * @param startLine - 起始行号
   * @param startCol - 起始列号
   * @param endLine - 结束行号
   * @param endCol - 结束列号
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// 应用模板生成 AST 节点和单行注释之间的抑制关系
import SuppressionUtil::Make<PythonAstNode, SingleLineComment>

/**
 * 表示兼容 Pylint 和 Pyflakes 的 noqa 风格抑制注释
 * 此类注释可被 LGTM 分析器识别并用于抑制警告
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** 返回用于标识的注解名称 */
  override string getAnnotation() { result = "lgtm" }

  /**
   * 指定注释所覆盖的代码范围
   * @param filePath - 源文件路径
   * @param startLine - 起始行号
   * @param startCol - 起始列号
   * @param endLine - 结束行号
   * @param endCol - 结束列号
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1  // 确保注释位于行首
  }

  /** 验证注释是否符合 noqa 格式规范 */
  NoqaStyleSuppressor() {
    // 检查注释内容是否匹配 noqa 格式（不区分大小写，允许前后有空格）
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}