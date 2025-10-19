/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import Python comment processing module
private import semmle.python.Comment as PythonComment

/**
 * Represents a Python AST node with location information.
 * Wraps the original AstNode to provide location details and string representation.
 */
class PythonAstNode instanceof PythonComment::AstNode {
  /**
   * Gets the location details of this AST node.
   * @param filePath Path of the containing file
   * @param startLine Starting line number
   * @param startCol Starting column number
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for location information
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Gets the string representation of this AST node.
   * @return String representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a single-line Python comment.
 * Wraps the original Comment to provide location details, text content, and string representation.
 */
class PythonLineComment instanceof PythonComment::Comment {
  /**
   * Gets the location details of this comment.
   * @param filePath Path of the containing file
   * @param startLine Starting line number
   * @param startCol Starting column number
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for location information
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Gets the text content of this comment.
   * @return Text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Gets the string representation of this comment.
   * @return String representation of the comment
   */
  string toString() { result = super.toString() }
}

// Apply AlertSuppression template to establish suppression relationships
import AlertSuppression::Make<PythonAstNode, PythonLineComment>

/**
 * Represents a noqa suppression comment in Python code.
 * Both pylint and pyflakes respect this annotation, so LGTM should too.
 * Extends SuppressionComment and PythonLineComment for noqa-specific behavior.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof PythonLineComment {
  /**
   * Constructs a NoqaSuppressionComment.
   * The comment must match the noqa pattern (case-insensitive).
   */
  NoqaSuppressionComment() {
    // Verify comment text matches noqa format (case-insensitive)
    PythonLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Gets the annotation identifier for this suppression comment.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression comment.
   * @param filePath Path of the containing file
   * @param startLine Starting line number of covered code
   * @param startCol Starting column number of covered code
   * @param endLine Ending line number of covered code
   * @param endCol Ending column number of covered code
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Validate comment location and ensure it starts at line beginning
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}