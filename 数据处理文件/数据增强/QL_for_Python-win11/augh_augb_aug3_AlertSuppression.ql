/**
 * @name Alert suppression
 * @description Identifies alert suppressions in Python code through comment analysis
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import required modules for suppression analysis
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location details
 * Inherits base AST node functionality from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieve precise location coordinates for the node
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column position
   * @param endLine - Concluding line number
   * @param endCol - Concluding column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location retrieval to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Generate string representation of the AST node
   * @return Textual representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Single-line comment representation in Python code
 * Extends base comment functionality from Python comment module
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Obtain precise location coordinates for the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column position
   * @param endLine - Concluding line number
   * @param endCol - Concluding column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location retrieval to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Extract the textual content of the comment
   * @return Raw comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Generate string representation of the comment
   * @return Textual representation of the comment
   */
  string toString() { result = super.toString() }
}

// Establish suppression mapping between nodes and comments using AlertSuppression framework
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments recognized by pylint and pyflakes
 * Also honored by LGTM analysis engine
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor validating noqa comment format
   * Requires case-insensitive noqa pattern match
   */
  NoqaSuppressionComment() {
    // Validate comment adheres to noqa format specification
    // Pattern permits optional whitespace and trailing content
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieve annotation identifier for this suppression
   * @return "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Define code scope covered by this suppression
   * Covers entire line containing the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number (comment line)
   * @param startCol - Beginning column (always 1 for line coverage)
   * @param endLine - Concluding line number (comment line)
   * @param endCol - Concluding column position
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve comment location and enforce line-start coverage
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}