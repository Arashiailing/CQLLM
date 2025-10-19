/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入CodeQL工具库中的AlertSuppression模块，用于处理告警抑制功能
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// 导入Python注释处理模块，用于解析Python代码中的注释
private import semmle.python.Comment as PythonComment

/**
 * Represents a node in the Python AST (Abstract Syntax Tree).
 * This class encapsulates the original AstNode to provide location details and string representation.
 */
class CodeNode instanceof PythonComment::AstNode {
  /**
   * Retrieves the location details for this AST node.
   * @param filePath The path of the file containing the node
   * @param startLine The starting line number of the node
   * @param startCol The starting column number of the node
   * @param endLine The ending line number of the node
   * @param endCol The ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegates to the parent class to obtain location information
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Provides a string representation of this AST node.
   * @return A string representing the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a single-line comment in Python code.
 * This class encapsulates the original Comment to provide location details, text content, and string representation.
 */
class LineComment instanceof PythonComment::Comment {
  /**
   * Retrieves the location details for this comment.
   * @param filePath The path of the file containing the comment
   * @param startLine The starting line number of the comment
   * @param startCol The starting column number of the comment
   * @param endLine The ending line number of the comment
   * @param endCol The ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegates to the parent class to obtain location information
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Retrieves the text content of this comment.
   * @return The text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of this comment.
   * @return A string representing the comment
   */
  string toString() { result = super.toString() }
}

// 应用AlertSuppression模板来建立代码节点与注释之间的抑制关系
import AlertSuppression::Make<CodeNode, LineComment>

/**
 * Represents a noqa suppression comment in Python code.
 * Both pylint and pyflakes respect this annotation, so LGTM should too.
 * This class extends SuppressionComment and LineComment to provide specific behavior for noqa comments.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof LineComment {
  /**
   * Constructs a NoqaSuppressionComment.
   * The comment must match the noqa pattern (case-insensitive).
   */
  NoqaSuppressionComment() {
    // Verifies if the comment text matches the noqa format (case-insensitive)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for this suppression comment.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression comment.
   * @param filePath The path of the file containing the covered code
   * @param startLine The starting line number of the covered code
   * @param startCol The starting column number of the covered code
   * @param endLine The ending line number of the covered code
   * @param endCol The ending column number of the covered code
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Validates the comment location and ensures it starts from the beginning of the line
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}