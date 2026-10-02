---
name: figma-to-flutter
description: Inspect Figma design frames, components, and variables via Figma MCP, and translate them into Material 3 Flutter widgets complying with LuminClash GEMINI.md rules.
---

# Figma to Flutter Translation Guide for LuminClash

This skill guides the agent in using the Figma MCP (Model Context Protocol) to inspect designs and convert them into high-quality, production-ready Flutter code following the **LuminClash architectural and design rules** (`GEMINI.md`).

---

## 1. Using Figma MCP Tools

When a user provides a Figma link (e.g., `https://www.figma.com/design/:fileId/:fileName?node-id=:nodeId`), use the Figma MCP server to extract the design context:

1. **Extract Context**: Call `get_design_context` with the Figma URL or node ID.
2. **Analyze Output**:
   - Hierarchy and layout (Auto-layout directions, padding, spacing, alignment).
   - Component names and variants.
   - Text styles and typography hierarchy.
   - Design tokens and variables (colors, corner radii, elevation).

---

## 2. Mapping Rules to LuminClash Standards (`GEMINI.md`)

When converting Figma designs to Flutter code in LuminClash, **strictly adhere to the following rules**:

### (1) Color & Theming: Never Hardcode Hex Colors
Figma designs may show specific hex values (e.g. `#1E2532` or `#6750A4`), but in LuminClash **all colors must use Monet semantic tokens**:

| Figma Element | LuminClash Semantic Token |
| :--- | :--- |
| Canvas / Screen Background | `Theme.of(context).colorScheme.surface` |
| Sidebar / Status Rail Background | `Theme.of(context).colorScheme.surfaceContainerLow` |
| Primary Content Cards | `Theme.of(context).colorScheme.surfaceContainer` |
| Elevated Cards / Dialogs | `Theme.of(context).colorScheme.surfaceContainerHigh` |
| Badges / Mini Capsules / Chips | `Theme.of(context).colorScheme.surfaceContainerHighest` |
| Borders & Dividers | `Theme.of(context).colorScheme.outlineVariant` |
| Primary Brand / Accent Actions | `Theme.of(context).colorScheme.primary` |
| Text / Icons on Primary | `Theme.of(context).colorScheme.onPrimary` |
| Secondary Container / Sub-accents | `Theme.of(context).colorScheme.secondaryContainer` |
| Secondary Container Text/Icons | `Theme.of(context).colorScheme.onSecondaryContainer` |
| Subdued Text / Captions | `Theme.of(context).colorScheme.onSurfaceVariant` |

### (2) Native Material 3 Expressive Components
Map Figma interactive components directly to Flutter M3 widgets:
- **Core Trigger / FAB**: Use `FloatingActionButton` (never custom painted pulse loops).
- **Mode Selectors / Segmented Tabs**: Use `SegmentedButton<T>`.
- **Progress / Gauges**: Use `LinearProgressIndicator` or `CircularProgressIndicator`.
- **Cards**: Use `Card` with `color: colorScheme.surfaceContainer` and zero or subtle elevation.
- **State Switchers / Flippers**: Use `AnimatedSwitcher` with `fade` or `scale` transitions.

### (3) Mobile & Desktop Ergonomics
- Wrap screens in `SafeArea(top: true, bottom: true)` to avoid cutouts and status bars.
- Single-line titles with `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
- Interactive primary touch points pushed toward the thumb comfort zone (lower portion of the screen).

---

## 3. Workflow Example

1. User sends: *"根据这个 Figma 设计实现节点测速卡片: https://www.figma.com/design/.../?node-id=10:24"*
2. Agent invokes Figma MCP's `get_design_context`.
3. Agent inspects layout constraints, padding, and child widgets.
4. Agent writes the Flutter widget in `lib/ui/widgets/` using M3 tokens and Riverpod state integration.
5. Agent verifies with `flutter analyze` and `flutter test`.
