namespace :peervoice do
  
  namespace :configure do

    desc "configure this application as a given target TARGET (or default)"
    task :target do
      target = ENV["TARGET"] || 'default'

      CONFIG_DIR = File.join(RAILS_ROOT, 'config')
      TARGET_DIR = File.join(CONFIG_DIR, 'targets', target)

      Dir[File.join(TARGET_DIR, '*')].each do |file|
        filename = File.basename(file)
        puts "Deploying: #{filename}"
        cp File.join(TARGET_DIR, filename), File.join(CONFIG_DIR, filename)
      end
    end
  
  end
  
end