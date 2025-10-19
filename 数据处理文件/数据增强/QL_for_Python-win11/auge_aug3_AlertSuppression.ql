/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入CodeQL工具库中的AlertSuppression模块，重命名为AlertSuppression
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// 导入Python注释处理模块，重命名为PythonComment
private import semmle.python.Comment as PythonComment

/**
 * Represents a node in the Python AST (Abstract Syntax Tree).
 * This class wraps the original AstNode to provide location information and string representation.
 */
class CodeNode instanceof PythonComment::AstNode {
  /**
   * Gets the location information for this AST node.
   * @param filepath The path of the file containing the node
   * @param startline The starting line number of the node
   * @param startcolumn The starting column number of the node
   * @param endline The ending line number of the node
   * @param endcolumn The ending column number of the node
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegates to the parent class to retrieve location information
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  /**
   * Gets a string representation of this AST node.
   * @return A string representing the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a single-line comment in Python code.
 * This class wraps the original Comment class to provide location information, text content, and string representation.
 */
class LineComment instanceof PythonComment::Comment {
  /**
   * Gets the location information for this comment.
   * @param filepath The path of the file containing the comment
   * @param startline The starting line number of the comment
   * @param startcolumn The starting column number of the comment
   * @param endline The ending line number of the comment
   * @param endcolumn The ending column number of the comment
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegates to the parent class to retrieve location information
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  /**
   * Gets the text content of this comment.
   * @return The text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Gets a string representation of this comment.
   * @return A string representing the comment
   */
  string toString() { result = super.toString() }
}

// 使用AlertSuppression模板建立节点与注释的抑制关系
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
    // Checks if the comment text matches the noqa format (case-insensitive)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Gets the annotation identifier for this suppression comment.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression comment.
   * @param filepath The path of the file containing the covered code
   * @param startline The starting line number of the covered code
   * @param startcolumn The starting column number of the covered code
   * @param endline The ending line number of the covered code
   * @param endcolumn The ending column number of the covered code
   */
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Verifies the comment location and ensures it starts from the beginning of the line
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}