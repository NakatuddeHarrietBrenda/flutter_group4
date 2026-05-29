import 'package:flutter/material.dart';

class TheoryQuestion {
  final String id;
  final String question;
  final String shortAnswer;
  final String detailedAnswer;
  final IconData icon;

  TheoryQuestion({
    required this.id,
    required this.question,
    required this.shortAnswer,
    required this.detailedAnswer,
    required this.icon,
  });
}

class StudyGuideScreen extends StatelessWidget {
  const StudyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = [
      TheoryQuestion(
        id: 'Q1',
        question: 'GET vs. POST Requests: What is the difference?',
        shortAnswer: 'GET is for retrieving data (readonly), while POST is for creating or submitting data (mutating state).',
        detailedAnswer: '• GET requests append parameters directly to the URL string (query parameters). They are idempotent and safe for bookmarks and browser caches, meaning they should never modify server state. Example: fetching the NutriBlend perfume catalog.\n\n• POST requests send data within the HTTP request body rather than the URL. They are used for state changes (e.g., submitting a checkout order). Since parameters are not saved in server logs or URL history, POST is significantly more secure for passing private data.',
        icon: Icons.swap_horiz_rounded,
      ),
      TheoryQuestion(
        id: 'Q2',
        question: 'Why do we use Uri.parse() instead of passing a plain string?',
        shortAnswer: 'http.get() requires a structured Uri object, which parses schemes, domains, paths, and handles character encoding safely.',
        detailedAnswer: '• Strong Typing: Dart\'s http package accepts Uri objects instead of plain Strings to enforce robust URL structures.\n\n• URL Encoding: Plain strings containing whitespaces or special characters (like Arabic characters or query values) will cause standard HTTP requests to crash. Uri.parse() automatically sanitizes, encodes (e.g., replacing spaces with %20), and validates the integrity of the endpoint address before sending it over the network wire.',
        icon: Icons.link_rounded,
      ),
      TheoryQuestion(
        id: 'Q3',
        question: 'What does jsonDecode() return in Dart? What is the type?',
        shortAnswer: 'It returns a dynamic representation of JSON, typically parsed into a Map<String, dynamic> or a List<dynamic>.',
        detailedAnswer: '• Dynamic Return: Since the JSON body can be either a single object or an array of objects, jsonDecode() yields a dynamic Dart object.\n\n• Object Mapping: For a product query starting with curly braces {}, it parses to a Map<String, dynamic> (where keys are Strings and values are dynamic objects like nested maps, lists, or primitive integers/doubles).\n\n• List Mapping: For arrays starting with square brackets [], it parses to a List<dynamic>. Models like Product.fromJson map these structures into highly safe, strongly-typed Dart objects.',
        icon: Icons.code_rounded,
      ),
      TheoryQuestion(
        id: 'Q4',
        question: 'What HTTP codes mean success? What do 200 and 201 mean?',
        shortAnswer: '200 means "OK" (successful retrieval), while 210/201 represents "Created" (successful storage creation).',
        detailedAnswer: '• HTTP Status Groups: Codes in the 2xx range denote network success.\n\n• 200 OK: Standard response for successful GET calls, returning requested data. (e.g., loading products).\n\n• 201 Created: The request succeeded and led to the creation of a resource on the backend server. Crucial for verifying POST order checkouts.\n\n• Error contrasts: 4xx codes (like 404 Not Found) indicate client mistakes, while 5xx codes represent backend failure.',
        icon: Icons.check_circle_outline_rounded,
      ),
      TheoryQuestion(
        id: 'Q5',
        question: 'Why should you always add a .timeout() to HTTP requests?',
        shortAnswer: 'To avoid infinite waiting states, save user device battery, and enable clean offline error recovery.',
        detailedAnswer: '• Prevents Deadlocks: On weak mobile connections (e.g., tunnels or rural areas), a server connection can enter an infinite pending state. Without a timeout, a spinner would spin forever, leading to a horrible user experience.\n\n• Clean Diagnostics: Specifying a 10-second timeout allows developers to capture a TimeoutException and alert users with an elegant retry button to refresh the screen, maintaining full control over the application lifecycle.',
        icon: Icons.timer_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        title: const Text(
          'Lesson Notes Hub',
          style: TextStyle(
            color: Color(0xFFF5F5F0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.12),
                  const Color(0xFF1E1E1E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFD4AF37),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'API & STATE ASSESSMENT',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37).withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Month 2 Practice Work',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore highly detailed answers to the Level 1 theory exercises. Tap each luxury card to expand and review complex networking topics.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Question cards
          ...questions.map((q) => _buildQuestionCard(context, q)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, TheoryQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            unselectedWidgetColor: const Color(0xFFD4AF37),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                q.icon,
                color: const Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            title: Text(
              q.question,
              style: const TextStyle(
                color: Color(0xFFF5F5F0),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                q.shortAnswer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
            iconColor: const Color(0xFFD4AF37),
            collapsedIconColor: const Color(0xFFD4AF37).withOpacity(0.7),
            childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.02),
                  ),
                ),
                child: Text(
                  q.detailedAnswer,
                  style: TextStyle(
                    color: const Color(0xFFF5F5F0).withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
