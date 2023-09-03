import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NoteService {
  Database? _db;

  // update an existing note
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNoteUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  // Get all notes from note table
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    final result = notes.map((e) => DatabaseNote.fromRow(e));

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return result;
    }
  }

  // Get a note using id
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  // Delete all notes from note table
  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);
    return deletedCount;
  }

  // Delete a note of an owner
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  // Create a note for a user
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // To make sure owner exister with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    // Create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  // Get a user
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  // Create a new user if not exists
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final id = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: id,
      email: email,
    );
  }

  // Delete a User
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email= ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // Get Database if connection is open
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  // Fun to open database connection
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create User Table
      db.execute(createUserTable);

      //Create Note Table
      db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  // Function to close Database connection
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person Id= $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, Id= $id, userId= $userId, isSyncedWithClout= $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailColumn = 'email';
const userIdColumn = "user_id";
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
            "id"	INTEGER,
            "email"	TEXT NOT NULL,
            PRIMARY KEY("id" AUTOINCREMENT)
          );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER,
        "user_id"	INTEGER NOT NULL,
        "note"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
