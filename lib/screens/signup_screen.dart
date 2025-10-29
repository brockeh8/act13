import 'package:flutter/material.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _Avatar {
  final IconData icon;
  final Color color;
  const _Avatar(this.icon, this.color);
}

const _avatars = <_Avatar>[
  _Avatar(Icons.rocket_launch, Colors.deepPurple),
  _Avatar(Icons.pets, Colors.orange),
  _Avatar(Icons.face, Colors.teal),
  _Avatar(Icons.sports_esports, Colors.indigo),
  _Avatar(Icons.emoji_nature, Colors.pink),
];

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _dob = TextEditingController();

  bool _showPwd = false;
  bool _loading = false;
  int? _avatarIndex;

  double _pwStrength = 0.0;
  String _pwLabel = 'Weak';
  Color _pwColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _pwd.addListener(() => _evaluatePassword(_pwd.text));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pwd.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _evaluatePassword(String p) {
    final a = p.length >= 8 ? 1 : 0;
    final b = RegExp(r'[a-z]').hasMatch(p) ? 1 : 0;
    final c = RegExp(r'[A-Z]').hasMatch(p) ? 1 : 0;
    final d = RegExp(r'[0-9]').hasMatch(p) ? 1 : 0;
    final e = RegExp(r'[^A-Za-z0-9]').hasMatch(p) ? 1 : 0;
    final s = ((a + b + c + d + e) / 5).clamp(0.0, 1.0);
    setState(() {
      _pwStrength = s;
      if (s < 0.4) { _pwColor = Colors.red; _pwLabel = 'Weak'; }
      else if (s < 0.7) { _pwColor = Colors.orange; _pwLabel = 'Okay'; }
      else if (s < 0.9) { _pwColor = Colors.lightGreen; _pwLabel = 'Strong'; }
      else { _pwColor = Colors.green; _pwLabel = 'Excellent'; }
    });
  }

  void _updateProgress() {}

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) _dob.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_avatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick an avatar to continue')));
      return;
    }
    setState(() => _loading = true);

    final badges = <String>[];
    if (_pwStrength >= 0.75) badges.add('Strong Password Master');
    if (DateTime.now().hour < 12) badges.add('The Early Bird Special');
    if (_name.text.trim().isNotEmpty &&
        _email.text.contains('@') &&
        _pwd.text.isNotEmpty &&
        _dob.text.isNotEmpty) {
      badges.add('Profile Completer');
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            userName: _name.text.trim(),
            avatarIcon: _avatars[_avatarIndex!].icon,
            avatarColor: _avatars[_avatarIndex!].color,
            badges: badges,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, title: const Text('Create Your Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Adventure Name', Icons.person, (v) => (v==null||v.isEmpty) ? 'Enter a name' : null),
                const SizedBox(height: 16),
                _field(_email, 'Email Address', Icons.email, (v) {
                  if (v==null||v.isEmpty) return 'Enter email';
                  if (!v.contains('@') || !v.contains('.')) return 'Enter valid email';
                  return null;
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dob,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDate),
                  ),
                  validator: (v) => (v==null||v.isEmpty) ? 'Pick a date' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pwd,
                  obscureText: !_showPwd,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(_showPwd ? Icons.visibility : Icons.visibility_off, color: Colors.deepPurple),
                      onPressed: () => setState(() => _showPwd = !_showPwd),
                    ),
                  ),
                  validator: (v) {
                    if (v==null||v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Strength: $_pwLabel', style: TextStyle(color: _pwColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: Text('Choose your avatar', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (int i = 0; i < _avatars.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _avatarIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: _avatarIndex == i ? [BoxShadow(color: _avatars[i].color.withOpacity(0.35), blurRadius: 12, spreadRadius: 1)] : null,
                          ),
                          child: CircleAvatar(
                            radius: _avatarIndex == i ? 30 : 26,
                            backgroundColor: _avatars[i].color.withOpacity(0.15),
                            child: Icon(_avatars[i].icon, color: _avatars[i].color, size: _avatarIndex == i ? 32 : 26),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                          onPressed: _submit,
                          child: const Text('Start My Adventure'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, String? Function(String?) v) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: v,
    );
  }
}
