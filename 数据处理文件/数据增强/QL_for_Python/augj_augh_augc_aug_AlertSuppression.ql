/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module for analyzing code comments
private import semmle.python.Comment as P

/**
 * Represents AST nodes with location tracking capabilities.
 * This class extends the basic AST node to provide location information.
 */
class AstNode instanceof P::AstNode {
  /**
   * Determines if the node is located at specified coordinates.
   * @param filePath Path of the file containing the node
   * @param startLine Starting line number of the node
   * @param startCol Starting column number of the node
   * @param endLine Ending line number of the node
   * @param endCol Ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Provides a string representation of the AST node.
   * @return String describing the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents single-line comments with location tracking.
 * This class extends the basic comment to provide location and text information.
 */
class SingleLineComment instanceof P::Comment {
  /**
   * Determines if the comment is located at specified coordinates.
   * @param filePath Path of the file containing the comment
   * @param startLine Starting line number of the comment
   * @param startCol Starting column number of the comment
   * @param endLine Ending line number of the comment
   * @param endCol Ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Retrieves the text content of the comment.
   * @return Text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of the comment.
   * @return String describing the comment
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class identifies and processes noqa-style suppression comments in Python code.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Initializes the noqa suppression comment by matching the noqa comment pattern.
   * The pattern matches comments that start with "noqa" (case-insensitive),
   * optionally followed by additional text (but not a colon).
   */
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the suppression annotation identifier.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code coverage scope for this suppression.
   * The suppression applies to the entire line where the comment appears.
   * @param filePath Path of the file containing the suppression
   * @param startLine Starting line number of the suppression
   * @param startCol Starting column number of the suppression
   * @param endLine Ending line number of the suppression
   * @param endCol Ending column number of the suppression
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}