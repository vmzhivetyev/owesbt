# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'owesbt' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for owesbt
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod 'Masonry'

end

target 'owesbtTests' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for owesbtTests
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod 'Masonry'
  pod 'OCMock'
  pod 'Expecta'
  pod 'OHHTTPStubs'

end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        end
    end
end