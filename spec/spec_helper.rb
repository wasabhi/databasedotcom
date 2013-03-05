require 'webmock/rspec'
Encoding.default_external = Encoding::UTF_8 if defined?(Encoding)
Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'shared_behaviors', '**', '*.rb')).each do |f|
    require f
end
