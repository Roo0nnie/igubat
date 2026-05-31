import 'package:flutter/material.dart';

class AppStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;

  const AppStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor = const Color(0xFF0F3D26), // Deep Green
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double stepWidth = width / steps.length;

        return SizedBox(
          height: 60,
          child: Stack(
            children: [
              // Progress Line
              Positioned(
                top: 14,
                left: stepWidth / 2,
                right: stepWidth / 2,
                child: Row(
                  children: List.generate(
                    steps.length - 1,
                    (index) {
                      final isActive = index < currentStep;
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: isActive ? activeColor : inactiveColor.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Step Dots and Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  steps.length,
                  (index) {
                    final isActive = index <= currentStep;
                    final isCurrent = index == currentStep;
                    
                    return SizedBox(
                      width: stepWidth,
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isActive ? activeColor : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive ? activeColor : inactiveColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: isActive
                                ? Icon(
                                    isCurrent ? Icons.circle : Icons.check,
                                    color: Colors.white,
                                    size: isCurrent ? 12 : 16,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            steps[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? activeColor : inactiveColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
