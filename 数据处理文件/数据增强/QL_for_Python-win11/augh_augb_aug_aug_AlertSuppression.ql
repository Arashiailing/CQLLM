/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's AlertSuppression module for handling suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// Import Python comment processing module for handling code annotations
private import semmle.python.Comment as CommentProcessor

// Represents an abstract syntax tree node in Python source code
class SourceCodeNode instanceof CommentProcessor::AstNode {
  /** Provides a string representation of the code node */
  string toString() { result = super.toString() }

  /** Determines if the node has the specified location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve location information by calling the parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Represents a single-line comment in Python source code
class SingleLineComment instanceof CommentProcessor::Comment {
  /** Retrieves the text content of the comment */
  string getText() { result = super.getContents() }

  /** Provides a string representation of the comment */
  string toString() { result = super.toString() }

  /** Determines if the comment has the specified location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve location information by calling the parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Generate suppression relationships between code nodes and single-line comments using template
import AlertSuppressionUtil::Make<SourceCodeNode, SingleLineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression comments
 * LGTM analyzer should recognize these comments
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /** Returns the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range covered by the comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure the comment is at the beginning of a line and location information matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }

  /** Constructor: Validates if the comment conforms to noqa format */
  NoqaSuppressionComment() {
    // Check if the comment text matches noqa format (case-insensitive, allowing leading/trailing spaces)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}