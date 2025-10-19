/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import required modules for alert suppression and comment processing
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
private import semmle.python.Comment as CommentProcessor

// Define an abstract syntax tree node class representing Python code structure elements
class PythonSyntaxNode instanceof CommentProcessor::AstNode {
  /** Retrieve location information of the node (file path and line/column range) */
  predicate hasLocationInfo(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    // Obtain precise location through parent class method
    super.getLocation().hasLocationInfo(sourceFilePath, lineStart, columnStart, lineEnd, columnEnd)
  }

  /** Return string representation of the node */
  string toString() { result = super.toString() }
}

// Define a single-line comment class representing single-line comment elements in Python code
class PythonSingleLineComment instanceof CommentProcessor::Comment {
  /** Retrieve location information of the comment (file path and line/column range) */
  predicate hasLocationInfo(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    // Obtain precise location through parent class method
    super.getLocation().hasLocationInfo(sourceFilePath, lineStart, columnStart, lineEnd, columnEnd)
  }

  /** Retrieve the text content of the comment */
  string getText() { result = super.getContents() }

  /** Return string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply template to generate suppression relationships between AST nodes and single-line comments
import AlertSuppressionUtil::Make<PythonSyntaxNode, PythonSingleLineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression comments
 * LGTM analyzer should recognize such comments
 */
class NoqaSuppressionComment extends SuppressionComment instanceof PythonSingleLineComment {
  /** Constructor: Validate if the comment conforms to noqa format */
  NoqaSuppressionComment() {
    // Check if comment text matches noqa format (case-insensitive, allowing leading/trailing spaces)
    PythonSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Return the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Define the code range covered by the comment */
  override predicate covers(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    // Ensure comment is at the beginning of a line and location information matches
    this.hasLocationInfo(sourceFilePath, lineStart, _, lineEnd, columnEnd) and
    columnStart = 1
  }
}