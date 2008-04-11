# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def build_number
    rev_file   = File.expand_path "#{RAILS_ROOT}/REVISION"
    dot_hg_dir = File.expand_path "#{RAILS_ROOT}/.hg/"

    if File.exist? rev_file
      open(rev_file, 'r') { |file| file.read.strip }

    elsif File.exist? dot_hg_dir
      repo_dir = File.expand_path RAILS_ROOT
      `hg identify`.chomp
    else
      '(not versioned)'
    end
  end
  
end
