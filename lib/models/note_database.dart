import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:notes/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar _isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([NoteSchema] , directory: dir.path
    );
  }

  final List<Note> currentNotes = [];

  Future<void> addNote(String textFromUser) async {
    final newNote = Note()..text = textFromUser;
    await _isar.writeTxn(() => _isar.notes.put(newNote));
    await fetchNotes();
  }

  Future<void> fetchNotes() async {
    List<Note> fetchNotes = await _isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchNotes);
    notifyListeners();
  }

  Future<void> updateNotes(int id, String newText) async {
    final existingNote = await _isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await _isar.writeTxn(() => _isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  Future<void> deleteNotes(int id) async {
    await _isar.writeTxn(() => _isar.notes.delete(id));
    await fetchNotes();
  }
}