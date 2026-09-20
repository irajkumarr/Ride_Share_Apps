/// Barrel file for shared_core library.
///
/// Exports all core modules, configurations, models, services, and UI components
/// intended for consumption across rider_app and driver_app.
library shared_core;

// ── Common ──────────────────────────────────────────────────────────────────
export 'common/bloc/app_bloc_observer.dart';
export 'common/extensions/extensions.dart';
export 'common/mixins/form_mixin.dart';
export 'common/validators/validators.dart';

// ── Configuration ───────────────────────────────────────────────────────────
export 'config/env/environment.dart';
export 'config/flavor/flavor_config.dart';
export 'config/global/app_global.dart';
export 'config/theme/app_theme.dart';
export 'config/theme/theme_extensions/app_colors_extension.dart';
export 'config/theme/widget_themes/appbar_theme.dart';
export 'config/theme/widget_themes/bottom_sheet_theme.dart';
export 'config/theme/widget_themes/checkbox_theme.dart';
export 'config/theme/widget_themes/chip_theme.dart';
export 'config/theme/widget_themes/elevated_button_theme.dart';
export 'config/theme/widget_themes/outlined_button_theme.dart';
export 'config/theme/widget_themes/text_field_theme.dart';
export 'config/theme/widget_themes/text_theme.dart';

// ── Models ──────────────────────────────────────────────────────────────────
export 'models/location/address_model.dart';
export 'models/location/lat_lng_model.dart';
export 'models/location/route_model.dart';

// ── Core Infrastructure ─────────────────────────────────────────────────────
// Analytics
export 'core/analytics/analytics_event.dart';
export 'core/analytics/analytics_observer.dart';
export 'core/analytics/analytics_parameter.dart';
export 'core/analytics/analytics_service.dart';

// API & Network
export 'core/api/api_client.dart';
export 'core/api/api_response.dart';
export 'core/api/dio_client.dart';
export 'core/api/interceptors/auth_interceptor.dart';
export 'core/api/interceptors/error_interceptor.dart';
export 'core/api/interceptors/logging_interceptor.dart';
export 'core/api/interceptors/retry_interceptor.dart';
export 'core/network/network_info.dart';

// Cache & Storage
export 'core/cache/hive_cache_service.dart';
export 'core/storage/local_storage_service.dart';
export 'core/storage/secure_storage_service.dart';

// Deep Linking
export 'core/config/deeplink/app_deep_link_service.dart';

// Dependency Injection
export 'core/di/injection.dart';

// Error & Failures
export 'core/error/error_mapper.dart';
export 'core/error/exceptions.dart';
export 'core/error/failures.dart';

// Helpers
export 'core/helpers/format_number.dart';
export 'core/helpers/show_app_sheet.dart';
export 'core/helpers/show_dialog.dart';

// Manager
export 'core/manager/firebase_manager.dart';

// Routing
export 'core/routing/app_route_observer.dart';
export 'core/routing/app_router.dart';
export 'core/routing/app_routes.dart';

// Usecase Base
export 'core/usecase/usecase.dart';

// Utils
export 'core/utils/ad_helper.dart';
export 'core/utils/api_urls.dart';
export 'core/utils/app_alerts.dart';
export 'core/utils/app_constants.dart';
export 'core/utils/app_logger.dart';
export 'core/utils/app_utils.dart';
export 'core/utils/base_bloc.dart';
export 'core/utils/base_cubit.dart';
export 'core/utils/colors.dart';
export 'core/utils/custom_image.dart';
export 'core/utils/debouncer.dart';
export 'core/utils/font.dart';
export 'core/utils/input_formatters.dart';
export 'core/utils/loading_overlay.dart';
export 'core/utils/map_utils.dart';
export 'core/utils/media_picker_service.dart';
export 'core/utils/pagination.dart';
export 'core/utils/platform_info.dart';
export 'core/utils/push_notification_service.dart';
export 'core/utils/responsive_size.dart';
export 'core/utils/toast_overlay.dart';
export 'core/utils/typedefs.dart';
export 'core/utils/ui_utils.dart';

