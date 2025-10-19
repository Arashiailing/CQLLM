/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core modules for suppression analysis
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location metadata
 * Inherits base functionality from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Extracts precise location coordinates for the node
   * @param file - Source file path
   * @param start - Beginning line number
   * @param startCol - Beginning column position
   * @param end - Concluding line number
   * @param endCol - Concluding column position
   */
  predicate hasLocationInfo(
    string file, int start, int startCol, int end, int endCol
  ) {
    // Forward location request to parent implementation
    super.getLocation().hasLocationInfo(file, start, startCol, end, endCol)
  }

  /**
   * Generates text representation of the AST node
   * @return Human-readable node description
   */
  string toString() { result = super.toString() }
}

/**
 * Single-line comment representation in Python code
 * Extends base comment functionality
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves exact position information for the comment
   * @param file - Source file path
   * @param start - Beginning line number
   * @param startCol - Beginning column position
   * @param end - Concluding line number
   * @param endCol - Concluding column position
   */
  predicate hasLocationInfo(
    string file, int start, int startCol, int end, int endCol
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(file, start, startCol, end, endCol)
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
    // Confirm comment adheres to noqa specification
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
   * @param file - Source file path
   * @param start - Beginning line number
   * @param startCol - Beginning column position (line start)
   * @param end - Concluding line number
   * @param endCol - Concluding column position
   */
  override predicate covers(
    string file, int start, int startCol, int end, int endCol
  ) {
    // Acquire comment coordinates and enforce line-start coverage
    this.hasLocationInfo(file, start, _, end, endCol) and
    startCol = 1
  }
}