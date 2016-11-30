Pod::Spec.new do |s|
  s.name         = 'AXCollectionViewBalancedFlowLayout'
  s.version      = '1.0.0'
  s.summary      = 'A custom flow layout.'
  s.description  = <<-DESC
                    A custom flow layout of UICollectionView.
                   DESC
  s.homepage     = 'https://github.com/devedbox/AXCollectionViewBalancedFlowLayout'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'devedbox' => 'devedbox@qq.com' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/devedbox/AXCollectionViewBalancedFlowLayout.git', :tag => '1.0.0' }
  s.source_files  = 'AXCollectionViewBalancedFlowLayout/Classes/*.{h,m}'
  s.frameworks = 'UIKit', 'Foundation'

  s.requires_arc = true
end
