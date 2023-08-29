import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _streamController = StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _streamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await ensureDbIsOpen();
    try {
      return await getUser(email: email);
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _streamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();

    // make sure the note exists
    await getNote(id: note.id);

    // update db
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _streamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _streamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _streamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _streamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';

    // create note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      syncWithCloud: true,
    );

    _notes.add(note);
    _streamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDAtabaseOrThrow();
    final deleteAccount = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deleteAccount != null) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDAtabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
//    create user table
      db.execute(createUserTable);
//    create note table
      db.execute(createNoteTable);
      await _cachedNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool syncWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.syncWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        syncWithCloud = (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncWithCloud = $syncWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncWithCloudColumn = "is_synced_with_cloud";
const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user"(
          "id" INTEGER NOT NULL,
          "email" TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
        )
      ''';
const createNoteTable = '''
        CREATE TABLE IF NOT EXISTS "note"(
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "text" TEXT,
          "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY("user_id") REFERENCES "user"("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        )
      ''';
