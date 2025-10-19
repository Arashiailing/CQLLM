/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入 CodeQL 警报抑制工具
private import codeql.util.suppression.AlertSuppression as AS
// 导入 Python 注释处理模块
private import semmle.python.Comment as P

// 表示具有位置跟踪功能的 AST 节点
class AstNode instanceof P::AstNode {
  // 验证节点位置是否与指定坐标匹配
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 提供 AST 节点的字符串表示
  string toString() { result = super.toString() }
}

// 表示具有位置跟踪功能的单行注释
class SingleLineComment instanceof P::Comment {
  // 验证注释位置是否与指定坐标匹配
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 获取注释的文本内容
  string getText() { result = super.getContents() }

  // 提供注释的字符串表示
  string toString() { result = super.toString() }
}

// 使用 AS 模板生成抑制关系
import AS::Make<AstNode, SingleLineComment>

/**
 * 表示一个 noqa 抑制注释。pylint 和 pyflakes 都遵守此注释，因此 lgtm 也应该遵守。
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // 通过匹配 noqa 注释模式进行初始化
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 返回抑制注释的标识符
  override string getAnnotation() { result = "lgtm" }

  // 定义此抑制的代码覆盖范围
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 提取并验证注释的位置信息
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // 设置行起始位置和边界匹配
      startLine = commentStartLine and
      endLine = commentEndLine and
      startCol = 1 and
      endCol = commentEndColumn
    )
  }
}