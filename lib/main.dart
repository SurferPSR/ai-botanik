import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const BotanikApp());

class BotanikApp extends StatelessWidget {
  const BotanikApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Botanik',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8F4),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6B4F)),
        ),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  File? _image;
  bool _analyzing = false;

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 88, maxWidth: 1800);
    if (picked == null || !mounted) return;
    setState(() { _image = File(picked.path); _analyzing = true; });
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _analyzing = false);
  }

  void _openPicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(alignment: Alignment.centerLeft, child: Text('Добавить фотографию', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 18),
            _PickerOption(icon: Icons.photo_library_outlined, title: 'Выбрать из галереи', onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); }),
            _PickerOption(icon: Icons.camera_alt_outlined, title: 'Сделать снимок', onTap: () { Navigator.pop(context); _pick(ImageSource.camera); }),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFE0EFE4), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.eco_rounded, color: Color(0xFF2C6B4F), size: 25)),
                  const SizedBox(width: 11),
                  const Text('botanik', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                ]),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, size: 26)),
              ]),
              const SizedBox(height: 35),
              const Text('Познакомься\nсо своим растением', style: TextStyle(fontSize: 34, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.2)),
              const SizedBox(height: 13),
              Text('Сфотографируй растение — мы расскажем,\nкак сделать его счастливым.', style: TextStyle(fontSize: 16, height: 1.4, color: Colors.grey.shade600)),
              const SizedBox(height: 27),
              _ScanCard(image: _image, analyzing: _analyzing, onTap: _openPicker),
              if (_image != null && !_analyzing) ...[
                const SizedBox(height: 24),
                const _PlantDetails(),
              ],
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Последнее открытие', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text('Все')),
              ]),
              const SizedBox(height: 7),
              const _PlantPreview(),
            ]),
          ),
        ),
        bottomNavigationBar: NavigationBar(selectedIndex: 0, onDestinationSelected: (_) {}, destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist_rounded), label: 'Мои растения'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
        ]),
      );
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({required this.icon, required this.title, required this.onTap});
  final IconData icon; final String title; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: const Color(0xFFEAF4EC), child: Icon(icon, color: const Color(0xFF2C6B4F))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.image, required this.analyzing, required this.onTap});
  final File? image; final bool analyzing; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 250,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF204D3A)),
          child: Stack(fit: StackFit.expand, children: [
            if (image != null) Image.file(image!, fit: BoxFit.cover) else const _LeafArtwork(),
            if (image != null) Container(color: Colors.black.withOpacity(.25)),
            Center(child: analyzing
                ? const Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height: 14), Text('Изучаем растение…', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))])
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 62, height: 62, decoration: BoxDecoration(color: Colors.white.withOpacity(.92), shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2C6B4F), size: 29)),
                    const SizedBox(height: 13),
                    Text(image == null ? 'Определить растение' : 'Определить ещё раз', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('Нажми, чтобы открыть камеру', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ])),
          ]),
        ),
      );
}

class _LeafArtwork extends StatelessWidget {
  const _LeafArtwork();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _LeafPainter());
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E7655);
    canvas.drawCircle(Offset(size.width * .18, size.height * .86), size.width * .33, paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .57, size.height * .50), width: size.width * .45, height: size.height * .88), paint);
    paint.color = const Color(0xFF77B579);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .83, size.height * .35), width: size.width * .34, height: size.height * .58), paint);
    paint.color = const Color(0xFFB4D59A);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .38, size.height * .18), width: size.width * .31, height: size.height * .45), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlantPreview extends StatelessWidget {
  const _PlantPreview();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: const Color(0xFFDCEBD7), borderRadius: BorderRadius.circular(17)), child: const Center(child: Text('🌿', style: TextStyle(fontSize: 38)))),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Монстера делициоза', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 5),
            Text('Monstera deliciosa', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54)),
            SizedBox(height: 8),
            Row(children: [Icon(Icons.wb_sunny_outlined, size: 15, color: Color(0xFFD49C38)), SizedBox(width: 4), Text('Рассеянный свет', style: TextStyle(fontSize: 12, color: Colors.black54))]),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.black45),
        ]),
      );
}

class _PlantDetails extends StatelessWidget {
  const _PlantDetails();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Монстера делициоза', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Monstera deliciosa  ·  Ароидные', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54)),
            ]),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFE6F3E8), borderRadius: BorderRadius.circular(20)), child: const Text('96%', style: TextStyle(color: Color(0xFF2C6B4F), fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text('Условия ухода', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const Row(children: [
            Expanded(child: _CareItem(icon: Icons.wb_sunny_outlined, label: 'Свет', value: 'Рассеянный')),
            Expanded(child: _CareItem(icon: Icons.water_drop_outlined, label: 'Полив', value: '1 раз в 7 дней')),
          ]),
          const SizedBox(height: 14),
          const Row(children: [
            Expanded(child: _CareItem(icon: Icons.thermostat_outlined, label: 'Температура', value: '18–27 °C')),
            Expanded(child: _CareItem(icon: Icons.cloud_outlined, label: 'Влажность', value: '60–80%')),
          ]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFF0F7F0), borderRadius: BorderRadius.circular(15)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFB88122), size: 20),
            SizedBox(width: 9),
            Expanded(child: Text('Протирай листья от пыли раз в неделю — так растение будет лучше дышать.', style: TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF435447)))),
          ])),
        ]),
      );
}

class _CareItem extends StatelessWidget {
  const _CareItem({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFEAF4EC), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF2C6B4F), size: 19)),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
      ]);
}
