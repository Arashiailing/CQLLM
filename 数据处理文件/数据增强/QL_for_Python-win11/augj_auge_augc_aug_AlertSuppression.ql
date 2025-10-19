/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities for handling suppression annotations
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module for analyzing source code comments
private import semmle.python.Comment as P

/**
 * Represents AST nodes with location tracking capabilities.
 * This class provides a uniform interface for accessing location information
 * across different types of AST nodes in the Python code.
 */
class AstNode instanceof P::AstNode {
  /**
   * Determines if this AST node matches the specified location coordinates.
   * @param filePath The path to the source file containing the node.
   * @param startLine The starting line number of the node (1-based).
   * @param startColumn The starting column number of the node (1-based).
   * @param finishLine The ending line number of the node (1-based).
   * @param finishColumn The ending column number of the node (1-based).
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  /**
   * Returns a string representation of this AST node.
   * @return A string describing the node.
   */
  string toString() { result = super.toString() }
}

/**
 * Represents single-line comments with location tracking.
 * This class extends the basic comment functionality to provide
 * location information and text content retrieval.
 */
class SingleLineComment instanceof P::Comment {
  /**
   * Determines if this comment matches the specified location coordinates.
   * @param filePath The path to the source file containing the comment.
   * @param startLine The starting line number of the comment (1-based).
   * @param startColumn The starting column number of the comment (1-based).
   * @param finishLine The ending line number of the comment (1-based).
   * @param finishColumn The ending column number of the comment (1-based).
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  /**
   * Retrieves the text content of this comment.
   * @return The full text of the comment, including the # symbol.
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of this comment.
   * @return A string describing the comment.
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template with our custom node types
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment, which is a standard mechanism
 * for suppressing linting warnings in Python code. Both pylint and pyflakes
 * respect this format, and this class enables LGTM to recognize it as well.
 * 
 * The noqa comment format is: "# noqa" or "# noqa: <error_codes>"
 * These comments are typically placed at the end of a line to suppress
 * warnings for that specific line.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Initializes a NoqaSuppressionComment by matching the noqa comment pattern.
   * This constructor identifies comments that follow the noqa format,
   * which is case-insensitive and may include optional error codes.
   */
  NoqaSuppressionComment() {
    // Match any comment that contains "noqa" (case-insensitive) optionally followed by a colon and more text
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the suppression annotation identifier.
   * For noqa comments, this is always "lgtm" to indicate that the
   * suppression should be recognized by LGTM.
   * @return The string "lgtm".
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code coverage scope for this suppression.
   * Noqa comments typically suppress warnings for the entire line they appear on.
   * @param filePath The path to the source file containing the suppression.
   * @param startLine The starting line number of the suppression scope (1-based).
   * @param startColumn The starting column number of the suppression scope (1-based).
   * @param finishLine The ending line number of the suppression scope (1-based).
   * @param finishColumn The ending column number of the suppression scope (1-based).
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(filePath, startLine, _, finishLine, finishColumn) and
    startColumn = 1
  }
}