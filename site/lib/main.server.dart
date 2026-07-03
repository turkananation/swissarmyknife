/// Static Jaspr documentation site for SwissArmyKnife.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/sidebar.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

import 'components/site_header.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    ContentApp(
      eagerlyLoadAllPages: true,
      templateEngine: MustacheTemplateEngine(),
      parsers: [MarkdownParser()],
      extensions: [HeadingAnchorsExtension(), TableOfContentsExtension()],
      components: [Callout(), Image(zoom: true)],
      layouts: [
        DocsLayout(
          header: const SiteHeader(),
          sidebar: const Sidebar(
            groups: [
              SidebarGroup(
                links: [SidebarLink(text: 'Overview', href: './')],
              ),
              SidebarGroup(
                title: 'Package',
                links: [
                  SidebarLink(text: 'Getting Started', href: 'getting-started'),
                  SidebarLink(text: 'API Guide', href: 'api'),
                  SidebarLink(text: 'Cookbook', href: 'cookbook'),
                  SidebarLink(text: 'Platform Support', href: 'platform'),
                ],
              ),
              SidebarGroup(
                title: 'Release',
                links: [SidebarLink(text: 'v0.1.0 Release', href: 'release')],
              ),
            ],
          ),
          footer: footer(classes: 'site-footer', [
            p([
              Component.text(
                'SwissArmyKnife v0.1.0. Built with Dart and Jaspr. ',
              ),
              a(
                href: 'https://github.com/turkananation/swissarmyknife',
                target: Target.blank,
                [Component.text('GitHub')],
              ),
            ]),
          ]),
        ),
      ],
      theme: ContentTheme(
        primary: ThemeColor(
          ThemeColors.emerald.$700,
          dark: ThemeColors.emerald.$300,
        ),
        background: ThemeColor(Color('#fbfaf7'), dark: ThemeColors.zinc.$950),
        text: ThemeColor(ThemeColors.zinc.$700, dark: ThemeColors.zinc.$200),
        colors: [
          ContentColors.links.apply(
            ThemeColor(
              ThemeColors.emerald.$700,
              dark: ThemeColors.emerald.$300,
            ),
          ),
          ContentColors.quoteBorders.apply(
            ThemeColor(ThemeColors.amber.$400, dark: ThemeColors.amber.$300),
          ),
          ContentColors.preBg.apply(
            ThemeColor(Color('#111827'), dark: Color('#020617')),
          ),
        ],
      ),
    ),
  );
}
