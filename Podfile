platform :ios, '10.0'

target 'Fyulaba' do
    use_frameworks!
    
    pod 'AudioKit'
    pod 'AudioKit/UI'
    pod 'Disk'
    pod 'SwiftDate'
    pod 'Eureka'
    pod 'DZNEmptyDataSet'
    pod 'ReSwift'
    pod 'ReSwiftRouter'
    pod 'TagListView'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '5.0'
                config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.14'
            end
        end
    end

end
