import 'package:flutter/material.dart';
import 'steps/upload_step.dart';
import 'steps/edit_step.dart';
import 'steps/enhance_step.dart';
import 'steps/publish_step.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildProgressBar(),
        automaticallyImplyLeading: false,
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isCompleted = index < _currentStep;
        bool isCurrent = index == _currentStep;
        return Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent || isCompleted
                    ? const Color(0xFFFF6B9D)
                    : Colors.grey[300],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent || isCompleted
                              ? Colors.white
                              : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            if (index < 3)
              Container(
                width: 40,
                height: 2,
                color: index < _currentStep
                    ? const Color(0xFFFF6B9D)
                    : Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return UploadStep(onNext: _nextStep);
      case 1:
        return EditStep(onNext: _nextStep, onPrev: _prevStep);
      case 2:
        return EnhanceStep(onNext: _nextStep, onPrev: _prevStep);
      case 3:
        return PublishStep(onPrev: _prevStep);
      default:
        return UploadStep(onNext: _nextStep);
    }
  }
}
