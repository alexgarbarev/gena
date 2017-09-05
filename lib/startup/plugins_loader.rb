
require_relative '../constants'


class PluginsLoader


  def load_all_plugins
    registered = []
    Dir["#{TEMPLATES_PROJECT_FOLDER}/**/*.rb", "#{TEMPLATES_SYSTEM_FOLDER}/**/*.rb"].each do |file|
      template_name = file.split(File::SEPARATOR)[-2]
      unless registered.include? template_name
        registered << template_name
        require file
      end
    end
    registered
  end

end