module Gena

  $xcode_project = nil

  class XcodeUtils < Thor

    no_tasks do

      def self.shared
        unless $utils
          $utils = XcodeUtils.new
        end
        $utils
      end

      def load_project_if_needed
        unless $xcode_project
          say "Loading project: #{$config.xcode_project_path}", Color::YELLOW if $verbose
          $xcode_project = Xcodeproj::Project.open($config.xcode_project_path)
        end
      end

      def save_project
        if $xcode_project
          say "Writing project (#{$config.xcode_project_path}) to disk..", Color::YELLOW if $verbose
          $xcode_project.save
        end
      end

      def obtain_target(target_name)
        load_project_if_needed
        $xcode_project.targets.each do |target|
          return target if target.name == target_name
        end
        say "Cannot find a target with name #{target_name} in Xcode project", Color::RED
        abort
      end

      def make_group(group_path, dir_path)
        load_project_if_needed

        group_path = $config.collapse_to_project(group_path)
        dir_path = $config.collapse_to_project(dir_path)

        group_names = path_names_from_path(group_path)

        group_components_count = group_names.count

        final_group = $xcode_project

        group_names.each_with_index do |group_name, index|
          next_group = final_group[group_name]

          unless next_group

            if group_path != dir_path && index == group_components_count-1
              next_group = final_group.new_group(group_name, dir_path, :project)
            else
              next_group = final_group.new_group(group_name, group_name)
            end
          end

          final_group = next_group
        end

        final_group
      end

      def add_file(target, group, file_path, is_resource)
        load_project_if_needed
        group.files.each do |file|
          if file.path == File.basename(file_path)
            return
          end
        end
        file = group.new_file(File.absolute_path(file_path))
        if is_resource
          target.add_resources([file])
        else
          target.add_file_references([file])
        end
      end

      def delete_path(path)
        load_project_if_needed

        path = $config.collapse_to_project(path)

        path_names = path_names_from_path(path)

        final_group = $xcode_project
        path_names.each_with_index do |group_name, index|
          final_group = final_group[group_name]
        end

        delete_node final_group
      end

      private

      def delete_node(node)
        if node.kind_of? Xcodeproj::Project::Object::PBXGroup
          node.recursive_children.each do |child|
            delete_node(child)
          end
          node.remove_from_project
        elsif node.kind_of? Xcodeproj::Project::Object::PBXFileReference
          node.build_files.each { |build_file| build_file.remove_from_project }
          node.remove_from_project
        end
      end

      def path_names_from_path(path)
        path.to_s.split('/')
      end

    end

  end


end