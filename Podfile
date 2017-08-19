platform :ios, '10.0'

target 'Fyulaba' do
    use_frameworks!

    pod 'Disk', '~> 0.1.4'
    pod 'Whisper'
    pod 'SwiftDate', '~> 4.0'
    pod 'Hero'
    pod 'DZNEmptyDataSet'
    pod 'Cartography'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
                config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
            end
        end
    end

end

