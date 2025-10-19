/**
 * @name Alert suppression
 * @description Detects and analyzes alert suppression comments in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import required modules for alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location information
 * Inherits base functionality from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves detailed location coordinates for the node
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column position
   * @param endLine - Ending line number
   * @param endCol - Ending column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Provides string representation of the AST node
   * @return Node's string representation
   */
  string toString() { result = super.toString() }
}

/**
 * Single-line comment wrapper with location and text access
 * Extends base Comment class from Python comment module
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves detailed location coordinates for the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column position
   * @param endLine - Ending line number
   * @param endCol - Ending column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Retrieves the actual text content of the comment
   * @return Raw comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Provides string representation of the comment
   * @return Comment's string representation
   */
  string toString() { result = super.toString() }
}

// Establish suppression relationship between nodes and comments
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment compatible with pylint, pyflakes, and LGTM
 * Identifies comments that suppress alerts across multiple tools
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Validates the comment as a noqa suppression directive
   * Matches case-insensitive noqa pattern with optional content
   */
  NoqaSuppressionComment() {
    // Verify comment follows noqa format pattern
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for this suppression
   * @return Standardized annotation identifier "lgtm"
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression
   * Covers the entire line containing the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number (comment line)
   * @param startCol - Beginning column (always line start)
   * @param endLine - Ending line number (comment line)
   * @param endCol - Ending column position
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve comment location and enforce line-wide coverage
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}