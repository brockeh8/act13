import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
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

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
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

  double _progress = 0.0;
  int _lastMilestone = 0;
  late final ConfettiController _miniConfetti;

  bool _nameValid = false;
  bool _emailValid = false;
  bool _dobValid = false;
  bool _pwdValid = false;

  late final AnimationController _nameBounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), lowerBound: 0.9, upperBound: 1.0);
  late final AnimationController _emailBounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), lowerBound: 0.9, upperBound: 1.0);
  late final AnimationController _dobBounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), lowerBound: 0.9, upperBound: 1.0);
  late final AnimationController _pwdBounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), lowerBound: 0.9, upperBound: 1.0);

  late final AudioPlayer _sfx = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pwd.addListener(() => _evaluatePassword(_pwd.text));
    _name.addListener(() => _validateAndUpdate(field: 'name'));
    _email.addListener(() => _validateAndUpdate(field: 'email'));
    _dob.addListener(() => _validateAndUpdate(field: 'dob'));
    _miniConfetti = ConfettiController(duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pwd.dispose();
    _dob.dispose();
    _miniConfetti.dispose();
    _nameBounce.dispose();
    _emailBounce.dispose();
    _dobBounce.dispose();
    _pwdBounce.dispose();
    _sfx.dispose();
    super.dispose();
  }

  Future<void> _playSfxFlexible() async {
    Future<bool> tryPlay(String path) async {
      try {
        await _sfx.stop();
        await _sfx.play(AssetSource(path));
        return true;
      } catch (_) {
        return false;
      }
    }
    bool ok = await tryPlay('assets/audio.mp3');
    if (!ok) ok = await tryPlay('assets/audio.ogg');
    if (!ok) ok = await tryPlay('assets/audio.wav');
    if (!ok) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    }
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
      _pwdValid = _pwd.text.length >= 6;
    });
    if (_pwdValid) _playBounce(_pwdBounce);
    _updateProgress();
  }

  void _validateAndUpdate({required String field}) {
    final before = [_nameValid, _emailValid, _dobValid, _pwdValid];
    if (field == 'name') _nameValid = _name.text.trim().isNotEmpty;
    if (field == 'email') _emailValid = _email.text.contains('@') && _email.text.contains('.');
    if (field == 'dob') _dobValid = _dob.text.isNotEmpty;
    final after = [_nameValid, _emailValid, _dobValid, _pwdValid];
    if (before[0] != after[0] && _nameValid) _playBounce(_nameBounce);
    if (before[1] != after[1] && _emailValid) _playBounce(_emailBounce);
    if (before[2] != after[2] && _dobValid) _playBounce(_dobBounce);
    _updateProgress();
  }

  void _playBounce(AnimationController c) async {
    await c.forward(from: 0.9);
  }

  void _updateProgress() {
    var done = 0;
    if (_nameValid) done++;
    if (_emailValid) done++;
    if (_pwd.text.isNotEmpty) done++;
    if (_dobValid) done++;
    if (_avatarIndex != null) done++;
    final next = (done / 5).clamp(0.0, 1.0);
    final pct = (next * 100).round();
    for (final m in [25, 50, 75, 100]) {
      if (pct >= m && _lastMilestone < m) {
        _lastMilestone = m;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_milestoneText(m)), duration: const Duration(milliseconds: 900), behavior: SnackBarBehavior.floating),
        );
        _miniConfetti.play();
        HapticFeedback.mediumImpact();
        _playSfxFlexible();
        if (m == 100) HapticFeedback.heavyImpact();
        break;
      }
    }
    setState(() => _progress = next);
  }

  String _milestoneText(int m) {
    if (m == 25) return 'Nice start! 25%';
    if (m == 50) return 'Halfway! 50%';
    if (m == 75) return 'Almost there! 75%';
    return 'Ready to launch! 100%';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dob.text = '${picked.day}/${picked.month}/${picked.year}';
      _validateAndUpdate(field: 'dob');
    }
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
    if (_nameValid && _emailValid && _pwd.text.isNotEmpty && _dobValid) {
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Adventure Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${(_progress * 100).round()}%'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(minHeight: 12, value: _progress),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _progress >= 1.0 ? 'All set!' :
                              _progress >= 0.75 ? 'Almost there' :
                              _progress >= 0.5 ? 'Halfway' :
                              _progress >= 0.25 ? 'Nice start' : 'Let’s begin',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _validatedField(
                      controller: _name,
                      label: 'Adventure Name',
                      icon: Icons.person,
                      validator: (v) => (v==null||v.isEmpty) ? 'Enter a name' : null,
                      valid: _nameValid,
                      bounce: _nameBounce,
                    ),
                    const SizedBox(height: 16),

                    _validatedField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      validator: (v) {
                        if (v==null||v.isEmpty) return 'Enter email';
                        if (!v.contains('@') || !v.contains('.')) return 'Enter valid email';
                        return null;
                      },
                      valid: _emailValid,
                      bounce: _emailBounce,
                    ),
                    const SizedBox(height: 16),

                    _dobField(),
                    const SizedBox(height: 16),

                    _passwordField(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Strength: $_pwLabel', style: TextStyle(color: _pwColor, fontWeight: FontWeight.w600)),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Text('Choose your avatar')),
                        if (_avatarIndex != null)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (int i = 0; i < _avatars.length; i++)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () { setState(() => _avatarIndex = i); _updateProgress(); },
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _miniConfetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 18,
              gravity: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _validatedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool valid,
    required AnimationController bounce,
  }) {
    return ScaleTransition(
      scale: bounce.drive(Tween(begin: 1.0, end: 1.0)),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: valid ? const Icon(Icons.check_circle, key: ValueKey('ok'), color: Colors.green) : const SizedBox(key: ValueKey('no')),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _dobField() {
    return ScaleTransition(
      scale: _dobBounce.drive(Tween(begin: 1.0, end: 1.0)),
      child: TextFormField(
        controller: _dob,
        readOnly: true,
        onTap: _pickDate,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDate),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: _dobValid ? const Icon(Icons.check_circle, key: ValueKey('dobok'), color: Colors.green) : const SizedBox(key: ValueKey('dobno')),
              ),
            ],
          ),
        ),
        validator: (v) => (v==null||v.isEmpty) ? 'Pick a date' : null,
      ),
    );
  }

  Widget _passwordField() {
    return ScaleTransition(
      scale: _pwdBounce.drive(Tween(begin: 1.0, end: 1.0)),
      child: TextFormField(
        controller: _pwd,
        obscureText: !_showPwd,
        decoration: InputDecoration(
          labelText: 'Secret Password',
          prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(_showPwd ? Icons.visibility : Icons.visibility_off, color: Colors.deepPurple),
                onPressed: () => setState(() => _showPwd = !_showPwd),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: _pwdValid ? const Icon(Icons.check_circle, key: ValueKey('pwdok'), color: Colors.green) : const SizedBox(key: ValueKey('pwdno')),
              ),
            ],
          ),
        ),
        validator: (v) {
          if (v==null||v.isEmpty) return 'Enter password';
          if (v.length < 6) return 'Min 6 characters';
          return null;
        },
      ),
    );
  }
}