// ── Core UI (Blocs & Widgets) ────────────────────────────────────────────────
// Blocs
export 'core/ui/blocs/network_cubit.dart';
export 'core/ui/blocs/pagination_cubit.dart';

// Widgets
export 'core/ui/widgets/app_image.dart';
export 'core/ui/widgets/app_state_wrapper.dart';
export 'core/ui/widgets/app_version_builder.dart';
export 'core/ui/widgets/bottom_sheet_layout.dart';
export 'core/ui/widgets/country_picker_bottom_sheet.dart';
export 'core/ui/widgets/custom_appbar.dart';
export 'core/ui/widgets/custom_button.dart';
export 'core/ui/widgets/custom_cached_network_image.dart';
export 'core/ui/widgets/custom_checkbox.dart';
export 'core/ui/widgets/custom_circular_avatar.dart';
export 'core/ui/widgets/custom_circular_progress_indicator.dart';
export 'core/ui/widgets/custom_container.dart';
export 'core/ui/widgets/custom_countdown.dart';
export 'core/ui/widgets/custom_dialog_layout.dart';
export 'core/ui/widgets/custom_divider.dart';
export 'core/ui/widgets/custom_inkwell_container.dart';
export 'core/ui/widgets/custom_loader.dart';
export 'core/ui/widgets/custom_map_view.dart';
export 'core/ui/widgets/custom_radio_button.dart';
export 'core/ui/widgets/custom_refresh_indicator.dart';
export 'core/ui/widgets/custom_scroll_behavior.dart';
export 'core/ui/widgets/custom_sized_box.dart';
export 'core/ui/widgets/custom_step_indicator.dart';
export 'core/ui/widgets/custom_svg_picture.dart';
export 'core/ui/widgets/custom_switch.dart';
export 'core/ui/widgets/custom_system_overlay.dart';
export 'core/ui/widgets/custom_tab_bar.dart';
export 'core/ui/widgets/custom_text.dart';
export 'core/ui/widgets/custom_textfield.dart';
export 'core/ui/widgets/custom_tooltip.dart';
export 'core/ui/widgets/dismiss_focus_overlay.dart';
export 'core/ui/widgets/dotted_border_container.dart';
export 'core/ui/widgets/double_back_to_close_wrapper.dart';
export 'core/ui/widgets/empty_view.dart';
export 'core/ui/widgets/flush_bar.dart';
export 'core/ui/widgets/gap.dart';
export 'core/ui/widgets/header_widget.dart';
export 'core/ui/widgets/language_picker_bottom_sheet.dart';
export 'core/ui/widgets/logout_account_dialog.dart';
export 'core/ui/widgets/media_picker_bottom_sheet.dart';
export 'core/ui/widgets/no_internet_screen.dart';
export 'core/ui/widgets/otp_input_widget.dart';
export 'core/ui/widgets/paginated_list_view.dart';
export 'core/ui/widgets/responsive_layout.dart';
export 'core/ui/widgets/rounded_widget.dart';
export 'core/ui/widgets/scrolling_text.dart';
export 'core/ui/widgets/shimmer_loader.dart';
export 'core/ui/widgets/vertical_tabs.dart';

// Common Widgets
export 'core/ui/widgets/common/animated_counter.dart' hide CountdownTimer;
export 'core/ui/widgets/common/badge_widget.dart';
export 'core/ui/widgets/common/dialog_widgets.dart';
export 'core/ui/widgets/common/rating_widget.dart';
export 'core/ui/widgets/common/section_header.dart';
export 'core/ui/widgets/common/skeleton_loader.dart';

// Image Slider Widgets
export 'core/ui/widgets/image_slider/image_slider.dart';

// Search Widget
export 'core/ui/widgets/search/search_widget.dart';

// ── Generated Assets & Fonts ────────────────────────────────────────────────
export 'gen/assets.gen.dart';
export 'gen/fonts.gen.dart';

// ── Services ────────────────────────────────────────────────────────────────
export 'services/location/location_service.dart';
export 'services/web_socket_service.dart';
