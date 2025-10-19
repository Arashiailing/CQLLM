/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import AlertSuppression module for handling alert suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import Python comment processing utilities for AST analysis
private import semmle.python.Comment as PythonComment

/**
 * Represents a Python AST node with enhanced location tracking.
 * Wraps the base AstNode to provide standardized location access.
 */
class CodeNode instanceof PythonComment::AstNode {
  /**
   * Provides location details for the AST node.
   * @param file Source file path containing the node
   * @param sLine Starting line number of the node
   * @param sCol Starting column number of the node
   * @param eLine Ending line number of the node
   * @param eCol Ending column number of the node
   */
  predicate hasLocationInfo(
    string file, int sLine, int sCol, int eLine, int eCol
  ) {
    // Delegate to base class for location information
    super.getLocation().hasLocationInfo(file, sLine, sCol, eLine, eCol)
  }

  /**
   * Returns string representation of the AST node.
   * @return Textual representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a Python single-line comment with location and content access.
 * Extends base Comment with standardized interface.
 */
class LineComment instanceof PythonComment::Comment {
  /**
   * Provides location details for the comment.
   * @param file Source file path containing the comment
   * @param sLine Starting line number of the comment
   * @param sCol Starting column number of the comment
   * @param eLine Ending line number of the comment
   * @param eCol Ending column number of the comment
   */
  predicate hasLocationInfo(
    string file, int sLine, int sCol, int eLine, int eCol
  ) {
    // Delegate to base class for location information
    super.getLocation().hasLocationInfo(file, sLine, sCol, eLine, eCol)
  }

  /**
   * Retrieves the textual content of the comment.
   * @return Raw text content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Returns string representation of the comment.
   * @return Textual representation of the comment
   */
  string toString() { result = super.toString() }
}

// Apply AlertSuppression template to establish suppression relationships
import AlertSuppression::Make<CodeNode, LineComment>

/**
 * Represents a noqa suppression comment in Python code.
 * Recognized by both pylint and pyflakes tools, and processed by LGTM.
 * Combines SuppressionComment and LineComment behaviors.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof LineComment {
  /**
   * Constructs a NoqaSuppressionComment instance.
   * Validates comment matches noqa pattern (case-insensitive).
   */
  NoqaSuppressionComment() {
    // Check for noqa pattern in comment text (case-insensitive)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for suppression.
   * @return Standardized "lgtm" annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression.
   * @param file Source file path containing covered code
   * @param sLine Starting line number of covered code
   * @param sCol Starting column number of covered code
   * @param eLine Ending line number of covered code
   * @param eCol Ending column number of covered code
   */
  override predicate covers(
    string file, int sLine, int sCol, int eLine, int eCol
  ) {
    // Validate comment location and ensure line-start alignment
    this.hasLocationInfo(file, sLine, _, eLine, eCol) and
    sCol = 1
  }
}