import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Para selecionar arquivos
import 'package:geolocator/geolocator.dart'; // Para GPS

void main() {
  runApp(const GuardiaoDeTerrasApp());
}

class GuardiaoDeTerrasApp extends StatelessWidget {
  const GuardiaoDeTerrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardião de Terras',
      theme: ThemeData(
        // Tema principal do aplicativo
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE5F4E3), // Fundo verde claro
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      // A rota inicial será a HomePage
      home: const HomePage(),
    );
  }
}

// --- TELA PRINCIPAL ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título do aplicativo
              const Text(
                '🌿 Guardião de Terras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A1A), // Verde escuro
                ),
              ),
              const SizedBox(height: 16),
              // Subtítulo
              const Text(
                'Pressione o botão para iniciar uma denúncia segura.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              // Botão de Denúncia Principal
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navega para a tela de formulário
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportFormPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xFFc84a4a), // Vermelho
                    foregroundColor: Colors.white, // Cor do texto e ícone
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
    );
  }
}

// --- TELA DO FORMULÁRIO ---
class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

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
          MaterialPageRoute(builder: (context) => const SuccessPage()),
       );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Denúncia'),
        centerTitle: true,
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
                hint: const Text('Selecione o tipo de denúncia'),
                decoration: const InputDecoration(
                  labelText: 'Tipo de denúncia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _reportTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
              const Text('Anexar evidências', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Selecionar Fotos ou Vídeos'),
                onPressed: _pickFiles,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_pickedFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${_pickedFiles.length} arquivo(s) selecionado(s).', style: TextStyle(color: Colors.green.shade800)),
                ),
              const SizedBox(height: 20),

              // Status da Localização
               const Text('Localização', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.grey.shade200,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Row(
                   children: [
                     Icon(
                      _isGettingLocation ? Icons.location_searching : Icons.location_on, 
                      color: _isGettingLocation ? Colors.grey : Colors.green.shade700
                     ),
                     const SizedBox(width: 8),
                     Expanded(child: Text(_locationStatus)),
                   ],
                 ),
               ),
               const SizedBox(height: 20),

              // Campo de descrição
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descreva o que aconteceu (opcional)',
                  hintText: 'Forneça mais detalhes sobre a ocorrência.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
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
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade700)),
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
  const SuccessPage({super.key});

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
              const Text(
                'Denúncia Enviada!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'As autoridades competentes foram notificadas. Agradecemos sua colaboração.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Volta para a tela inicial, limpando as outras da pilha
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
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
