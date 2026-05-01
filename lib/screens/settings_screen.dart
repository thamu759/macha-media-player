import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openAiController = TextEditingController();
  final _elevenLabsController = TextEditingController();
  final _voiceIdController = TextEditingController();
  final _box = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _openAiController.text = _box.get('openai_key', defaultValue: "");
    _elevenLabsController.text = _box.get('elevenlabs_key', defaultValue: "");
    _voiceIdController.text = _box.get('voice_id', defaultValue: "pNInz6obpgDQGcFmaJcg");
  }

  void _saveSettings() {
    _box.put('openai_key', _openAiController.text.trim());
    _box.put('elevenlabs_key', _elevenLabsController.text.trim());
    _box.put('voice_id', _voiceIdController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Auto Dub API Keys', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
              const SizedBox(height: 16),
              TextField(
                controller: _openAiController,
                decoration: const InputDecoration(
                  labelText: 'OpenAI API Key (Whisper)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _elevenLabsController,
                decoration: const InputDecoration(
                  labelText: 'ElevenLabs API Key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _voiceIdController,
                decoration: const InputDecoration(
                  labelText: 'ElevenLabs Voice ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
