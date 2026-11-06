#!/usr/bin/env ruby
# frozen_string_literal: true

# Attach the CleartrayInboxWidget (WidgetKit) and ShareExtension targets to
# Runner.xcodeproj, plus the capture-anywhere / Today widget sources and
# localizations (ADR 0009). Idempotent — running twice is a no-op.
#
# Run from the repo root:
#   ruby ios/scripts/add_extensions.rb
#
# Requires the `xcodeproj` gem (ships with CocoaPods).

require 'xcodeproj'
require 'pathname'

IOS_DIR        = Pathname.new(File.expand_path('..', __dir__))
PROJECT_PATH   = IOS_DIR.join('Runner.xcodeproj')
BASE_BUNDLE_ID = 'app.cleartray'
DEV_TEAM       = '368WCFCZ65'

project = Xcodeproj::Project.open(PROJECT_PATH.to_s)
runner  = project.targets.find { |t| t.name == 'Runner' } or
  abort("Could not find Runner target in #{PROJECT_PATH}")

# --- 1. Wire Runner.entitlements into Runner if it isn't already ----------

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] ||= 'Runner/Runner.entitlements'
end

runner_group = project.main_group['Runner']
unless runner_group.files.any? { |f| f.path == 'Runner.entitlements' }
  runner_group.new_reference('Runner.entitlements')
end

# --- 2. Helpers -----------------------------------------------------------

def ensure_group(project, name)
  project.main_group[name] || project.main_group.new_group(name, name)
end

def add_app_extension_target(project, name, bundle_suffix, deployment_target, dev_team)
  target = project.targets.find { |t| t.name == name }
  # Settings are seeded only on creation: existing targets carry later
  # hand-tuned settings (e.g. versions from AppExtensionVersion.xcconfig).
  return target if target

  target = project.new_target(
    :app_extension,
    name,
    :ios,
    deployment_target,
    nil,
    :swift
  )

  target.build_configurations.each do |config|
    settings = config.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER']       = "#{BASE_BUNDLE_ID}.#{bundle_suffix}"
    settings['PRODUCT_NAME']                    = '$(TARGET_NAME)'
    settings['INFOPLIST_FILE']                  = "#{name}/Info.plist"
    settings['CODE_SIGN_ENTITLEMENTS']          = "#{name}/#{name}.entitlements"
    settings['CODE_SIGN_STYLE']                 = 'Automatic'
    settings['DEVELOPMENT_TEAM']                = dev_team
    settings['SWIFT_VERSION']                   = '5.0'
    settings['IPHONEOS_DEPLOYMENT_TARGET']      = deployment_target
    settings['TARGETED_DEVICE_FAMILY']          = '1,2'
    settings['SKIP_INSTALL']                    = 'YES'
    settings['MARKETING_VERSION']               = '1.0'
    settings['CURRENT_PROJECT_VERSION']         = '1'
    settings['GENERATE_INFOPLIST_FILE']         = 'NO'
    settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
  end

  target
end

def add_file_to_target(project, target, group, relative_path, build: :sources)
  ref = group.files.find { |f| f.path == relative_path } ||
        group.new_reference(relative_path)
  case build
  when :sources
    unless target.source_build_phase.files_references.include?(ref)
      target.source_build_phase.add_file_reference(ref)
    end
  when :resources
    unless target.resources_build_phase.files_references.include?(ref)
      target.resources_build_phase.add_file_reference(ref)
    end
  when :none
    # File reference only (Info.plist, entitlements) — Xcode picks these up via
    # build settings, not build phases.
  end
  ref
end

LOCALES = %w[en de es fr ja ko pt ru zh-Hans zh-Hant].freeze

# Adds `<locale>.lproj/<name>` files under a variant group in [group] and the
# group to [target]'s resources.
def add_localized_resource(target, group, name)
  variant = group.children.find do |c|
    c.is_a?(Xcodeproj::Project::Object::PBXVariantGroup) && c.name == name
  end
  variant ||= group.new_variant_group(name)
  LOCALES.each do |locale|
    path = "#{locale}.lproj/#{name}"
    next if variant.files.any? { |f| f.path == path }

    ref = variant.new_reference(path)
    ref.name = locale
    ref.last_known_file_type = 'text.plist.strings'
  end
  unless target.resources_build_phase.files_references.include?(variant)
    target.resources_build_phase.add_file_reference(variant)
  end
end

