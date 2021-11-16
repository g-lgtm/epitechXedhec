import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool myLock = false;
  static List<String> allQandA = [];
  final ScrollController _scrollController = ScrollController();
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _text.clear();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    _lastWords = '';
    myLock = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (_speechToText.isNotListening && myLock) {
        if (_lastWords.length <= 2) return;
        allQandA.insert(0, _lastWords);
        allQandA.insert(0, getAnswer(_lastWords));
        myLock = false;
        _lastWords = '';
      }
    });
  }

  void _emplaceText() {
    setState(() {
      allQandA.insert(0, _text.text);
      allQandA.insert(0, getAnswer(_text.text));
      _text.clear();
    });
  }

  String getAnswer(String question) {
    if (question == "oui") return ("fi");
    if (question.toLowerCase().contains("jambon"))
      return ("Nos produits sont controlés et certifié français :)");
    return ("Désolé je n'ai pas compris votre question. Pouvez vous répéter ?");
  }

  _scrollToEnd() async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent + 10,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
    return Scaffold(
        appBar: AppBar(
          title: const Text('HamBot'),
          centerTitle: true,
        ),
        body: ListView(
          controller: _scrollController,
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                ..._getTexts(allQandA),
                const SizedBox(
                  height: 50,
                )
              ],
            )),
          ],
        ),
        bottomSheet: Container(
          margin: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 70,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 5),
                child: TextField(
                  controller: _text,
                  onChanged: (useless) {
                    setState(() {});
                  },
                  onSubmitted: (useless) {
                    _emplaceText();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Entrez votre question ici',
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.only(left: 5),
                child: IconButton(
                    onPressed: _text.text == ""
                        ? (_speechToText.isNotListening
                            ? _startListening
                            : null)
                        : _emplaceText,
                    icon: Icon(_text.text == ""
                        ? (_speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic)
                        : Icons.send)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.blue[200]),
              )
            ],
          ),
        ));
  }
}

List<Widget> _getTexts(allQandA) {
  List<Widget> allQandATextFields = [];
  for (int i = allQandA.length - 1; i >= 0; i--) {
    allQandATextFields.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: AllQandATextFields(i, allQandA[i])),
        ],
      ),
    ));
  }
  return allQandATextFields;
}

class AllQandATextFields extends StatelessWidget {
  final int index;
  final String actQandA;
  AllQandATextFields(this.index, this.actQandA);

  BoxDecoration getBox(bool isSentence) {
    BoxDecoration result = BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.1));
    if (isSentence) return result;
    result = const BoxDecoration(border: Border());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
        ),
        Container(
          width: (index % 2 == 0
                  ? MediaQuery.of(context).size.width / 3 * 2
                  : MediaQuery.of(context).size.width / 3) -
              10,
          padding: index % 2 == 0
              ? const EdgeInsets.fromLTRB(10, 5, 10, 5)
              : const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(index % 2 == 0 ? actQandA : ''),
          decoration: getBox(index % 2 == 0),
        ),
        Container(
          width: (index % 2 != 0
                  ? MediaQuery.of(context).size.width / 3 * 2
                  : MediaQuery.of(context).size.width / 3) -
              10,
          padding: index % 2 != 0
              ? const EdgeInsets.fromLTRB(10, 5, 10, 5)
              : const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(index % 2 == 0 ? '' : actQandA),
          alignment: Alignment.centerRight,
          decoration: getBox(index % 2 != 0),
        ),
        Container(
          width: 10,
        ),
      ],
      // Container(
      // child: Text(actQandA),
      // decoration: BoxDecoration(border: Border.all()),
    );
  }
}
