#include "screenshot_guard_plugin_main.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <iostream>  // For logging

// Function to prevent screen capture
void PreventScreenCapture(HWND hwnd) {
  if (SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)) {
    std::cout << "Screen capture protection applied successfully." << std::endl;
  } else {
    std::cerr << "Failed to apply screen capture protection. Error: " 
              << GetLastError() << std::endl;
  }
}

namespace screenshot_guard {

// static
void ScreenshotGuardPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "screenshot_guard",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ScreenshotGuardPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

ScreenshotGuardPlugin::ScreenshotGuardPlugin() {}

ScreenshotGuardPlugin::~ScreenshotGuardPlugin() {}

void ScreenshotGuardPlugin::ResetSecureFlag() {
  HWND hwnd = GetForegroundWindow();
  if (!hwnd) {
    std::cerr << "Failed to get the window handle during ResetSecureFlag" << std::endl;
    return;
  }

  if (lastState) {
    if (SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)) {
      std::cout << "Screen capture protection reapplied during reset." << std::endl;
    } else {
      std::cerr << "Failed to reapply screen capture protection during reset. Error: " 
                << GetLastError() << std::endl;
    }
  } else {
    if (SetWindowDisplayAffinity(hwnd, WDA_NONE)) {
      std::cout << "Screen capture protection removed during reset." << std::endl;
    } else {
      std::cerr << "Failed to remove screen capture protection during reset. Error: " 
                << GetLastError() << std::endl;
    }
  }
}

void ScreenshotGuardPlugin::HandleMethodCall(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("enableSecureFlag") == 0) {
      const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (!arguments) {
        result->Error("BAD_ARGUMENTS", "Expected map arguments");
        return;
      }
      
      auto enable_it = arguments->find(flutter::EncodableValue("enable"));
      if (enable_it == arguments->end()) {
        result->Error("BAD_ARGUMENTS", "Missing 'enable' key in map arguments");
        return;
      }

      const auto* enable_value = std::get_if<bool>(&enable_it->second);
      if (!enable_value) {
        result->Error("BAD_ARGUMENTS", "Expected a boolean 'enable' argument.");
        return;
      }

      bool enable = *enable_value;

      // Utilisez la variable membre lastState au lieu de déclarer une variable locale
      this->lastState = enable;  // Assurez-vous que lastState est bien une variable membre de la classe

      // Get the window handle
      HWND hwnd = GetForegroundWindow();
      if (!hwnd) {
        result->Error("NO_WINDOW", "Failed to get the window handle");
        return;
      }

      if (enable) {
        // Apply the screen capture protection
        if (SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)) {
          result->Success(flutter::EncodableValue("Screen capture protection enabled"));
        } else {
          result->Error("SET_WINDOW_DISPLAY_AFFINITY_FAILED",
                        "Failed to apply screen capture protection",
                        flutter::EncodableValue(static_cast<int>(GetLastError())));
        }
      } else {
        // Remove the screen capture protection
        if (SetWindowDisplayAffinity(hwnd, WDA_NONE)) {
          result->Success(flutter::EncodableValue("Screen capture protection disabled"));
        } else {
          result->Error("SET_WINDOW_DISPLAY_AFFINITY_FAILED",
                        "Failed to remove screen capture protection",
                        flutter::EncodableValue(static_cast<int>(GetLastError())));
        }
      }
    } else if (method_call.method_name().compare("resetSecureFlag") == 0) {
      ResetSecureFlag();
      result->Success(flutter::EncodableValue("Screen capture protection refreshed"));
    } else if (method_call.method_name().compare("getPlatformVersion") == 0) {
      std::ostringstream version_stream;
      version_stream << "Windows ";

      if (IsWindows10OrGreater()) {
        version_stream << "10+";
      } else if (IsWindows8OrGreater()) {
        version_stream << "8";
      } else if (IsWindows7OrGreater()) {
        version_stream << "7";
      }
      
      result->Success(flutter::EncodableValue(version_stream.str()));
    } else {
      result->NotImplemented();
    }
}

} // namespace screenshot_guard
