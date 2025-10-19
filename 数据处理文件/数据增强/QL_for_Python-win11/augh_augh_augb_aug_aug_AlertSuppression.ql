/**
 * @name Alert suppression
 * @description Detects and evaluates alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's AlertSuppression module for managing suppression functionality
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// Import Python comment processing module for handling code annotations
private import semmle.python.Comment as CommentHandler

// Represents an abstract syntax tree node within Python source code
class CodeElement instanceof CommentHandler::AstNode {
  /** Provides a string representation of the code element */
  string toString() { result = super.toString() }

  /** Checks if the element contains the specified location details */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Obtain location information by invoking the parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Represents a single-line comment in Python source code
class LineComment instanceof CommentHandler::Comment {
  /** Obtains the text content of the comment */
  string getText() { result = super.getContents() }

  /** Provides a string representation of the comment */
  string toString() { result = super.toString() }

  /** Checks if the comment contains the specified location details */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Obtain location information by invoking the parent class method
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }
}

// Generate suppression relationships between code elements and line comments using template
import SuppressionUtil::Make<CodeElement, LineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression comments
 * LGTM analyzer should recognize these comments
 */
class NoqaStyleSuppression extends SuppressionComment instanceof LineComment {
  /** Provides the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Specifies the code range covered by the comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify the comment is at the beginning of a line and location information matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }

  /** Constructor: Validates if the comment follows noqa format */
  NoqaStyleSuppression() {
    // Check if the comment text conforms to noqa format (case-insensitive, allowing leading/trailing spaces)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}