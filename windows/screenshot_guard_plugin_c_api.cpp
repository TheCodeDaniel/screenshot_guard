#include "include/screenshot_guard/screenshot_guard_plugin.h"

#include <flutter/plugin_registrar_windows.h>

#include "screenshot_guard_plugin_main.h"

void ScreenshotGuardPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  screenshot_guard::ScreenshotGuardPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
