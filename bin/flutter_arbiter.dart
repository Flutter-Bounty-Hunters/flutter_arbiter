import 'package:static_shock/static_shock.dart';

Future<void> main(List<String> arguments) async {
  final isPreviewMode = arguments.contains("preview");

  // Configure the static website generator.
  final staticShock = StaticShock()
    // Here, you can directly hook into the StaticShock pipeline. For example,
    // you can copy an "images" directory from the source set to build set:
    ..pick(DirectoryPicker.parse("images"))
    ..pick(DirectoryPicker.parse("scripts"))
    ..pick(ExtensionPicker("css"))
    ..plugin(const MarkdownPlugin())
    ..plugin(const JinjaPlugin())
    ..plugin(const PrettyUrlsPlugin())
    ..plugin(const RedirectsPlugin())
    ..plugin(const SassPlugin())
    ..plugin(DraftingPlugin(
      showDrafts: isPreviewMode,
    ));

  // Generate the static website.
  await staticShock.generateSite();
}
