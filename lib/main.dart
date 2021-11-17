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

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _lastWords = '';
    myLock = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

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

  String entireQuestion(String question) {
    if (question.contains("depuis quand") &&
        question.contains("conservateur") &&
        (question.contains("sans") || question.contains("aucun"))) {
      return ("Depuis 20 ans, nous veillons à ne pas ajouter de conservateurs dans nos plats cuisinés dès que les recettes nous le permettent. Mais c'est depuis 2002 que nous travaillons avec nos fournisseurs pour supprimer les conservateurs dans les ingrédients. Aujourd'hui 94% de nos plats cuisinés ne contiennent aucun conservateur. Ne soyez pas timide, allez plutôt les tester par vous-mêmes.");
    }
    if (question.contains("manger") && question.contains("moins")) {
      if (question.contains("salé")) {
        return ("Il est possible de s'habituer progressivement à manger moins salé en jouant avec les épices (poivre, curry, curcuma, clous de girofle...) et les herbes aromatiques (thym, ciboulette...). Et pour être sûr de ne pas dépasser la juste dose, nous vous conseillons de saler en fin de cuisson plutôt qu'au début ! Ces efforts paieront rapidement car il suffit de 3 semaines pour que les papilles s'habituent à un goût moins salé, juste le temps pour elles de se regénérer.");
      }
    }
    return ("");
  }

  String getAnswer(String question) {
    String tmp = question.toLowerCase();
    String result = entireQuestion(tmp);
    if (result != "") return result;
    if (tmp == "oui") result = "fi";
    if (tmp == "aide" || (tmp.contains("j") && tmp.contains("aide"))) {
      result = "Aide:\nPoser vos questions en les tapant / dictant";
    }
    if (tmp.contains("respect") || tmp.contains("souci")) {
      if (tmp.contains("anima")) {
        result =
            "La priorité numéro 1 de nos équipes est de les traiter avec respect.";
      }
      if (tmp.contains("planète") ||
          tmp.contains("planete") ||
          tmp.contains("environ")) {
        result =
            "Bien évidemment, notre environnement doit être préservé à tout prix !";
      }
    }
    if (tmp.contains("périmé") ||
        tmp.contains("perime") ||
        tmp.contains("peremption")) {
      result =
          "Un prduit périmé ? regarder notre charte des produits \"dépassé\" pour en savoir plus sur comment les dlc sont établies !";
    }
    if (tmp.contains("salut") ||
        tmp.contains("bonjour") ||
        tmp == "yo" ||
        tmp.contains("yo ")) {
      result = "Bonjour, en quoi puis-je vous aider ?";
    }
    return (result == ""
        ? "Désolé je n'ai pas compris, veuillez répéter"
        : result);
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
          child: Container(
            child: Text(index % 2 == 0 ? actQandA : ''),
            padding: const EdgeInsets.all(8),
            decoration: getBox(index % 2 == 0),
          ),
          alignment: Alignment.centerLeft,
        ),
        Container(
          width: (index % 2 != 0
                  ? MediaQuery.of(context).size.width / 3 * 2
                  : MediaQuery.of(context).size.width / 3) -
              10,
          padding: index % 2 != 0
              ? const EdgeInsets.fromLTRB(10, 5, 10, 5)
              : const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Container(
            child: Text(index % 2 != 0 ? actQandA : ''),
            padding: const EdgeInsets.all(8),
            decoration: getBox(index % 2 != 0),
          ),
          alignment: Alignment.centerRight,
        ),
        Container(
          width: 10,
        ),
      ],
    );
  }
}
