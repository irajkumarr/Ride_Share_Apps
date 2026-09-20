import 'package:flutter/material.dart';

class CustomStepProgressBar extends StatelessWidget {
  final List<String> steps; //  dynamic steps
  final int currentStep; //  current active step (1-based index)

  //  customization params
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? lineColor;
  final double circleSize;
  final double lineWidth;
  final ScrollPhysics physics;

  const CustomStepProgressBar({
    Key? key,
    required this.steps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.lineColor,
    this.circleSize = 24,
    this.lineWidth = 40,
    this.physics = const BouncingScrollPhysics(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeStep = currentStep - 1;

    final theme = Theme.of(context);

    final active = activeColor ?? theme.primaryColor;
    final inactive = inactiveColor ?? Colors.grey;
    final dividerColor = lineColor ?? Colors.black;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(steps.length, (i) {
          final isActive = i <= activeStep;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: isActive ? active : null,
                        border: Border.all(
                          width: 2,
                          color: active,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _buildCircleChild(
                          index: i,
                          activeStep: activeStep,
                          isActive: isActive,
                          activeColor: active,
                          inactiveColor: inactive,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    steps[i],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive ? active : inactive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // line between steps
              if (i != steps.length - 1)
                Container(
                  height: 2,
                  width: lineWidth,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: dividerColor,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCircleChild({
    required int index,
    required int activeStep,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    if (index < activeStep) {
      //  completed step
      return const Icon(Icons.check, color: Colors.white, size: 16);
    } else {
      //  current or upcoming
      return Text(
        '${index + 1}',
        style: TextStyle(
          color: isActive ? Colors.white : inactiveColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
