import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/Request.dart';
import 'package:frontend/State.dart';
import 'package:frontend/main.dart';
import 'package:frontend/sampleRss.dart';
import 'package:provider/provider.dart';

class ImmersiveRSSFeedUploader extends StatefulWidget {
  const ImmersiveRSSFeedUploader({Key? key}) : super(key: key);

  @override
  _ImmersiveRSSFeedUploaderState createState() =>
      _ImmersiveRSSFeedUploaderState();
}

class _ImmersiveRSSFeedUploaderState extends State<ImmersiveRSSFeedUploader> {
  // Design Color Palette
  static const Color _primaryGreen = Color(0xFF00FF6C);
  static const Color _backgroundDark = Color(0xFF0A0A1A);
  static const Color _accentPurple = Color(0xFF9C27B0);
  static const Color _softGreen = Color(0xFF00FF6C);
  static const Color _glowColor = Color(0xFF00FF6C);

  final List<TextEditingController> _linkControllers =
      List.generate(5, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  // Tracking active input
  int _activeFeedIndex = -1;
  // To get the text from a specific link input
  String getLinkText(int index) {
    return _linkControllers[index].text;
  }

// To get all links
  List<String> getAllLinks() {
    return _linkControllers
        .map((controller) => controller.text.trim())
        .where((link) => link.isNotEmpty)
        .toList();
  }

// In your processing method
  void processLinks() {
    // Get all non-empty links
    List<String> links = getAllLinks();

    // Example of processing
    links.forEach((link) {
      print('Processing link: $link');
      // Add your link processing logic here
    });
  }

// If you want to clear all link inputs after processing
  void clearLinkInputs() {
    _linkControllers.forEach((controller) {
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var emptyRss = context.watch<appbloc>().rssLinkValue;

    return Scaffold(
      backgroundColor: _backgroundDark,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: emptyRss == "" ? _buildRSSUploader() : _buildSplitLayout(),
      ),
    );
  }

  Widget _buildRSSUploader() {
    return Center(
      child: Container(
        width: 700,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        decoration: BoxDecoration(
          color: _backgroundDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _softGreen.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
                color: _glowColor.withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 15,
                offset: Offset(0, 10))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Immersive Title
              Text(
                'Rss FEED SYNC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _softGreen,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: _glowColor.withOpacity(0.7),
                    )
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .shimmer(color: _softGreen.withOpacity(0.5)),

              SizedBox(height: 40),

              // Dynamic Feed Link Inputs
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _activeFeedIndex == index
                            ? [
                                _softGreen.withOpacity(0.1),
                                _accentPurple.withOpacity(0.1)
                              ]
                            : [Colors.transparent, Colors.transparent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _activeFeedIndex == index
                              ? _softGreen.withOpacity(0.5)
                              : Colors.transparent,
                          width: 2),
                    ),
                    child: TextFormField(
                      controller: _linkControllers[index],
                      onTap: () => setState(() => _activeFeedIndex = index),
                      onEditingComplete: () =>
                          setState(() => _activeFeedIndex = -1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.2),
                      decoration: InputDecoration(
                        hintText: 'Enter Rss Feed Link ${index + 1}',
                        hintStyle: TextStyle(
                            color: _softGreen.withOpacity(0.5),
                            letterSpacing: 1.5),
                        prefixIcon: Icon(
                          Icons.electrical_services_rounded,
                          color: _softGreen,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: _glowColor.withOpacity(0.7),
                            )
                          ],
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final urlPattern =
                            r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$';
                        if (!RegExp(urlPattern).hasMatch(value)) {
                          return 'Invalid Rss Feed Link';
                        }
                        return null;
                      },
                    ),
                  ),
                )
                    .animate()
                    .slideX(
                        begin: -0.1, duration: 500.ms, curve: Curves.easeOut)
                    .fadeIn(),
              ),

              SizedBox(height: 30),

              // Immersive Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final urlLinks = getAllLinks();
                    try {
                      print("----------${urlLinks.runtimeType}------------");
                      requests.sendLinks(urlLinks, "sample", context);
                    } catch (e) {
                      print(e);
                    }

                    // Process links logic
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: _softGreen,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                        color: _softGreen.withOpacity(0.7), width: 2),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SYNC Rss Feed',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: _glowColor.withOpacity(0.5),
                        )
                      ]),
                ),
              )
                  .animate()
                  .scale(duration: 500.ms)
                  .fadeIn()
                  .shimmer(color: _softGreen, delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Row(
      key: const ValueKey('split-layout'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildRSSUploader(),
        ),
        Expanded(
          child: RSSFeedViewer(),
        )
      ],
    ).animate().fadeIn(duration: 500.ms);
  }
}
