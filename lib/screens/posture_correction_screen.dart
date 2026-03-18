import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';

class PostureCorrectionScreen extends StatefulWidget {
  final String workoutName;

  const PostureCorrectionScreen({super.key, required this.workoutName});

  @override
  State<PostureCorrectionScreen> createState() =>
      _PostureCorrectionScreenState();
}

class _PostureCorrectionScreenState extends State<PostureCorrectionScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  String _feedback = "Initializing camera...";
  int _reps = 0;
  String _stage = "";
  double _angle = 0;
  List<dynamic> _landmarks = [];
  Timer? _timer;
  late FlutterTts _flutterTts;
  String _lastSpokenFeedback = "";
  int _selectedCameraIndex = -1;

  final String _apiUrl = "https://fitness-posture-ai.onrender.com/analyze";

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initializeCamera();
  }

  void _initTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty && text != _lastSpokenFeedback) {
      _lastSpokenFeedback = text;
      await _flutterTts.speak(text);
    }
  }

  int _getPreferredCameraIndex() {
    final rearIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (rearIndex != -1) {
      return rearIndex;
    }

    final frontIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (frontIndex != -1) {
      return frontIndex;
    }

    return 0;
  }

  bool get _isFrontCamera {
    if (_selectedCameraIndex < 0 || _selectedCameraIndex >= cameras.length) {
      return false;
    }
    return cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  bool get _canSwitchCamera {
    final availableDirections =
        cameras.map((camera) => camera.lensDirection).toSet();
    return availableDirections.contains(CameraLensDirection.front) &&
        availableDirections.contains(CameraLensDirection.back);
  }

  String _cameraLabel(CameraLensDirection lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.front:
        return 'front';
      case CameraLensDirection.back:
        return 'rear';
      case CameraLensDirection.external:
        return 'external';
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _feedback = "Camera permission denied";
      });
      return;
    }

    if (cameras.isEmpty) {
      setState(() {
        _feedback = "No cameras found";
      });
      return;
    }

    final initialIndex = _selectedCameraIndex >= 0
        ? _selectedCameraIndex
        : _getPreferredCameraIndex();
    await _createCameraController(initialIndex);
  }

  Future<void> _createCameraController(int cameraIndex) async {
    _timer?.cancel();
    _timer = null;

    final oldController = _controller;
    _controller = null;

    if (mounted) {
      setState(() {
        _feedback =
            "Initializing ${_cameraLabel(cameras[cameraIndex].lensDirection)} camera...";
        _landmarks = [];
      });
    }

    await oldController?.dispose();

    final controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await controller.setFlashMode(FlashMode.off);
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);

      _controller = controller;
      _selectedCameraIndex = cameraIndex;

      if (!mounted) return;
      setState(() {
        _feedback =
            "Ready! Perform your ${widget.workoutName} with the ${_cameraLabel(controller.description.lensDirection)} camera";
      });
      _startAnalysis();
    } catch (e) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _feedback = "Camera initialization failed: $e";
      });
    }
  }

  Future<void> _switchCamera() async {
    if (!_canSwitchCamera || _isProcessing) return;

    final targetLens = _isFrontCamera
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    final targetIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == targetLens,
    );

    if (targetIndex == -1) return;
    await _createCameraController(targetIndex);
  }

  void _startAnalysis() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!_isProcessing &&
          _controller != null &&
          _controller!.value.isInitialized) {
        _captureAndAnalyze();
      }
    });
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await controller.takePicture();

      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      String exerciseType = widget.workoutName.toLowerCase().trim();
      if (exerciseType.contains('squat')) {
        exerciseType = 'squat';
      } else if (exerciseType.contains('curl')) {
        exerciseType = 'bicep_curl';
      } else if (exerciseType.contains('push')) {
        exerciseType = 'pushup';
      } else if (exerciseType.contains('lunge')) {
        exerciseType = 'lunge';
      } else if (exerciseType.contains('plank')) {
        exerciseType = 'plank';
      }

      request.fields['exercise'] = exerciseType;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _feedback = data['feedback']?.toString() ?? "Keep going!";
          _reps = (data['reps'] as num?)?.toInt() ?? _reps;
          _stage = data['stage']?.toString() ?? "";
          _landmarks = data['landmarks'] as List<dynamic>? ?? [];
          _angle = (data['angle'] as num?)?.toDouble() ?? 0.0;
        });

        if (_feedback != "Keep going!" && _feedback.isNotEmpty) {
          _speak(_feedback);
        }
      } else {
        var errorMsg = "Service Error (${response.statusCode})";
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (_) {}
        setState(() {
          _feedback = errorMsg;
        });
      }
    } catch (e) {
      var errMsg = e.toString();
      if (errMsg.contains('TimeoutException')) {
        errMsg = "Server is taking too long to respond. (Render might be waking up)";
      } else if (errMsg.contains('SocketException')) {
        errMsg = "Cannot connect to server. Check your internet connection.";
      }
      setState(() {
        _feedback = "Analysis failed: $errMsg";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;
    final previewSize = isReady ? controller.value.previewSize : null;

    final previewWidth = previewSize == null ? 1.0 : previewSize.height;
    final previewHeight = previewSize == null ? 1.0 : previewSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Posture: ${widget.workoutName}"),
        backgroundColor: const Color.fromARGB(255, 238, 255, 65),
      ),
      body: Stack(
        children: [
          if (isReady)
            Positioned.fill(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: previewWidth,
                    height: previewHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(controller),
                        if (_landmarks.isNotEmpty)
                          CustomPaint(
                            painter: PosePainter(
                              landmarks: _landmarks,
                              isFrontCamera: _isFrontCamera,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          if (_canSwitchCamera)
            Positioned(
              top: 20,
              left: 20,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _isProcessing ? null : _switchCamera,
                    tooltip: _isFrontCamera
                        ? 'Switch to rear camera'
                        : 'Switch to front camera',
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _isFrontCamera ? "FRONT" : "REAR",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "REPS",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      "$_reps",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_stage.isNotEmpty)
                      Text(
                        _stage.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Divider(color: Colors.white24),
                    const Text(
                      "ANGLE",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      "${_angle.toStringAsFixed(1)} deg",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _feedback,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isProcessing)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<dynamic> landmarks;
  final bool isFrontCamera;

  const PosePainter({
    required this.landmarks,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final pointPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.lightGreenAccent
      ..strokeWidth = 3.0;

    Offset? getOffset(int index) {
      if (index >= landmarks.length) return null;
      final lm = landmarks[index] as Map<String, dynamic>;
      final visibility = (lm['visibility'] as num?)?.toDouble() ?? 1.0;
      if (visibility < 0.4) return null;

      final rawX = (lm['x'] as num?)?.toDouble() ?? 0.0;
      final rawY = (lm['y'] as num?)?.toDouble() ?? 0.0;

      return Offset(
        (isFrontCamera ? (1 - rawX) : rawX) * size.width,
        rawY * size.height,
      );
    }

    final connections = [
      [11, 12],
      [11, 13],
      [13, 15],
      [12, 14],
      [14, 16],
      [11, 23],
      [12, 24],
      [23, 24],
      [23, 25],
      [25, 27],
      [24, 26],
      [26, 28],
    ];

    for (final connection in connections) {
      final start = getOffset(connection[0]);
      final end = getOffset(connection[1]);
      if (start != null && end != null) {
        canvas.drawLine(start, end, linePaint);
      }
    }

    for (final landmark in landmarks) {
      final lm = landmark as Map<String, dynamic>;
      final visibility = (lm['visibility'] as num?)?.toDouble() ?? 1.0;
      if (visibility < 0.4) continue;

      final rawX = (lm['x'] as num?)?.toDouble() ?? 0.0;
      final rawY = (lm['y'] as num?)?.toDouble() ?? 0.0;

      canvas.drawCircle(
        Offset(
          (isFrontCamera ? (1 - rawX) : rawX) * size.width,
          rawY * size.height,
        ),
        5.0,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
