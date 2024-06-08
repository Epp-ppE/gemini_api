import 'package:flutter/material.dart';
import 'package:gemini_api/widgets/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: "AIzaSyA60WSsvU6s3CiwB9H52PRIcAuejKSDLms"
    );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Generative AI Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            // fontWeight: FontWeight.bold
          )
        ),
        // make title center
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatSession.history.length,
              itemBuilder: (context, index) {
                debugPrint('building item $index...');
                final Content content = _chatSession.history.toList()[index];
                final texts = content.parts.whereType<TextPart>().map<String>((e) => e.text).join('');
                return MessageWidget(
                  text: texts, 
                  isFromUser: content.role == 'user'
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    focusNode: _textFieldFocus,
                    decoration: textFieldDecoration(),
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  )  
                ),
                InkWell(
                  onTap: () => _sendChatMessage(_textController.text),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    // decoration: BoxDecoration(
                    //   color: Theme.of(context).colorScheme.primary,
                    //   borderRadius: BorderRadius.circular(15)
                    // ),
                    child: _loading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        )
                      : Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        )
                  )
                )
              ]
            )
          )
        ],
      )
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty) {
      // Do not send the message if it is empty or contains only whitespace
      return;
    }

    setState((){
      debugPrint('setting state to loading...');
      _loading = true;
    });

    try {
      debugPrint('entering try block...');
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      debugPrint('got response...');
      if (text == null){
        debugPrint('text is null...');
        _showError('No response from API.');
        return;
      } else {
        debugPrint('text is not null...');
        debugPrint(text);
        setState(() {
          debugPrint('setting state to loading...');
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: "Enter a prompt...",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2
        )
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2
        )
      ),

    );
  }

  void _showError(String message) {
    debugPrint('showing error...');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong!'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK')
            )
          ]
        );
      }
      
    );
  }

  void _scrollDown() {
    debugPrint('entering scroll down...');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOut
      )
    );
  }
}