def embed_extension_in_host(project, host_target, ext_target)
  phase = host_target.copy_files_build_phases.find do |p|
    p.symbol_dst_subfolder_spec == :plug_ins
  end
  if phase.nil?
    phase = host_target.new_copy_files_build_phase('Embed App Extensions')
    phase.symbol_dst_subfolder_spec = :plug_ins

    # Xcode runs "Embed App Extensions" before the "Thin Binary" / Pods
    # scripts. If we leave it at the end of the build phases list, the .appex
    # copy ends up depending on Thin Binary, which itself depends on
    # Info.plist (which depends on the .appex) → build graph cycle.
    # Insert it directly before the first shell script phase.
    host_target.build_phases.delete(phase)
    first_script_idx = host_target.build_phases.index do |bp|
      bp.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
        bp.name == 'Thin Binary'
    end
    insert_at = first_script_idx || host_target.build_phases.length
    host_target.build_phases.insert(insert_at, phase)
  end

  product_ref = ext_target.product_reference
  unless phase.files_references.include?(product_ref)
    build_file = phase.add_file_reference(product_ref)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
  end

  unless host_target.dependencies.any? { |d| d.target == ext_target }
    host_target.add_dependency(ext_target)
  end
end

# --- 3. CleartrayInboxWidget target ---------------------------------------

widget_group = ensure_group(project, 'CleartrayInboxWidget')
widget_target = add_app_extension_target(
  project,
  'CleartrayInboxWidget',
  'CleartrayInboxWidget',
  '16.0',
  DEV_TEAM
)

add_file_to_target(project, widget_target, widget_group, 'CleartrayInboxWidget.swift', build: :sources)
%w[TrayzeroWidgets.swift TrayzeroTodayWidget.swift TrayzeroCaptureControl.swift].each do |file|
  add_file_to_target(project, widget_target, widget_group, file, build: :sources)
end
add_localized_resource(widget_target, widget_group, 'Localizable.strings')
add_file_to_target(project, widget_target, widget_group, 'Info.plist', build: :none)
add_file_to_target(project, widget_target, widget_group, 'CleartrayInboxWidget.entitlements', build: :none)

# Frameworks: WidgetKit + SwiftUI (linked weakly is fine but Xcode default is strong)
['WidgetKit.framework', 'SwiftUI.framework'].each do |fw|
  widget_target.add_system_framework(fw.sub('.framework', ''))
end

embed_extension_in_host(project, runner, widget_target)

# --- 4. ShareExtension target ---------------------------------------------

share_group = ensure_group(project, 'ShareExtension')
share_target = add_app_extension_target(
  project,
  'ShareExtension',
  'ShareExtension',
  '15.0', # UTType API needs iOS 14+; App Store requires 15.0+ (ITMS-90068)
  DEV_TEAM
)

add_file_to_target(project, share_target, share_group, 'ShareViewController.swift', build: :sources)
add_file_to_target(project, share_target, share_group, 'MainInterface.storyboard', build: :resources)
add_file_to_target(project, share_target, share_group, 'Info.plist', build: :none)
add_file_to_target(project, share_target, share_group, 'ShareExtension.entitlements', build: :none)

['Social', 'MobileCoreServices', 'UniformTypeIdentifiers', 'UIKit'].each do |fw|
  share_target.add_system_framework(fw)
end

embed_extension_in_host(project, runner, share_target)

# --- 5. Capture anywhere (ADR 0009) ----------------------------------------

# App Group store and the app-opening intents, compiled into both Runner and
# the widget extension (the Control Center control runs them).
shared_group = ensure_group(project, 'TrayzeroShared')
%w[TrayzeroShared.swift TrayzeroOpenIntents.swift].each do |file|
  [runner, widget_target].each do |target|
    add_file_to_target(project, target, shared_group, file, build: :sources)
  end
end

%w[LaunchLinkRelay.swift TrayzeroAppIntents.swift].each do |file|
  add_file_to_target(project, runner, runner_group, file, build: :sources)
end
add_localized_resource(runner, runner_group, 'Localizable.strings')
add_localized_resource(runner, runner_group, 'AppShortcuts.strings')

LOCALES.each do |locale|
  project.root_object.known_regions << locale unless project.root_object.known_regions.include?(locale)
end

# --- 6. Save -------------------------------------------------------------

project.save
puts "Wrote #{PROJECT_PATH}"
puts "Targets now in project: #{project.targets.map(&:name).join(', ')}"
