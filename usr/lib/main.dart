import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobox Order',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const PhotoboxOrderScreen(),
    );
  }
}

class PhotoboxOrderScreen extends StatefulWidget {
  const PhotoboxOrderScreen({super.key});

  @override
  State<PhotoboxOrderScreen> createState() => _PhotoboxOrderScreenState();
}

class _PhotoboxOrderScreenState extends State<PhotoboxOrderScreen> {
  // State variables for user selections
  String? _selectedColor;
  int? _selectedPhotoCount;
  String? _selectedAlbum;
  bool? _withMusic;

  double _totalPrice = 0.0;

  // Prices
  static const double _price12Photos = 5000;
  static const double _price20Photos = 7000;
  static const double _album20PhotosPrice = 2000;
  static const double _album40PhotosPrice = 3500;
  static const double _musicPrice = 1000;

  final List<String> _colors = ['Светлый дуб', 'Тёмный венге', 'Нежный фиолет'];
  final Map<int, double> _photoOptions = {12: _price12Photos, 20: _price20Photos};
  final Map<String, double> _albumOptions = {
    'Без альбома': 0,
    'Мини-альбом на 20 фото': _album20PhotosPrice,
    'Мини-альбом на 40 фото': _album40PhotosPrice,
  };
  final Map<bool, double> _musicOptions = {
    false: 0,
    true: _musicPrice,
  };

  void _calculatePrice() {
    double currentPrice = 0;
    if (_selectedPhotoCount != null) {
      currentPrice += _photoOptions[_selectedPhotoCount]!;
    }
    if (_selectedAlbum != null) {
      currentPrice += _albumOptions[_selectedAlbum]!;
    }
    if (_withMusic != null && _withMusic == true) {
      currentPrice += _musicPrice;
    }
    setState(() {
      _totalPrice = currentPrice;
    });
  }

  bool _isOrderComplete() {
    return _selectedColor != null &&
        _selectedPhotoCount != null &&
        _selectedAlbum != null &&
        _withMusic != null;
  }

  void _sendOrderToWhatsApp() async {
    if (!_isOrderComplete()) return;

    final String orderSummary = """
Здравствуйте! Хочу сделать заказ Photobox:
- Цвет корпуса: $_selectedColor
- Количество фотографий: $_selectedPhotoCount
- Мини-альбом: $_selectedAlbum
- Фономузыка: ${_withMusic! ? 'Да' : 'Нет'}
- Итоговая сумма: $_totalPrice ₸
""";

    // TODO: Replace with your actual phone number
    const String phoneNumber = "+71234567890"; 
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderSummary)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Не удалось открыть WhatsApp.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🖤 Оформляем заказ от Photobox'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Выберите формат, цвет, количество фотографий и доп. опции — и мы создадим ваш идеальный фотобокс.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: '1. Цвет Photobox',
            subtitle: 'Выберите цвет корпуса:',
            child: _buildColorSelector(),
          ),
          _buildSectionCard(
            title: '2. Количество фотографий',
            subtitle: 'Сколько фото добавить:',
            child: _buildRadioGroup<int>(
              options: _photoOptions,
              groupValue: _selectedPhotoCount,
              onChanged: (value) {
                setState(() {
                  _selectedPhotoCount = value;
                  _calculatePrice();
                });
              },
              labelBuilder: (key) => '$key фотографий',
            ),
          ),
          _buildSectionCard(
            title: '3. Мини-альбом',
            subtitle: 'Хотите добавить мини-альбом?',
            child: _buildRadioGroup<String>(
              options: _albumOptions,
              groupValue: _selectedAlbum,
              onChanged: (value) {
                setState(() {
                  _selectedAlbum = value;
                  _calculatePrice();
                });
              },
              labelBuilder: (key) => '$key (+${_albumOptions[key]} ₸)',
            ),
          ),
          _buildSectionCard(
            title: '4. Фотомузыка',
            subtitle: 'Добавьте фотомузыку для атмосферы:',
            child: _buildRadioGroup<bool>(
              options: _musicOptions,
              groupValue: _withMusic,
              onChanged: (value) {
                setState(() {
                  _withMusic = value;
                  _calculatePrice();
                });
              },
              labelBuilder: (key) => key ? 'С фотомузыкой (+${_musicOptions[key]} ₸) 🎵' : 'Без музыки',
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _colors.map((color) {
        final isSelected = _selectedColor == color;
        return ChoiceChip(
          label: Text(color),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedColor = color;
              }
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadioGroup<T>({
    required Map<T, double> options,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      children: options.keys.map((key) {
        return RadioListTile<T>(
          title: Text(labelBuilder(key)),
          value: key,
          groupValue: groupValue,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          activeColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildPriceFooter() {
    return Column(
      children: [
        Text(
          'Итоговая цена: ${_totalPrice.toStringAsFixed(0)} ₸',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isOrderComplete())
          ElevatedButton.icon(
            onPressed: _sendOrderToWhatsApp,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('💬 Отправить заказ в WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
      ],
    );
  }
}
