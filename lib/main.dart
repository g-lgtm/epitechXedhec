import 'dart:io';

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
      title: 'Fleury Michon',
      home: MyHomePage(),
      theme: ThemeData(
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color.fromRGBO(235, 235, 235, 0.96)),
      ),
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
  int isReclam = 0;
  static List<String> allQandA = [
    "Rhttps://www.fleurymichon.fr/manger-mieux/recettes/salade-de-poulet-cesar-ou-filet-de-poulet",
    "RJe vous propose une salade césar avec des émincées de poulet grillées Fleury Michon",
    "Qje dirais légumes",
    "RVous êtes plus: \n- Légume\n- Féculents\n- Les deux",
    "RUne dernière question",
    "QPoulet",
    "RVous êtes plus poulet ou dinde ?",
    "Qnon",
    "RMangez-vous halal ?",
    "Qje suis plus entrée froide",
    "RVous êtes plus:\n- Plats chaud\n- Entrée froide",
    "QJe voudrais une idée gourmande",
    "RBonjour, je suis Hambot ! L'assistant virtuel de Fleury Michon, comment puis-je vous aider ?\n\n- J'ai une question\n- J'ai une réclamation\n- Je voudrais une idée gourmande\n- Je voudrais postuler à un emploi",
  ];
  final ScrollController _scrollController = ScrollController();
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _text.clear();
  }

  void _initSpeech() async {
    // _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _lastWords = '';
    myLock = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    sleep(const Duration(seconds: 1));
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (_speechToText.isNotListening && myLock) {
        if (_lastWords.length <= 2) return;
        allQandA.insert(0, "Q" + _lastWords);
        allQandA.insert(0, "R" + getAnswer(_lastWords));
        myLock = false;
        _lastWords = '';
      }
    });
  }

  void _emplaceText() {
    setState(() {
      allQandA.insert(0, "Q" + _text.text);
      allQandA.insert(0, "R" + getAnswer(_text.text));
      _text.clear();
    });
  }

  String entireQuestion(String question) {
    String finl = "";
    if (question.contains("ai")) {
      if (question.contains("question")) {
        finl = "Quelle est votre question ?";
      } else if (question.contains("reclamation") ||
          question.contains("réclamation")) {
        finl =
            "Vous êtes redirigé vers ce site: https://www.fleurymichon.fr/contact";
      }
    }
    if (question.contains("postul") &&
        (question.contains("emploi") ||
            question.contains("travail") ||
            question.contains("job"))) {
      finl = "https://www.fleurymichon.fr/offre";
    }
    if (question.contains("depuis quand") &&
        question.contains("conservateur") &&
        (question.contains("sans") ||
            question.contains("aucun") ||
            question.contains("retir"))) {
      finl =
          "Depuis 20 ans, nous veillons à ne pas ajouter de conservateurs dans nos plats cuisinés dès que les recettes nous le permettent. Mais c'est depuis 2002 que nous travaillons avec nos fournisseurs pour supprimer les conservateurs dans les ingrédients. Aujourd'hui 94% de nos plats cuisinés ne contiennent aucun conservateur. Ne soyez pas timide, allez plutôt les tester par vous-mêmes.";
    }
    if (question.contains("manger") && question.contains("moins")) {
      if (question.contains("salé")) {
        finl =
            "Il est possible de s'habituer progressivement à manger moins salé en jouant avec les épices (poivre, curry, curcuma, clous de girofle...) et les herbes aromatiques (thym, ciboulette...). Et pour être sûr de ne pas dépasser la juste dose, nous vous conseillons de saler en fin de cuisson plutôt qu'au début ! Ces efforts paieront rapidement car il suffit de 3 semaines pour que les papilles s'habituent à un goût moins salé, juste le temps pour elles de se regénérer.";
      }
    }
    return (finl);
  }

  String getAnswer(String question) {
    String tmp = question.toLowerCase();
    String result = "";
    if (isReclam == 1) {
      isReclam = 2;
      return ("Merci, maintenant il me faudrait votre address mail");
    }
    if (isReclam == 2) {
      isReclam = 3;
      return ("Parfait, maintenant vous pouvez écrire votre message qui sera transferré à notre service réclamation");
    }
    if (isReclam == 3) {
      isReclam = 0;
      return ("Fini\nVous recevrez une réponse sous 3j");
    }
    if (tmp.contains("ai")) {
      if (tmp.contains("question")) {
        result = "Quelle est votre question ?";
      } else if (tmp.contains("reclamation") || tmp.contains("réclamation")) {
        result =
            "Pour toute réclamation je vais avoir besion de votre nom s'il vous plait";
        isReclam = 1;
      }
    }
    if (tmp.contains("postul") &&
        (tmp.contains("emploi") ||
            tmp.contains("travail") ||
            tmp.contains("job"))) {
      result = "https://www.fleurymichon.fr/offre";
    }
    // if (result != "") return result;
    // if (tmp == "oui") result = "fi";
    // if (tmp == "aide" || (tmp.contains("j") && tmp.contains("aide"))) {
    //   result = "Aide:\nPoser vos questions en les tapant / dictant";
    // }
    // if (tmp.contains("respect") || tmp.contains("souci")) {
    //   if (tmp.contains("anima")) {
    //     result =
    //         "La priorité numéro 1 de nos équipes est de les traiter avec respect.";
    //   }
    //   if (tmp.contains("planète") ||
    //       tmp.contains("planete") ||
    //       tmp.contains("environ")) {
    //     result =
    //         "Bien évidemment, notre environnement doit être préservé à tout prix !";
    //   }
    // }
    // if (tmp.contains("périmé") ||
    //     tmp.contains("perime") ||
    //     tmp.contains("peremption")) {
    //   result =
    //       "Un produit périmé ? regarder notre charte des produits \"dépassé\" pour en savoir plus sur comment les dlc sont établies !";
    // }
    // if (tmp.contains("salut") ||
    //     tmp.contains("bonjour") ||
    //     tmp == "yo" ||
    //     tmp.contains("yo ")) {
    //   result = "Bonjour, en quoi puis-je vous aider ?";
    // }
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
            title: SizedBox(
              width: MediaQuery.of(context).size.width / 5 * 3,
              child: Image.asset("assets/logo-fleury-michon.png"),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(0, 129, 62, 1)),
        backgroundColor: const Color.fromRGBO(245, 245, 245, 0.96),
        body: ListView(
          controller: _scrollController,
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(15, 4, 0, 4),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 129, 62, 1),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      boxShadow: kElevationToShadow[4]),
                  child: const Text(
                    'HamBot',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(140, 60, 0, 1),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ..._getTexts(allQandA),
                const SizedBox(
                  height: 60,
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
                            : _stopListening)
                        : _emplaceText,
                    icon: Icon(_text.text == ""
                        ? (_speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic)
                        : Icons.send)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromRGBO(0, 160, 62, 0.9)),
              )
            ],
          ),
        ));
  }
}

