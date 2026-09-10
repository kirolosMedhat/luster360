enum OverlayType { imagePng, text, logo, animated }

class OverlayItem {
  final String id;
  final OverlayType type;
  final String? content; // file path for image, string for text
  final double x; // normalized 0.0 to 1.0
  final double y; // normalized 0.0 to 1.0
  final double scale;
  final double rotationDegrees;
  final double opacity;
  final int zIndex;

  // Text specific styling
  final String? fontName;
  final double? fontSize;
  final int? textColorHex;

  const OverlayItem({
    required this.id,
    required this.type,
    this.content,
    this.x = 0.5,
    this.y = 0.5,
    this.scale = 1.0,
    this.rotationDegrees = 0.0,
    this.opacity = 1.0,
    this.zIndex = 0,
    this.fontName,
    this.fontSize,
    this.textColorHex,
  });

  OverlayItem copyWith({
    String? content,
    double? x,
    double? y,
    double? scale,
    double? rotationDegrees,
    double? opacity,
    int? zIndex,
  }) {
    return OverlayItem(
      id: id,
      type: type,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      fontName: fontName,
      fontSize: fontSize,
      textColorHex: textColorHex,
    );
  }
}
