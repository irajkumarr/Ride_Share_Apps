import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Screen allowing drivers to register their vehicle details required by the backend.
/// Exactly matches the provided Vehicle Registration design.
class VehicleRegisterScreen extends StatefulWidget {
  final bool showBackButton;

  const VehicleRegisterScreen({super.key, this.showBackButton = true});

  @override
  State<VehicleRegisterScreen> createState() => _VehicleRegisterScreenState();
}

class _VehicleRegisterScreenState extends State<VehicleRegisterScreen>
    with FormMixin {
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _colorController;

  String _selectedType = 'ECONOMY';
  final List<String> _vehicleTypes = ['ECONOMY', 'PREMIUM', 'XL'];

  @override
  void initState() {
    super.initState();
    _makeController = registerController();
    _modelController = registerController();
    _yearController = registerController();
    _plateController = registerController();
    _colorController = registerController();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  void _onSubmit() {
    hideKeyboard();
    if (!validateForm()) return;

    final vehicle = {
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': _yearController.text.trim(),
      'licensePlate': _plateController.text.trim().toUpperCase(),
      'color': _colorController.text.trim(),
      'type': _selectedType,
    };

    context.read<VehicleCubit>().registerVehicle(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.showBackButton,
      child: DismissFocusOverlay(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: widget.showBackButton
                ? IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 30,
                      color: Color(0xFF111827),
                    ),
                  )
                : null,
            automaticallyImplyLeading: false,
            title: const Text(
              'Vehicle Registration',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: !widget.showBackButton,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFF3F4F6), height: 1),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Title
                          const Text(
                            'Add Your Vehicle',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Subtitle
                          const Text(
                            'This vehicle will be assigned to incoming rider dispatch requests.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Vehicle Category Label
                          const Text(
                            'Vehicle Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3 Category Cards: ECONOMY, PREMIUM, XL
                          _buildCategorySelector(),

                          const SizedBox(height: 24),

                          // Make & Model Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Make'),
                                    const SizedBox(height: 8),
                                    _buildInputField(
                                      controller: _makeController,
                                      hintText: 'e.g. Toyota',
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Enter make';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Model'),
                                    const SizedBox(height: 8),
                                    _buildInputField(
                                      controller: _modelController,
                                      hintText: 'e.g. Corolla',
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Enter model';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Year & Color Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Year'),
                                    const SizedBox(height: 8),
                                    _buildInputField(
                                      controller: _yearController,
                                      hintText: 'e.g. 2022',
                                      keyboardType: TextInputType.number,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Enter year';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Color'),
                                    const SizedBox(height: 8),
                                    _buildInputField(
                                      controller: _colorController,
                                      hintText: 'e.g. Silver',
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Enter color';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // License Plate
                          _buildFieldLabel('License Plate'),
                          const SizedBox(height: 8),
                          _buildLicensePlateField(),

                          const SizedBox(height: 40),

                          // Complete & Go Online Button
                          _buildSubmitButton(context),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: _vehicleTypes.map((type) {
        final isSelected = _selectedType == type;

        IconData iconData;
        if (type == 'XL') {
          iconData = Icons.local_shipping_rounded;
        } else if (type == 'PREMIUM') {
          iconData = Icons.directions_car_filled_rounded;
        } else {
          iconData = Icons.directions_car_rounded;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != _vehicleTypes.last ? 12 : 0,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
                    width: 1.4,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconData,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildLicensePlateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Row(
        children: [
          // 123 badge icon prefix like in design
          Container(
            margin: const EdgeInsets.only(left: 14),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4B5563),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '123',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextFormField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                hintText: 'E.G. BA 2 KHA 1234',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Enter license plate number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocConsumer<VehicleCubit, VehicleState>(
      listener: (context, state) {
        if (state is VehicleLoading) {
          LoadingOverlay.show();
        } else {
          LoadingOverlay.hide();
        }
        if (state is VehicleActionSuccess) {
          AppAlerts.success(context, state.message);
          context.go(AppRoutes.home);
        } else if (state is VehicleFailure) {
          AppAlerts.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _onSubmit,
              child: const Center(
                child: Text(
                  'Complete & Go Online',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
