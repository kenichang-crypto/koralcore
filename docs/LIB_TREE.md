# lib 目錄樹狀結構（全部展開）

```
lib
├── app
│   ├── common
│   │   ├── app_context.dart
│   │   ├── app_error.dart
│   │   ├── app_error_code.dart
│   │   ├── app_error_mapper.dart
│   │   ├── app_result.dart
│   │   ├── app_session.dart
│   ├── debug
│   │   ├── ble_transport_debug_playbook.dart
│   ├── device
│   │   ├── add_device_usecase.dart
│   │   ├── connect_device.dart
│   │   ├── connect_device_usecase.dart
│   │   ├── device_connection_coordinator.dart
│   │   ├── device_snapshot.dart
│   │   ├── disconnect_device.dart
│   │   ├── disconnect_device_usecase.dart
│   │   ├── discover_device.dart
│   │   ├── initialize_device_usecase.dart
│   │   ├── remove_device_usecase.dart
│   │   ├── scan_devices_usecase.dart
│   │   ├── switch_current_device_usecase.dart
│   │   ├── sync_device_state.dart
│   │   ├── toggle_favorite_device_usecase.dart
│   │   ├── update_device_name_usecase.dart
│   │   ├── update_device_sink_usecase.dart
│   ├── doser
│   │   ├── apply_schedule_usecase.dart
│   │   ├── manual_dose.dart
│   │   ├── observe_dosing_state_usecase.dart
│   │   ├── read_calibration_history.dart
│   │   ├── read_dosing_schedule_summary_usecase.dart
│   │   ├── read_dosing_state_usecase.dart
│   │   ├── read_schedule.dart
│   │   ├── read_today_total.dart
│   │   ├── reset_dosing_state_usecase.dart
│   │   ├── schedule_capability_guard.dart
│   │   ├── schedule_result.dart
│   │   ├── schedule_result_mapper.dart
│   │   ├── set_calibration.dart
│   │   ├── set_dosing_schedule.dart
│   │   ├── set_pump_speed.dart
│   │   ├── single_dose_immediate_usecase.dart
│   │   ├── single_dose_timed_usecase.dart
│   │   ├── update_pump_head_settings.dart
│   ├── led
│   │   ├── add_scene_usecase.dart
│   │   ├── apply_led_schedule_usecase.dart
│   │   ├── apply_scene_usecase.dart
│   │   ├── clear_led_records_usecase.dart
│   │   ├── delete_led_record_usecase.dart
│   │   ├── delete_scene_usecase.dart
│   │   ├── enter_dimming_mode_usecase.dart
│   │   ├── enter_led_usecase.dart
│   │   ├── exit_dimming_mode_usecase.dart
│   │   ├── init_led_record_usecase.dart
│   │   ├── led_record_guard.dart
│   │   ├── led_schedule_capability_guard.dart
│   │   ├── led_schedule_result.dart
│   │   ├── led_schedule_result_mapper.dart
│   │   ├── lighting_state_store.dart
│   │   ├── observe_led_record_state_usecase.dart
│   │   ├── observe_led_state_usecase.dart
│   │   ├── read_led_record_state_usecase.dart
│   │   ├── read_led_scenes.dart
│   │   ├── read_led_schedule_summary_usecase.dart
│   │   ├── read_led_schedules.dart
│   │   ├── read_led_state_usecase.dart
│   │   ├── read_lighting_state.dart
│   │   ├── refresh_led_record_state_usecase.dart
│   │   ├── reset_led_state_usecase.dart
│   │   ├── save_led_schedule_usecase.dart
│   │   ├── set_channel_intensity.dart
│   │   ├── set_led_schedule.dart
│   │   ├── start_led_preview_usecase.dart
│   │   ├── start_led_record_usecase.dart
│   │   ├── stop_led_preview_usecase.dart
│   │   ├── update_scene_usecase.dart
│   ├── lifecycle
│   │   ├── bootstrap_app.dart
│   ├── main_scaffold.dart
│   ├── main_shell_page.dart
│   ├── navigation_controller.dart
│   ├── result
│   │   ├── app_error.dart
│   │   ├── app_result.dart
│   │   ├── app_warning.dart
│   ├── session
│   │   ├── current_device_session.dart
│   ├── system
│   │   ├── ble_readiness_controller.dart
│   │   ├── check_firmware_capability.dart
│   │   ├── read_capability.dart
│   │   ├── read_device_info.dart
│   │   ├── read_firmware_version.dart
│   │   ├── reboot_device.dart
│   │   ├── reset_device.dart
│   │   ├── start_firmware_update.dart
│   │   ├── sync_time.dart
├── core
│   ├── ble
│   │   ├── ble_guard.dart
│   │   ├── ble_readiness_controller.dart
│   ├── errors
│   │   ├── core_error.dart
│   ├── extensions
│   │   ├── bool_extensions.dart
│   │   ├── byte_array_extensions.dart
│   │   ├── int_extensions.dart
│   ├── result
│   │   ├── error_code.dart
│   │   ├── failure.dart
│   │   ├── failure_type.dart
│   │   ├── result.dart
│   │   ├── result_extensions.dart
│   │   ├── success.dart
│   ├── time
│   │   ├── clock.dart
│   │   ├── errors.dart
│   │   ├── fixed_clock.dart
│   │   ├── instant.dart
│   │   ├── system_clock.dart
│   │   ├── time_provider.dart
├── data
│   ├── ble
│   │   ├── ble_adapter.dart
│   │   ├── ble_adapter_impl.dart
│   │   ├── ble_adapter_stub.dart
│   │   ├── ble_container.dart
│   │   ├── ble_notify_bus.dart
│   │   ├── ble_scan_service.dart
│   │   ├── ble_uuid.dart
│   │   ├── debug
│   │   │   ├── ble_record.dart
│   │   │   ├── ble_record_type.dart
│   │   │   ├── ble_recorder.dart
│   │   │   ├── ble_recorder_impl.dart
│   │   │   ├── ble_replay.dart
│   │   │   ├── ble_replay_runner.dart
│   │   │   ├── custom_schedule_debug_samples.dart
│   │   │   ├── custom_schedule_encoder_0x72_debug.dart
│   │   │   ├── custom_schedule_encoder_0x73_debug.dart
│   │   │   ├── custom_schedule_encoder_0x74_debug.dart
│   │   │   ├── daily_average_schedule_encoder_debug.dart
│   │   │   ├── led_schedule_debug.dart
│   │   │   ├── timed_single_dose_encoder_debug.dart
│   │   ├── device_name_filter.dart
│   │   ├── doser
│   │   │   ├── ble_today_totals_data_source.dart
│   │   │   ├── today_totals_data_source.dart
│   │   ├── dosing
│   │   │   ├── dosing_command_builder.dart
│   │   ├── encoder
│   │   │   ├── doser
│   │   │   │   ├── immediate_single_dose_encoder.dart
│   │   │   ├── led
│   │   │   │   ├── led_custom_schedule_encoder.dart
│   │   │   │   ├── led_daily_schedule_encoder.dart
│   │   │   │   ├── led_encoding_utils.dart
│   │   │   │   ├── led_opcodes.dart
│   │   │   │   ├── led_scene_schedule_encoder.dart
│   │   │   │   ├── led_schedule_encoder.dart
│   │   │   ├── schedule
│   │   │   │   ├── custom_schedule_chunk_encoder.dart
│   │   │   │   ├── custom_schedule_encoder_0x72.dart
│   │   │   │   ├── custom_schedule_encoder_0x73.dart
│   │   │   │   ├── custom_schedule_encoder_0x74.dart
│   │   │   │   ├── daily_average_schedule_encoder.dart
│   │   ├── led
│   │   │   ├── led_command_builder.dart
│   │   ├── platform_channels
│   │   │   ├── ble_notify_packet.dart
│   │   │   ├── ble_platform_transport_writer.dart
│   │   ├── record
│   │   │   ├── ble_record.dart
│   │   │   ├── ble_record_type.dart
│   │   │   ├── ble_recorder.dart
│   │   │   ├── ble_recorder_impl.dart
│   │   ├── replay
│   │   │   ├── ble_replay.dart
│   │   │   ├── ble_replay_runner.dart
│   │   ├── response
│   │   │   ├── ble_error_code.dart
│   │   │   ├── ble_response.dart
│   │   │   ├── ble_response_parser.dart
│   │   ├── schedule
│   │   │   ├── custom_schedule_builder.dart
│   │   │   ├── h24_schedule_builder.dart
│   │   │   ├── led
│   │   │   │   ├── led_custom_schedule_builder.dart
│   │   │   │   ├── led_daily_schedule_builder.dart
│   │   │   │   ├── led_scene_schedule_builder.dart
│   │   │   │   ├── led_schedule_command_builder.dart
│   │   │   │   ├── led_schedule_encoder.dart
│   │   │   │   ├── led_schedule_payload.dart
│   │   │   ├── oneshot_schedule_builder.dart
│   │   │   ├── schedule_sender.dart
│   │   ├── transport
│   │   │   ├── ble_read_transport.dart
│   │   │   ├── ble_transport_log_buffer.dart
│   │   │   ├── ble_transport_models.dart
│   │   ├── verification
│   │   │   ├── ble_golden_capture.dart
│   │   │   ├── encoder_verifier.dart
│   │   │   ├── golden_payloads.dart
│   ├── database
│   │   ├── database_helper.dart
│   ├── dosing
│   │   ├── ble_dosing_repository_impl.dart
│   ├── led
│   │   ├── ble_led_repository_impl.dart
│   │   ├── koralcore.code-workspace
│   ├── mappers
│   │   ├── device_mapper.dart
│   │   ├── doser_mapper.dart
│   │   ├── lighting_mapper.dart
│   ├── repositories
│   │   ├── device_repository_impl.dart
│   │   ├── doser_repository_impl.dart
│   │   ├── drop_type_repository_impl.dart
│   │   ├── favorite_repository_impl.dart
│   │   ├── lighting_repository_impl.dart
│   │   ├── pump_head_repository_impl.dart
│   │   ├── scene_repository_impl.dart
│   │   ├── schedule_repository_impl.dart
│   │   ├── sink_repository_impl.dart
│   │   ├── system_repository_impl.dart
│   │   ├── warning_repository_impl.dart
│   ├── storage
│   │   ├── local_storage_stub.dart
│   ├── time
│   │   ├── system_time_adapter.dart
├── domain
│   ├── command
│   │   ├── command.dart
│   │   ├── command_error.dart
│   │   ├── command_progress.dart
│   │   ├── command_result.dart
│   │   ├── command_state.dart
│   ├── device
│   │   ├── capability
│   │   │   ├── capability.dart
│   │   │   ├── capability_error.dart
│   │   │   ├── capability_id.dart
│   │   │   ├── capability_registry.dart
│   │   │   ├── capability_snapshot.dart
│   │   │   ├── capability_state.dart
│   │   ├── capability_set.dart
│   │   ├── device_context.dart
│   │   ├── device_product.dart
│   │   ├── device_product_resolver.dart
│   │   ├── firmware_version.dart
│   │   ├── identity
│   │   │   ├── device_id.dart
│   │   ├── registry
│   │   │   ├── capability_registry.dart
│   ├── doser_dosing
│   │   ├── custom_window_schedule_definition.dart
│   │   ├── daily_average_schedule_definition.dart
│   │   ├── dose_distribution.dart
│   │   ├── dose_value.dart
│   │   ├── doser_schedule.dart
│   │   ├── doser_schedule_type.dart
│   │   ├── doser_schedule_validator.dart
│   │   ├── dosing_constraints.dart
│   │   ├── dosing_schedule_summary.dart
│   │   ├── dosing_state.dart
│   │   ├── encoder
│   │   │   ├── single_dose_encoding_utils.dart
│   │   │   ├── timed_single_dose_encoder.dart
│   │   ├── pump_head.dart
│   │   ├── pump_head_adjust_history.dart
│   │   ├── pump_head_mode.dart
│   │   ├── pump_head_record_detail.dart
│   │   ├── pump_head_record_type.dart
│   │   ├── pump_speed.dart
│   │   ├── schedule.dart
│   │   ├── schedule_repeat.dart
│   │   ├── schedule_time_models.dart
│   │   ├── schedule_validator.dart
│   │   ├── schedule_weekday.dart
│   │   ├── scheduled_dose_trigger.dart
│   │   ├── single_dose_immediate.dart
│   │   ├── single_dose_plan.dart
│   │   ├── single_dose_timed.dart
│   │   ├── time_of_day.dart
│   │   ├── today_dose_summary.dart
│   │   ├── weekday.dart
│   ├── drop_type
│   │   ├── drop_type.dart
│   ├── errors
│   │   ├── domain_error.dart
│   ├── led
│   │   ├── spectrum
│   │   │   ├── spectrum.dart
│   │   │   ├── spectrum_calculator.dart
│   ├── led_lighting
│   │   ├── led_channel.dart
│   │   ├── led_channel_group.dart
│   │   ├── led_channel_value.dart
│   │   ├── led_custom_schedule.dart
│   │   ├── led_daily_schedule.dart
│   │   ├── led_intensity.dart
│   │   ├── led_record.dart
│   │   ├── led_record_state.dart
│   │   ├── led_scene.dart
│   │   ├── led_scene_schedule.dart
│   │   ├── led_schedule.dart
│   │   ├── led_schedule_overview.dart
│   │   ├── led_schedule_type.dart
│   │   ├── led_spectrum.dart
│   │   ├── led_state.dart
│   │   ├── lighting_schedule.dart
│   │   ├── lighting_state.dart
│   │   ├── scene_catalog.dart
│   │   ├── scene_channel_inspector.dart
│   │   ├── time_of_day.dart
│   │   ├── weekday.dart
│   ├── sink
│   │   ├── sink.dart
│   │   ├── sink_with_devices.dart
│   ├── usecases
│   │   ├── doser
│   │   │   ├── (18 usecase files - same as app/doser)
│   │   ├── led
│   │   │   ├── (28 usecase files - same as app/led)
│   ├── warning
│   │   ├── warning.dart
├── features
│   ├── bluetooth
│   │   └── presentation/pages/bluetooth_tab_page.dart
│   ├── device
│   │   └── presentation (controllers, pages, widgets)
│   ├── doser
│   │   └── presentation (controllers, models, pages, widgets)
│   ├── home
│   │   └── presentation (controllers, pages)
│   ├── led
│   │   ├── data/spectrum
│   │   ├── domain/models/spectrum, services
│   │   └── presentation (controllers, helpers, models, pages, widgets)
│   ├── sink
│   │   └── presentation (controllers, pages)
│   ├── splash
│   │   └── presentation/pages/splash_page.dart
│   └── warning
│       └── presentation (controllers, pages)
├── l10n
│   ├── app_localizations*.dart (15 files)
│   └── intl_*.arb (18 files)
├── main.dart
├── platform
│   ├── capability_registry.dart
│   └── contracts (11 repository/port contracts)
├── shared
│   ├── assets (icons)
│   ├── theme (app/reef colors, radius, spacing, text, theme)
│   └── widgets (dialogs, cards, overlays, etc.)
└── test
    └── domain/dosing/dosing_rules_test.dart
```

共 611 個項目（目錄與檔案）。  
若需某個子目錄的細部展開，可指定路徑再產生。
