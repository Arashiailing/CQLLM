/**
 * @name Alert suppression analysis
 * @description Detects and examines alert suppression techniques in Python code,
 *              with a focus on 'noqa' style suppression comments that are frequently
 *              utilized to silence linter warnings.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for examining suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities to extract and handle code comments
private import semmle.python.Comment as PythonComment

/**
 * Represents a single-line Python comment with improved location tracking functionality.
 * This class builds upon the base Comment class to offer more precise location details.
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Obtains comprehensive location information for the comment.
   * @param filePath - The path to the file containing the comment
   * @param startLine - The starting line number of the comment
   * @param startColumn - The starting column number of the comment
   * @param finishLine - The ending line number of the comment
   * @param finishColumn - The ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  /**
   * Retrieves the text content of the comment, without the comment marker.
   * @returns The textual content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of the comment.
   * @returns A string representation of the comment
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a Python AST node with detailed location tracking capabilities.
 * This class extends the base AstNode class to provide thorough location information.
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Obtains comprehensive location information for the AST node.
   * @param filePath - The path to the file containing the node
   * @param startLine - The starting line number of the node
   * @param startColumn - The starting column number of the node
   * @param finishLine - The ending line number of the node
   * @param finishColumn - The ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  /**
   * Provides a string representation of the AST node.
   * @returns A string representation of the node
   */
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments using the AlertSuppression framework
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a 'noqa' suppression comment, which is a widely recognized mechanism
 * for disabling linter warnings in Python code. Both pylint and pyflakes respect
 * this convention, making it a standard for suppression in the Python ecosystem.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructs a NoqaSuppressionComment by identifying comments that match the noqa pattern.
   * The pattern is case-insensitive and allows for optional suffixes after the noqa keyword.
   */
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix (without colon)
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for this suppression comment.
   * @returns The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Specifies the code range covered by this suppression comment.
   * A noqa comment typically covers the entire line where it appears.
   * @param filePath - The path to the file containing the suppression
   * @param startLine - The starting line number of the covered range
   * @param startColumn - The starting column number of the covered range
   * @param finishLine - The ending line number of the covered range
   * @param finishColumn - The ending column number of the covered range
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Get comment location and verify it starts at column 1 (beginning of line)
    this.hasLocationInfo(filePath, startLine, _, finishLine, finishColumn) and
    startColumn = 1
  }
}