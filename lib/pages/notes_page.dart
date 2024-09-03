import 'package:flutter/material.dart';
import 'package:notes/models/note_database.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:notes/models/note.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/component/drawer.dart';
import 'package:notes/component/note_settings.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readNotes();
  }

  void createNote() {
    textController.clear(); // Ensure the text is cleared before creating a new note

    showDialog(
      context: context,
      builder: (context) {
        // Set initial height for the TextField
        int lineCount = 1;
        double initialHeight = lineCount * 24.0; // Estimate 24.0 height per line

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: const Text('Create Note'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: initialHeight,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your note',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    controller: textController,
                    maxLines: null, // Allows the TextField to expand vertically
                    onChanged: (text) {
                      setState(() {
                        lineCount = '\n'.allMatches(text).length + 1;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    context.read<NoteDatabase>().addNote(textController.text);
                    textController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  void updateNote(Note note) {
    textController.text = note.text;
    // Set the cursor to the end of the text
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    showDialog(
      context: context,
      builder: (context) {
        // Calculate the initial height based on the content
        int lineCount = '\n'.allMatches(textController.text).length + 1;
        double initialHeight = lineCount * 24.0; // Estimate 24.0 height per line

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: const Text('Update Note'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: initialHeight,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: textController,
                    maxLines: null, // Allows the TextField to expand vertically
                    onChanged: (text) {
                      setState(() {
                        lineCount = '\n'.allMatches(text).length + 1;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    context.read<NoteDatabase>().updateNotes(note.id, textController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteNote(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () {
                context.read<NoteDatabase>().deleteNotes(id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<NoteDatabase>();

    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          createNote();
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.inversePrimary),
      ),

      drawer: const MyDrawer(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Notes",
              style: GoogleFonts.dmSerifText(
                fontSize: 40,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: currentNotes.isEmpty
                ? const Center(
              child: Text('No notes yet'),
            )
                : ListView.builder(
              itemCount: currentNotes.length,
              itemBuilder: (context, index) {
                final note = currentNotes[index];
                return Container(
                  margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(note.text, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.inversePrimary),
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),

                          ),

                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ];
                      },
                      onSelected: (value) {
                        if (value == 'edit') {
                          updateNote(note);
                        } else if (value == 'delete') {
                          deleteNote(note.id);
                        }
                      },
                    ),

                    // trailing: Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     IconButton(
                    //       icon: const Icon(Icons.edit),
                    //       onPressed: () => updateNote(note),
                    //     ),
                    //     IconButton(
                    //       icon: const Icon(Icons.delete),
                    //       onPressed: () {
                    //         deleteNote(note.id);
                    //       },
                    //     ),
                    //   ],
                    // ),
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}