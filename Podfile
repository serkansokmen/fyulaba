platform :ios, '11.0'

target 'Fyulaba' do
    use_frameworks!

    pod 'Disk', '~> 0.1.4'
    pod 'SwiftDate', '~> 4.0'
    pod 'Hero'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka', :branch => 'feature/Xcode9-Swift3_2'
    pod 'DZNEmptyDataSet'
    pod 'Cartography'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'ReSwift'
    pod 'ReSwiftRouter'
    pod 'ReSwiftRecorder'
    pod 'RxSwift'
    pod 'RxCocoa'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
                config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
            end
        end
    end

end
