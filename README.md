# STQRYSVG

Renders SVG shapes and paths to UIImage objects.

Supports IBInspectable attributes on UIImageView for specifying SVG images in Interface Builder.

## API

### UIImage+STQRYSVG

```objc
+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename;
+ (instancetype)stqry_imageWithSVGNamed:(NSString *)filename size:(CGSize)size;
```

### UIImageView+STQRYSVG

```objc
@property (nonatomic, copy) IBInspectable NSString *svgImageName;
@property (nonatomic, assign) IBInspectable CGSize svgImageSize;
```
