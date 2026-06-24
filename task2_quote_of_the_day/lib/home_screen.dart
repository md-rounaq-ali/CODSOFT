import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'quote.dart';
import 'favorites_service.dart';
import 'favorites_screen.dart';

// Premium Category Gradients (Modern, curated palettes)
const Map<String, List<Color>> categoryGradients = {
  'Motivation': [Color(0xFF6366F1), Color(0xFFA855F7)], // Indigo to Purple
  'Wisdom':     [Color(0xFF0EA5E9), Color(0xFF2563EB)], // Sky to Royal Blue
  'Success':    [Color(0xFF10B981), Color(0xFF059669)], // Emerald to Green
  'Courage':    [Color(0xFFF43F5E), Color(0xFFE11D48)], // Rose to Ruby Red
  'Happiness':  [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber to Warm Orange
  'Growth':     [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan to Dark Teal
};

List<Color> gradientForCategory(String cat) =>
    categoryGradients[cat] ?? [const Color(0xFF6366F1), const Color(0xFFA855F7)];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Quote _currentQuote;
  bool _isFavorite = false;
  bool _isAnimating = false;
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  List<Quote> _filteredQuotes = [];
  bool _showResults = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.value = 1.0;

    // Set daily quote deterministically
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _currentQuote = allQuotes[dayOfYear % allQuotes.length];
    _checkFavorite();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoritesService.isFavorite(_currentQuote);
    setState(() => _isFavorite = fav);
  }

  void _showRandomQuote() async {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    await _fadeCtrl.reverse();
    final filtered = _selectedCategory == 'All'
        ? allQuotes
        : allQuotes.where((q) => q.category == _selectedCategory).toList();
    final next = filtered[DateTime.now().millisecondsSinceEpoch % filtered.length];
    setState(() => _currentQuote = next);
    await _checkFavorite();
    await _fadeCtrl.forward();
    setState(() => _isAnimating = false);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesService.removeFavorite(_currentQuote);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await FavoritesService.addFavorite(_currentQuote);
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote saved to favorites! ⭐'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareQuote(Quote quote) {
    Share.share(quote.toShareText(), subject: 'Quote of the Day');
  }

  void _copyToClipboard(Quote quote) {
    Clipboard.setData(ClipboardData(text: '"${quote.text}" — ${quote.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote copied to clipboard! 📋'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.length < 2) {
      setState(() { _showResults = false; _filteredQuotes = []; });
      return;
    }
    setState(() {
      _showResults = true;
      _filteredQuotes = allQuotes
          .where((quote) =>
              quote.text.toLowerCase().contains(q) ||
              quote.author.toLowerCase().contains(q) ||
              quote.category.toLowerCase().contains(q))
          .toList();
    });
  }

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _searchCtrl.clear();
      if (cat == 'All') {
        _showResults = false;
        _filteredQuotes = [];
      } else {
        _showResults = true;
        _filteredQuotes = allQuotes.where((q) => q.category == cat).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = gradientForCategory(_currentQuote.category);
    final today = DateTime.now();
    final dateStr = '${_weekday(today.weekday)}, ${_month(today.month)} ${today.day}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra-clean premium light gray
      body: Column(
        children: [
          // ── PREMIUM GRADIENT HEADER ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)], // Deep rich violet gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DQuotes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        // Glassmorphic Favorites Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.star_rounded, color: Colors.white, size: 26),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                              );
                              _checkFavorite();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Elegant Search Bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search_rounded, color: Color(0xFF7C3AED), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Search quote, author, or category...',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() { _showResults = false; _filteredQuotes = []; });
                              },
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CATEGORY CHIPS ──
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: categories.map((cat) {
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _selectCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFFC084FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: selected ? null : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── MAIN BODY CONTENT ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showResults) ...[
                    // Elegant Header Label
                    const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      child: Text(
                        'TODAY\'S INSPIRATION',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    // ── STUNNING HERO QUOTE CARD ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Large stylized watermark quotation mark
                            Positioned(
                              top: -10,
                              left: 10,
                              child: Text(
                                '“',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.12),
                                  fontSize: 160,
                                  fontFamily: 'serif',
                                  height: 0.8,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    _currentQuote.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      height: 1.6,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 1.5,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _currentQuote.author,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    children: [
                                      // Category pill tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          _currentQuote.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Action Buttons
                                      _iconAction(
                                        icon: _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                        onTap: _toggleFavorite,
                                      ),
                                      const SizedBox(width: 8),
                                      _iconAction(
                                        icon: Icons.copy_all_rounded,
                                        onTap: () => _copyToClipboard(_currentQuote),
                                      ),
                                      const SizedBox(width: 8),
                                      _iconAction(
                                        icon: Icons.share_rounded,
                                        onTap: () => _shareQuote(_currentQuote),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Elegant Random Quote Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _showRandomQuote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7C3AED),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎲', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'Generate Random Quote',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Categories Grid Header
                    const Text(
                      'BROWSE CATEGORIES',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gorgeous custom category cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _gridCategoryCard('💪', 'Motivation', [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]),
                        _gridCategoryCard('🦉', 'Wisdom', [const Color(0xFF0EA5E9), const Color(0xFF3B82F6)]),
                        _gridCategoryCard('🏆', 'Success', [const Color(0xFF10B981), const Color(0xFF059669)]),
                        _gridCategoryCard('😊', 'Happiness', [const Color(0xFFF59E0B), const Color(0xFFD97706)]),
                      ],
                    ),
                  ],

                  // ── SEARCH & CATEGORY RESULTS LIST ──
                  if (_showResults) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Text(
                        _searchCtrl.text.isNotEmpty
                            ? 'SEARCH RESULTS (${_filteredQuotes.length})'
                            : '${_selectedCategory.toUpperCase()} QUOTES (${_filteredQuotes.length})',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    if (_filteredQuotes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Text('🔍', style: TextStyle(fontSize: 48, color: Colors.grey.shade400)),
                              const SizedBox(height: 16),
                              const Text(
                                'No matching quotes found',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try searching for another keyword or author.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._filteredQuotes.map((q) => _resultCard(q)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _gridCategoryCard(String emoji, String title, List<Color> colors) {
    return GestureDetector(
      onTap: () => _selectCategory(title),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child: Text(emoji, style: const TextStyle(fontSize: 72)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(Quote quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quote.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_all_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => _copyToClipboard(quote),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.star_border_rounded, color: Color(0xFF94A3B8), size: 22),
                      onPressed: () async {
                        final added = await FavoritesService.addFavorite(quote);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(added ? 'Saved to favorites! ⭐' : 'Already in favorites!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => _shareQuote(quote),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${quote.text}"',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(width: 16, height: 1.5, color: const Color(0xFFCBD5E1)),
                const SizedBox(width: 8),
                Text(
                  quote.author,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(int d) =>
      ['', 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][d];
  String _month(int m) =>
      ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}
