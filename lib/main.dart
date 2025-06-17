import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Para selecionar arquivos
import 'package:geolocator/geolocator.dart'; // Para GPS

void main() {
  runApp(const GuardiaoDeTerrasApp());
}

class GuardiaoDeTerrasApp extends StatefulWidget {
  const GuardiaoDeTerrasApp({super.key});

  @override
  State<GuardiaoDeTerrasApp> createState() => _GuardiaoDeTerrasAppState();
}

class _GuardiaoDeTerrasAppState extends State<GuardiaoDeTerrasApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardião de Terras',
      theme: ThemeData(
        // Tema claro
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE5F4E3), // Fundo verde claro
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        // Tema escuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// --- TELA PRINCIPAL ---
class HomePage extends StatelessWidget {
  final Function() toggleTheme;
  final bool isDarkMode;

  const HomePage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título do aplicativo
                  Text(
                    '🌿 Guardião de Terras',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1E3A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtítulo
                  Text(
                    'Pressione o botão para iniciar uma denúncia segura.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Botão de Denúncia Principal
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReportFormPage(
                            toggleTheme: toggleTheme,
                            isDarkMode: isDarkMode,
                          )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFFc84a4a),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.red.withOpacity(0.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 80),
                          SizedBox(height: 8),
                          Text('DENUNCIAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Theme toggle button in top right corner
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              onPressed: toggleTheme,
            ),
          ),
        ],
      ),
    );
  }
}

// --- TELA DO FORMULÁRIO ---
class ReportFormPage extends StatefulWidget {
  final Function() toggleTheme;
  final bool isDarkMode;

  const ReportFormPage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  // Variáveis para controlar o estado do formulário
  String? _selectedReportType;
  final List<String> _reportTypes = [
    'Invasão por garimpeiros/madeireiros',
    'Desmatamento ilegal',
    'Queimada',
    'Ameaça a lideranças',
    'Emergência de saúde',
    'Outro',
  ];
  List<PlatformFile> _pickedFiles = [];
  String _locationStatus = 'Buscando coordenadas GPS...';
  bool _isGettingLocation = true;
  Position? _currentPosition;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getDeviceLocation();
  }

  // Função para pegar a localização
  Future<void> _getDeviceLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Buscando coordenadas GPS...';
    });

    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Serviço de localização desabilitado.';
          _isGettingLocation = false;
        });
        return;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Permissão de localização negada.';
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Permissão de localização negada permanentemente.';
          _isGettingLocation = false;
        });
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationStatus = 'Localização obtida com sucesso!';
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Falha ao obter localização: $e';
        _isGettingLocation = false;
      });
    }
  }

  // Função para abrir o seletor de arquivos
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Permite selecionar vários arquivos
        type: FileType.media, // Permite imagem e vídeo
      );

      if (result != null) {
        setState(() {
          _pickedFiles = result.files;
        });
      }
    } catch (e) {
      // Mostrar erro se houver problema ao selecionar arquivos
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivos: $e')),
        );
      }
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
       // Em um app real, aqui você enviaria os dados para um servidor.
      print('Formulário enviado!');
      print('Tipo: $_selectedReportType');
      print('Arquivos: ${_pickedFiles.length}');
      print('Localização: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');

      // Navega para a tela de sucesso
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          )),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Formulário de Denúncia',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        iconTheme: IconThemeData(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown para tipo de denúncia
              DropdownButtonFormField<String>(
                value: _selectedReportType,
                hint: Text(
                  'Selecione o tipo de denúncia',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                decoration: InputDecoration(
                  labelText: 'Tipo de denúncia',
                  labelStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.category,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                dropdownColor: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                items: _reportTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedReportType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecione um tipo.' : null,
              ),
              const SizedBox(height: 20),

              // Botão para anexar arquivos
              Text(
                'Anexar evidências',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(
                  Icons.attach_file,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
                label: Text(
                  'Selecionar Fotos ou Vídeos',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                onPressed: _pickFiles,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              if (_pickedFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${_pickedFiles.length} arquivo(s) selecionado(s).',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Status da Localização
              Text(
                'Localização',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isGettingLocation ? Icons.location_searching : Icons.location_on,
                      color: _isGettingLocation
                          ? (widget.isDarkMode ? Colors.grey.shade600 : Colors.grey)
                          : (widget.isDarkMode ? Colors.green.shade300 : Colors.green.shade700),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationStatus,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campo de descrição
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descreva o que aconteceu (opcional)',
                  labelStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  hintText: 'Forneça mais detalhes sobre a ocorrência.',
                  hintStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 30),
              
              // Botão de Envio
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Enviar Denúncia às Autoridades'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
               const SizedBox(height: 10),
               // Botão Cancelar
               TextButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade700,
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

// --- TELA DE SUCESSO ---
class SuccessPage extends StatelessWidget {
  final Function() toggleTheme;
  final bool isDarkMode;

  const SuccessPage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 100),
              const SizedBox(height: 24),
              Text(
                'Denúncia Enviada!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'As autoridades competentes foram notificadas. Agradecemos sua colaboração.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage(
                      toggleTheme: toggleTheme,
                      isDarkMode: isDarkMode,
                    )),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
