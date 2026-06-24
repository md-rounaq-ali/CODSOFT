// Quote model
class Quote {
  final String text;
  final String author;
  final String category;

  const Quote({
    required this.text,
    required this.author,
    required this.category,
  });

  String serialize() => '$text|||$author|||$category';

  static Quote? deserialize(String data) {
    final parts = data.split('|||');
    if (parts.length == 3) {
      return Quote(text: parts[0], author: parts[1], category: parts[2]);
    }
    return null;
  }

  String toShareText() =>
      '"$text"\n\n— $author\n\n#QuoteOfTheDay #DQuotes #Motivation';

  @override
  bool operator ==(Object other) =>
      other is Quote && other.text == text && other.author == author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}

// All quotes database
const List<Quote> allQuotes = [
  // Motivation
  Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "Motivation"),
  Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: "Motivation"),
  Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", category: "Motivation"),
  Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair", category: "Motivation"),
  Quote(text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis", category: "Motivation"),
  Quote(text: "Push yourself, because no one else is going to do it for you.", author: "Unknown", category: "Motivation"),
  Quote(text: "Great things never come from comfort zones.", author: "Unknown", category: "Motivation"),
  // Wisdom
  Quote(text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein", category: "Wisdom"),
  Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu", category: "Wisdom"),
  Quote(text: "Knowing yourself is the beginning of all wisdom.", author: "Aristotle", category: "Wisdom"),
  Quote(text: "The unexamined life is not worth living.", author: "Socrates", category: "Wisdom"),
  Quote(text: "Yesterday is history, tomorrow is a mystery, today is a gift.", author: "Alice Morse Earle", category: "Wisdom"),
  Quote(text: "Life is what happens when you're busy making other plans.", author: "John Lennon", category: "Wisdom"),
  // Success
  Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain", category: "Success"),
  Quote(text: "I have not failed. I've just found 10,000 ways that won't work.", author: "Thomas Edison", category: "Success"),
  Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson", category: "Success"),
  Quote(text: "Whether you think you can or you can't, you're right.", author: "Henry Ford", category: "Success"),
  Quote(text: "Success is the sum of small efforts repeated day in and day out.", author: "Robert Collier", category: "Success"),
  Quote(text: "The best time to plant a tree was 20 years ago. The second best is now.", author: "Chinese Proverb", category: "Success"),
  // Courage
  Quote(text: "Courage is not the absence of fear, but the triumph over it.", author: "Nelson Mandela", category: "Courage"),
  Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky", category: "Courage"),
  Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela", category: "Courage"),
  Quote(text: "Do one thing every day that scares you.", author: "Eleanor Roosevelt", category: "Courage"),
  Quote(text: "Strength does not come from winning. Your struggles develop your strengths.", author: "Arnold Schwarzenegger", category: "Courage"),
  // Happiness
  Quote(text: "Happiness is not something ready made. It comes from your own actions.", author: "Dalai Lama", category: "Happiness"),
  Quote(text: "The purpose of our lives is to be happy.", author: "Dalai Lama", category: "Happiness"),
  Quote(text: "Spread love everywhere you go. Let no one come to you without leaving happier.", author: "Mother Teresa", category: "Happiness"),
  Quote(text: "Count your age by friends, not years. Count your life by smiles, not tears.", author: "John Lennon", category: "Happiness"),
  Quote(text: "Joy is the simplest form of gratitude.", author: "Karl Barth", category: "Happiness"),
  // Growth
  Quote(text: "An investment in knowledge pays the best interest.", author: "Benjamin Franklin", category: "Growth"),
  Quote(text: "The more that you read, the more things you will know.", author: "Dr. Seuss", category: "Growth"),
  Quote(text: "Develop a passion for learning. If you do, you will never cease to grow.", author: "Anthony J. D'Angelo", category: "Growth"),
  Quote(text: "We cannot become what we want by remaining what we are.", author: "Max DePree", category: "Growth"),
  Quote(text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "Mahatma Gandhi", category: "Growth"),
  Quote(text: "Education is the most powerful weapon which you can use to change the world.", author: "Nelson Mandela", category: "Growth"),
];

const List<String> categories = [
  'All', 'Motivation', 'Wisdom', 'Success', 'Courage', 'Happiness', 'Growth'
];
