/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import required modules for alert suppression and comment processing
private import codeql.util.suppression.AlertSuppression as AlertSuppressionModule
private import semmle.python.Comment as CommentModule

// Define a class representing abstract syntax tree nodes in Python code
class PythonAstNode instanceof CommentModule::AstNode {
  /** Retrieve location information for the syntax node (file path and line/column range) */
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Delegate to parent class method for location retrieval
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  /** Return string representation of the syntax node */
  string toString() { result = super.toString() }
}

// Define a class representing single-line comments in Python code
class SingleLineComment instanceof CommentModule::Comment {
  /** Retrieve location information for the comment (file path and line/column range) */
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Delegate to parent class method for location retrieval
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  /** Retrieve the text content of the comment */
  string getText() { result = super.getContents() }

  /** Return string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply template to generate suppression relationships between AST nodes and single-line comments
import AlertSuppressionModule::Make<PythonAstNode, SingleLineComment>

/**
 * Pylint and Pyflakes compatible noqa suppression comments
 * These comments should be recognized by LGTM analyzer
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Constructor: Validate if the comment conforms to noqa format */
  NoqaStyleSuppressor() {
    // Check if comment text matches noqa format (case-insensitive, allowing leading/trailing spaces)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Return the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Define the code range covered by the suppression comment */
  override predicate covers(
    string sourcePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Ensure comment is at the beginning of a line and location information matches
    this.hasLocationInfo(sourcePath, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}