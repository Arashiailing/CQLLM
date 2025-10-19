/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's AlertSuppression module for handling suppression logic
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// Import Python comment processing module for analyzing code comments
private import semmle.python.Comment as CommentProcessor

// Define a source code node class representing AST nodes in Python code
class SourceCodeNode instanceof CommentProcessor::AstNode {
  /** Provides string representation of the node */
  string toString() { result = super.toString() }

  /** Determines if the node has the specified location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve location information by calling parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Define a single-line comment class representing Python comments
class SingleLineComment instanceof CommentProcessor::Comment {
  /** Retrieves the text content of the comment */
  string getText() { result = super.getContents() }

  /** Returns string representation of the comment */
  string toString() { result = super.toString() }

  /** Determines if the comment has the specified location information */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve location information by calling parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Generate suppression relationships between source code nodes and single-line comments using template
import SuppressionUtil::Make<SourceCodeNode, SingleLineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression comments
 * LGTM analyzer should recognize these comments
 */
class NoqaSuppression extends SuppressionComment instanceof SingleLineComment {
  /** Returns the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range covered by the comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment is at the beginning of a line and location information matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }

  /** Constructor: Validates if the comment conforms to noqa format */
  NoqaSuppression() {
    // Check if comment text matches noqa format (case-insensitive, allowing surrounding whitespace)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}