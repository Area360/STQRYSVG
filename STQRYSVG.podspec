Pod::Spec.new do |s|
    s.name                   = 'STQRYSVG'
    s.summary                = 'Renders SVG shapes and paths to UIImage objects. Supports IBInspectable for UIImageViews in Interface Builder.'
    s.platform               = :ios
    s.ios.deployment_target  = '7.0'
    s.version                = '0.0.1'
    s.homepage               = 'https://github.com/stqry/STQRYSVG'
    s.authors                = { 'Jake' => 'jake.bellamy@stqry.com' }
    s.license                = 'BSD'
    s.source                 = { :git => 'https://github.com/stqry/STQRYSVG.git', :tag => s.version }
    s.source_files           = 'STQRYSVG/**/*.{h,m}'
    s.requires_arc           = true

    s.ios.dependency 'PocketSVG', '~> 0.6'
end
