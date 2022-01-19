import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  final ValueNotifier<int> selected = ValueNotifier(-1);

  final Map<String, String> questions = {
    "Question 1": "Answer 1",
    "new text": "Answer 2",
    "Question 3": "Answer 3",
    "Question 4": "Answer 4",
    "Question 5": "Answer 5",
    "Question 6": "Answer 6",
    "Question 7": "Answer 7",
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              children: [
                InkResponse(
                  child: Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Spacer(),
                Text(
                  'FAQ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              itemCount: questions.length,
              itemBuilder: (context, index) => questionCard(index),
            ),
          )
        ],
      ),
    );
  }

  Widget questionCard(index) => ValueListenableBuilder(
      valueListenable: selected,
      builder: (context, selectedIndex, _) {
        bool isSelected = selectedIndex == index;
        return InkWell(
          onTap: () => isSelected ? selected.value = -1 : selected.value = index,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 5),
                    Container(
                      child: Text(
                        questions.keys.elementAt(index),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(isSelected ? Icons.expand_less : Icons.expand_more),
                    SizedBox(width: 5),
                  ],
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(
                      questions.values.elementAt(index),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 17,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        );
      });
}
