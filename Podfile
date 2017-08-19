platform :ios, '10.0'

target 'Fyulaba' do
    use_frameworks!

    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'Whisper'
    pod 'FontAwesome.swift'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka', :branch => 'feature/Xcode9-Swift3_2'
    pod 'Hero'
    pod 'DZNEmptyDataSet'
    pod 'Cartography'
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'SwiftDate', '~> 4.0'
    pod 'Disk', '~> 0.1.4'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
                config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
            end
        end
    end

end