bool isItLink(String maybeLink) {
  if (maybeLink.contains("http")) return (true);
  return (false);
}

List<Widget> _getTexts(allQandA) {
  List<Widget> allQandATextFields = [];
  for (int i = allQandA.length - 1; i >= 0; i--) {
    allQandATextFields.add(
      AllQandATextFields(
        actQandA: allQandA[i].substring(1, allQandA[i].length),
        isAnswer: allQandA[i][0] == 'R',
        isLink: isItLink(allQandA[i]),
      ),
    );
  }
  return allQandATextFields;
}

class AllQandATextFields extends StatelessWidget {
  const AllQandATextFields(
      {Key? key,
      required this.actQandA,
      required this.isAnswer,
      required this.isLink})
      : super(key: key);
  final String actQandA;
  final bool isAnswer;
  final bool isLink;
  BoxDecoration getBox(bool isSentence) {
    BoxDecoration result = BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromRGBO(227, 227, 227, 0.9));
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
          width: (isAnswer
                  ? MediaQuery.of(context).size.width / 3 * 2
                  : MediaQuery.of(context).size.width / 3) -
              10,
          padding: isAnswer
              ? const EdgeInsets.fromLTRB(10, 5, 10, 5)
              : const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Container(
            child: Text(
              isAnswer ? actQandA : '',
              style: TextStyle(color: isLink ? Colors.blue : Colors.black),
            ),
            padding: const EdgeInsets.all(8),
            decoration: getBox(isAnswer),
          ),
          alignment: Alignment.centerLeft,
        ),
        Container(
          width: (!isAnswer
                  ? MediaQuery.of(context).size.width / 3 * 2
                  : MediaQuery.of(context).size.width / 3) -
              10,
          padding: !isAnswer
              ? const EdgeInsets.fromLTRB(10, 5, 10, 5)
              : const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Container(
            child: Text(!isAnswer ? actQandA : ''),
            padding: const EdgeInsets.all(8),
            decoration: getBox(!isAnswer),
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
