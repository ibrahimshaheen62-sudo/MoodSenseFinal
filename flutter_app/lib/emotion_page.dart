import 'package:flutter/material.dart';
import 'package:flutter_application_1/emotion_api.dart';

class EmotionPage extends StatefulWidget {
  const EmotionPage({Key? key}) : super(key: key);

  @override
  State<EmotionPage> createState() => _EmotionPageState();
}

class _EmotionPageState extends State<EmotionPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _analyze() async {
    setState(() => _loading = true);
    try {
      final res = await EmotionApi.getEmotion(_controller.text);
      setState(() => _results = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Classifier')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _analyze,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze Emotion'),
            ),
            const SizedBox(height: 20),
            if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return ListTile(
                      title: Text(item['label']),
                      trailing: Text((item['score'] * 100).toStringAsFixed(2) + '%'),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
