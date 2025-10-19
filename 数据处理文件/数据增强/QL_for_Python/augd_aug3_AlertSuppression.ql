/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import the AlertSuppression utility module for handling alert suppressions
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment

// Wrapper class for AST nodes that extends PythonComment::AstNode functionality
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves the location information for this AST node.
   * @param filePath - The file path where the node is located
   * @param startLine - The starting line number of the node
   * @param startColumn - The starting column number of the node
   * @param endLine - The ending line number of the node
   * @param endColumn - The ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class to obtain and validate location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Returns a string representation of this AST node.
   * @returns A string describing the node
   */
  string toString() { result = super.toString() }
}

// Wrapper class for single-line comments that extends PythonComment::Comment functionality
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves the location information for this comment.
   * @param filePath - The file path where the comment is located
   * @param startLine - The starting line number of the comment
   * @param startColumn - The starting column number of the comment
   * @param endLine - The ending line number of the comment
   * @param endColumn - The ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class to obtain and validate location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Returns the text content of this comment.
   * @returns The string content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of this comment.
   * @returns A string describing the comment
   */
  string toString() { result = super.toString() }
}

// Establish the relationship between nodes and comments for alert suppression
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this syntax,
 * so LGTM analysis should also recognize and respect these suppressions.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor that verifies the comment follows the noqa format.
   * The noqa comment is case-insensitive and may include additional content after the noqa keyword.
   */
  NoqaSuppressionComment() {
    // Check if the comment text matches the noqa format (case-insensitive)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for this suppression comment.
   * @returns The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression comment.
   * @param filePath - The file path where the comment is located
   * @param startLine - The starting line number of the covered range
   * @param startColumn - The starting column number of the covered range
   * @param endLine - The ending line number of the covered range
   * @param endColumn - The ending column number of the covered range
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Verify the comment location and ensure it starts at the beginning of the line
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}