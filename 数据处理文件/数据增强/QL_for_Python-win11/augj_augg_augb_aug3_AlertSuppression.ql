/**
 * @name Alert suppression
 * @description Detects and analyzes alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core modules for suppression analysis
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location metadata
 * Extends base functionality from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves precise location coordinates for the node
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startColumn - Beginning column position
   * @param endLine - Concluding line number
   * @param endColumn - Concluding column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location resolution to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Generates text representation of the AST node
   * @return Human-readable node description
   */
  string toString() { result = super.toString() }
}

/**
 * Single-line comment representation in Python code
 * Inherits base comment functionality
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves exact position information for the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startColumn - Beginning column position
   * @param endLine - Concluding line number
   * @param endColumn - Concluding column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Forward location request to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Accesses the raw text content of the comment
   * @return Verbatim comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Produces string representation of the comment
   * @return Human-readable comment description
   */
  string toString() { result = super.toString() }
}

// Configure suppression mapping between AST nodes and comments
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents noqa-style suppression comments compatible with
 * pylint, pyflakes, and LGTM analysis tools
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Validates noqa comment format during instantiation
   * Requires case-insensitive noqa pattern match
   */
  NoqaSuppressionComment() {
    // Verify comment conforms to noqa specification
    // Allows optional whitespace and trailing content
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Retrieves the annotation identifier for suppression
   * @return Standardized "lgtm" annotation tag
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Determines the code scope affected by this suppression
   * Covers the entire line containing the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startColumn - Beginning column position (line start)
   * @param endLine - Concluding line number
   * @param endColumn - Concluding column position
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Obtain comment coordinates and enforce line-start coverage
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}