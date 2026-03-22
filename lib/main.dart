import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/notes_provider.dart';
import 'providers/linked_notes_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'screens/rich_note_editor_screen.dart';
import 'screens/linked_notes_screen.dart';
import 'services/firestore_service.dart';
import 'models/linked_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
  await NotificationService.init();
  runApp(const MemoraApp());
}

class MemoraApp extends StatelessWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => LinkedNotesProvider()),
      ],
      child: MaterialApp(
        title: 'Memora',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF3E8FF),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFB39DDB),
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _authStream;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Show splash for at least 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((user) {
      if (!mounted) return;
      final notesProvider = context.read<NotesProvider>();
      final linkedProvider = context.read<LinkedNotesProvider>();
      if (user != null) {
        notesProvider.init(user.uid);
        linkedProvider.init(user.uid);
      } else {
        notesProvider.clear();
        linkedProvider.clear();
      }
    });
    NotificationService.onNotificationTap = (noteId, type) async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (type == 'linked') {
        // Fetch the specific linked note by ID and open its detail screen
        final doc = await FirestoreService()
            .linkedNotesStream(user.uid)
            .first
            .then((list) => list.where((n) => n.id == noteId).firstOrNull);
        if (!mounted || doc == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LinkedNoteDetailScreen(note: doc),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RichNoteEditorScreen(noteId: noteId),
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (!_splashDone || snapshot.connectionState != ConnectionState.active) {
          return const SplashScreen();
        }
        if (snapshot.data != null) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}


