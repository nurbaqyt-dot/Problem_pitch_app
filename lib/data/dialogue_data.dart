import '../models/dialogue.dart';

const dialogueCatalog = <DialogueScenario>[
  DialogueScenario(
    id: 'greetings_chat',
    lessonId: 'greetings',
    title: 'Meet Aida',
    description: 'Practice greeting a local and answering simple questions.',
    nodes: [
      DialogueNode(
        id: 'start',
        speaker: DialogueSpeaker.local,
        text: 'Salem! Qalaisyn?',
        translation: 'Hello! How are you?',
        pronunciation: 'Sa-lem! Qa-lai-syn',
        choices: [
          DialogueChoice(
            id: 'good',
            label: 'Men zhaqsymyn',
            translation: 'I am good',
            nextNodeId: 'name_prompt',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'thanks',
            label: 'Rahmet',
            translation: 'Thank you',
            nextNodeId: 'start_retry',
            feedback:
                'That phrase is polite, but here you need to answer how you are.',
          ),
          DialogueChoice(
            id: 'hello',
            label: 'Salem',
            translation: 'Hello',
            nextNodeId: 'start_retry',
            feedback: 'Good greeting, but Aida already said hello first.',
          ),
        ],
      ),
      DialogueNode(
        id: 'start_retry',
        speaker: DialogueSpeaker.local,
        text: 'You are close. Try answering with "I am good."',
        translation: 'Answer the question before moving on.',
        nextNodeId: 'start',
        actionLabel: 'Try again',
      ),
      DialogueNode(
        id: 'name_prompt',
        speaker: DialogueSpeaker.local,
        text: 'Keremet! Men Aida. Sening atyn kim?',
        translation: 'Great! I am Aida. What is your name?',
        pronunciation: 'Ke-re-met! Men Ai-da. Se-ning a-tyn kim',
        choices: [
          DialogueChoice(
            id: 'my_name',
            label: 'Menin atym Samat',
            translation: 'My name is Samat',
            nextNodeId: 'end',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'excuse_me',
            label: 'Keshiriniz',
            translation: 'Excuse me',
            nextNodeId: 'name_retry',
            feedback: 'Useful phrase, but now you should introduce yourself.',
          ),
          DialogueChoice(
            id: 'goodbye',
            label: 'Sau bol',
            translation: 'Goodbye',
            nextNodeId: 'name_retry',
            feedback: 'Too early to leave. First, say your name.',
          ),
        ],
      ),
      DialogueNode(
        id: 'name_retry',
        speaker: DialogueSpeaker.local,
        text: 'Aida is asking for your name.',
        translation: 'Use the pattern "Menin atym..."',
        nextNodeId: 'name_prompt',
        actionLabel: 'Retry',
      ),
      DialogueNode(
        id: 'end',
        speaker: DialogueSpeaker.local,
        text: 'Tanysqanyma quanyshtymyn!',
        translation: 'Nice to meet you!',
        pronunciation: 'Ta-nys-qa-ny-ma qua-nush-ty-myn',
      ),
    ],
  ),
  DialogueScenario(
    id: 'basic_phrases_chat',
    lessonId: 'basic_phrases',
    title: 'Market Mini Talk',
    description: 'Use polite basics while buying something small.',
    nodes: [
      DialogueNode(
        id: 'start',
        speaker: DialogueSpeaker.local,
        text: 'Salem! Sizge komek kerek pe?',
        translation: 'Hello! Do you need help?',
        pronunciation: 'Salem! Siz-ge ko-mek ke-rek pe',
        choices: [
          DialogueChoice(
            id: 'yes',
            label: 'Ia',
            translation: 'Yes',
            nextNodeId: 'price_prompt',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'thanks',
            label: 'Rahmet',
            translation: 'Thank you',
            nextNodeId: 'start_retry',
            feedback: 'Polite, but first answer yes or no.',
          ),
          DialogueChoice(
            id: 'no',
            label: 'Zhoq',
            translation: 'No',
            nextNodeId: 'no_branch',
            feedback:
                'That answer is understandable, but this practice path needs "Yes."',
          ),
        ],
      ),
      DialogueNode(
        id: 'start_retry',
        speaker: DialogueSpeaker.local,
        text: 'Try a simple yes or no answer first.',
        translation: 'Use "Ia" if you want help.',
        nextNodeId: 'start',
        actionLabel: 'Retry',
      ),
      DialogueNode(
        id: 'no_branch',
        speaker: DialogueSpeaker.local,
        text: 'Zharai-dy. Biraq bugingi practice-ta komek suraiyk.',
        translation: 'That is fine, but in this practice let\'s ask for help.',
        nextNodeId: 'start',
        actionLabel: 'Try the help route',
      ),
      DialogueNode(
        id: 'price_prompt',
        speaker: DialogueSpeaker.local,
        text: 'Mine, su. Ne dep suraisyz?',
        translation: 'Here is water. What do you ask next?',
        pronunciation: 'Mi-ne, su. Ne dep su-raiy-syz',
        choices: [
          DialogueChoice(
            id: 'how_much',
            label: 'Qansha turady?',
            translation: 'How much is it?',
            nextNodeId: 'end',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'dont_understand',
            label: 'Men tusinbeimin',
            translation: 'I do not understand',
            nextNodeId: 'price_retry',
            feedback: 'Helpful phrase, but here you want the price.',
          ),
          DialogueChoice(
            id: 'thanks',
            label: 'Rahmet',
            translation: 'Thank you',
            nextNodeId: 'price_retry',
            feedback: 'You can thank them after asking how much it costs.',
          ),
        ],
      ),
      DialogueNode(
        id: 'price_retry',
        speaker: DialogueSpeaker.local,
        text: 'Now ask for the price.',
        translation: 'Use the phrase for "How much is it?"',
        nextNodeId: 'price_prompt',
        actionLabel: 'Ask again',
      ),
      DialogueNode(
        id: 'end',
        speaker: DialogueSpeaker.local,
        text: '100 tenge. Rahmet!',
        translation: '100 tenge. Thank you!',
        pronunciation: 'Bir juz ten-ge. Rah-met',
      ),
    ],
  ),
  DialogueScenario(
    id: 'food_restaurant_chat',
    lessonId: 'food_restaurant',
    title: 'Cafe Order',
    description: 'Order tea, react politely, and ask for the bill.',
    nodes: [
      DialogueNode(
        id: 'start',
        speaker: DialogueSpeaker.local,
        text: 'Qosh keldiniz! Ne alasiz?',
        translation: 'Welcome! What would you like?',
        pronunciation: 'Qosh kel-di-niz! Ne a-la-syz',
        choices: [
          DialogueChoice(
            id: 'tea',
            label: 'Bir shai, otinemin',
            translation: 'One tea, please',
            nextNodeId: 'taste_prompt',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'menu',
            label: 'Menyu',
            translation: 'Menu',
            nextNodeId: 'menu_branch',
            feedback:
                'Reasonable choice, but this practice focuses on ordering tea directly.',
          ),
          DialogueChoice(
            id: 'bill',
            label: 'Esepti, otinemin',
            translation: 'The bill, please',
            nextNodeId: 'bill_too_soon',
            feedback: 'That comes at the end of the meal.',
          ),
        ],
      ),
      DialogueNode(
        id: 'menu_branch',
        speaker: DialogueSpeaker.local,
        text: 'Menyu munda. Endi susyn dyrys taqdap kor.',
        translation: 'The menu is here. Now try choosing the drink directly.',
        nextNodeId: 'start',
        actionLabel: 'Order now',
      ),
      DialogueNode(
        id: 'bill_too_soon',
        speaker: DialogueSpeaker.local,
        text: 'Ali tamaq kelgen zhoq. Almen tapsyrys bereik.',
        translation:
            'Your food has not arrived yet. Let\'s place the order first.',
        nextNodeId: 'start',
        actionLabel: 'Retry order',
      ),
      DialogueNode(
        id: 'taste_prompt',
        speaker: DialogueSpeaker.local,
        text: 'Shai daiyr. Tamak qalai?',
        translation: 'Your tea is ready. How is the food?',
        pronunciation: 'Shai dai-yr. Ta-mak qa-lai',
        choices: [
          DialogueChoice(
            id: 'tasty',
            label: 'Tamak damdi',
            translation: 'The food is tasty',
            nextNodeId: 'end',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'water',
            label: 'Su',
            translation: 'Water',
            nextNodeId: 'taste_retry',
            feedback:
                'That is a useful word, but here you are giving feedback on the meal.',
          ),
          DialogueChoice(
            id: 'thanks',
            label: 'Rahmet',
            translation: 'Thank you',
            nextNodeId: 'taste_retry',
            feedback: 'Polite, but try complimenting the taste first.',
          ),
        ],
      ),
      DialogueNode(
        id: 'taste_retry',
        speaker: DialogueSpeaker.local,
        text: 'Describe the food with the phrase for "tasty."',
        translation: 'Say that the food tastes good.',
        nextNodeId: 'taste_prompt',
        actionLabel: 'Try again',
      ),
      DialogueNode(
        id: 'end',
        speaker: DialogueSpeaker.local,
        text: 'Rahmet! Esepti kerek bolsa, aita beriniz.',
        translation: 'Thank you! If you need the bill, just let me know.',
        pronunciation: 'Rah-met! E-sep-ti ke-rek bol-sa, ai-ta be-ri-niz',
      ),
    ],
  ),
  DialogueScenario(
    id: 'directions_chat',
    lessonId: 'directions',
    title: 'Ask for Directions',
    description:
        'Practice asking where a place is and understanding the reply.',
    nodes: [
      DialogueNode(
        id: 'start',
        speaker: DialogueSpeaker.local,
        text: 'Salem! Qai zherdi izdep zhursiz?',
        translation: 'Hello! What place are you looking for?',
        pronunciation: 'Salem! Qai zher-di iz-dep zhur-siz',
        choices: [
          DialogueChoice(
            id: 'station',
            label: 'Beket qai da?',
            translation: 'Where is the station?',
            nextNodeId: 'turn_prompt',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'hotel',
            label: 'Qonaq ui',
            translation: 'Hotel',
            nextNodeId: 'place_retry',
            feedback: 'You named a place, but try asking the full question.',
          ),
          DialogueChoice(
            id: 'straight',
            label: 'Tike',
            translation: 'Straight',
            nextNodeId: 'place_retry',
            feedback:
                'That is a direction word, not the question you need here.',
          ),
        ],
      ),
      DialogueNode(
        id: 'place_retry',
        speaker: DialogueSpeaker.local,
        text: 'Ask the full question with "Where is the station?"',
        translation: 'Use the station phrase.',
        nextNodeId: 'start',
        actionLabel: 'Ask again',
      ),
      DialogueNode(
        id: 'turn_prompt',
        speaker: DialogueSpeaker.local,
        text: 'Tike zhuriniz de, sodan kein ne isteisiz?',
        translation: 'Go straight, and then what do you do?',
        pronunciation: 'Ti-ke zhu-ri-niz de, so-dan kei-in ne is-tei-siz',
        choices: [
          DialogueChoice(
            id: 'turn_right',
            label: 'Onga burylynyz',
            translation: 'Turn right',
            nextNodeId: 'end',
            isCorrect: true,
          ),
          DialogueChoice(
            id: 'turn_left',
            label: 'Solga',
            translation: 'Left',
            nextNodeId: 'turn_retry',
            feedback:
                'Close, but the local said the next move is to turn right.',
          ),
          DialogueChoice(
            id: 'hotel',
            label: 'Qonaq ui',
            translation: 'Hotel',
            nextNodeId: 'turn_retry',
            feedback: 'That is a place, but here you need the next direction.',
          ),
        ],
      ),
      DialogueNode(
        id: 'turn_retry',
        speaker: DialogueSpeaker.local,
        text: 'Listen for the next movement instruction.',
        translation: 'The route continues with a right turn.',
        nextNodeId: 'turn_prompt',
        actionLabel: 'Retry',
      ),
      DialogueNode(
        id: 'end',
        speaker: DialogueSpeaker.local,
        text: 'Durys! Beket sondai.',
        translation: 'Correct! The station is there.',
        pronunciation: 'Du-rys! Be-ket son-dai',
      ),
    ],
  ),
];

DialogueScenario? dialogueForLesson(String lessonId) {
  for (final scenario in dialogueCatalog) {
    if (scenario.lessonId == lessonId) {
      return scenario;
    }
  }
  return null;
}
