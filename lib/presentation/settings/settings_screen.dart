import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/presentation/settings/settings_cubit.dart';
import 'package:local_game/presentation/settings/settings_state.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: creamBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: darkBorderColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: darkBorderColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: darkBorderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Spacer for centering
                  ],
                ),
              ),
              const Divider(height: 1, color: darkBorderColor, thickness: 2),

              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Audio', darkBorderColor),
                          const SizedBox(height: 16),

                          // Music Toggle
                          _buildSettingRow(
                            'Background Music',
                            state.musicEnabled,
                            (val) => _cubit.toggleMusic(val),
                            darkBorderColor,
                            accentOrange,
                          ),
                          const SizedBox(height: 16),

                          // SFX Toggle
                          _buildSettingRow(
                            'Sound Effects',
                            state.sfxEnabled,
                            (val) => _cubit.toggleSfx(val),
                            darkBorderColor,
                            accentOrange,
                          ),
                          const SizedBox(height: 32),

                          _buildSectionTitle('Volume', darkBorderColor),
                          const SizedBox(height: 16),

                          // Volume Slider
                          NeubrutalismContainer(
                            borderRadius: 20,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.volume_mute, color: darkBorderColor),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: accentOrange,
                                      inactiveTrackColor: accentOrange
                                          .withOpacity(0.2),
                                      thumbColor: accentOrange,
                                      overlayColor: accentOrange.withOpacity(
                                        0.1,
                                      ),
                                      trackHeight: 8,
                                    ),
                                    child: Slider(
                                      value: state.volume,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (val) => _cubit.setVolume(val),
                                    ),
                                  ),
                                ),
                                Icon(Icons.volume_up, color: darkBorderColor),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Info Card
                          NeubrutalismContainer(
                            borderRadius: 20,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const Text(
                                  'Join the Fun!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: darkBorderColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Local Game v1.0.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: darkBorderColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingRow(
    String label,
    bool value,
    Function(bool) onChanged,
    Color darkBorderColor,
    Color accentOrange,
  ) {
    return NeubrutalismContainer(
      borderRadius: 20,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBorderColor,
            ),
          ),
          Switch(
            value: value,
            activeColor: accentOrange,
            activeTrackColor: accentOrange.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
