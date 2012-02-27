module E9
  module Carrierwave
    module Controller
      extend ActiveSupport::Concern

      module ClassMethods
        # NOTE it's still necessary to define a member route for reset_#{mount_name}, e.g.
        #
        # resources :users
        #   member do
        #     delete :reset_avatar
        #     post :upload_avatar
        #   end
        # end
        #
        def carrierwave_column_methods(*columns)
          options = columns.extract_options!

          return if columns.empty?

          filter_str = "filter_access_to #{columns.map {|c| ":upload_#{c}, :reset_#{c}" }.join(', ') }, :require => :update"
          filter_str << ", :context => :#{options[:context]}" if options[:context]

          class_eval(filter_str)

          columns.each do |column|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def upload_#{column}
                object = resource
                
                if instance_params = params.delete(resource_instance_name)
                  ##
                  # if file passed, simply update the mount
                  #
                  if file = instance_params[:#{column}]
                    @column = :#{column}
                    object.update_attribute :#{column}, file

                  ##
                  # elsif %{some_column}_image_id is passed, update the image id. It allows 
                  # for an arbitrary mount name, but probably no longer needs this (anymore).  
                  #
                  elsif key_val = instance_params.select {|k,_| k =~ /_image_id$/ }.first
                    @column = key_val[0][/(.*)_image_id$/, 1].to_sym
                    object.#{column}_image_id = key_val[1]
                    # Image.find_by_id(key_val[1]).destroy
                  end
                end

                respond_with(object) do |format|
                  format.json { render :json => object.#{column}.to_json }
                  format.js do 
                    @mount = object.#{column}
                    render get_template(:upload, object)
                  end
                end
              end

              def reset_#{column}
                object = resource

                if object.respond_to?(:remove_#{column}!)
                  object.remove_#{column}!
                  object.send(:write_attribute, :#{column}, nil)
                  object.save(:validate => false)
                  object.reload
                end

                respond_with(object) do |format|
                  format.js { render 'carrierwave/reset' }
                end
              end

              # TODO find a better way to do this, how to append the appropriate dir to the view_path on a per action basis?
              #      Or achieve a like effect?  The need is that this action renders a different template based on not *its*
              #      controller, but an attribute of the record.  In this case I need images that are attached to banners
              #      to render the admin/banners/upload template.
              def get_template(action, object)
                "\#{object.is_a?(Image) && object.owner.is_a?(Banner) ? 'admin/banners/carrierwave' : 'carrierwave'}/\#{action}"
              end
              private :get_template
            RUBY
          end
        end
      end
    end

    module Model

      def mount_uploader(column, uploader = nil, options = {}, &block)
        super

        mod = Module.new
        include mod
        mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # NOTE should we destroy the image after save?  When is it safe to do so?
          attr_reader :#{column}_image_id

          def #{column}_image_id=(image_id)
            opts = image_id.kind_of?(Hash) ? image_id : { 'id' => image_id }
        
            if image = Image.find_by_id(opts['id'])
              if image.file?
                if opts['version']
                  self.#{column}.versions[opts['version'].to_sym].store!(image.file)
                  self.update_attribute(:updated_at, Time.now)
                else
                  self.#{column}.cache!(image.file)

                  if persisted?
                    self.updated_at = Time.now
                    self.save(:validate => false)
                  else
                    @#{column}_image_id = image.id
                  end
                end
              end
            end
          end
        RUBY
      end

    end
  end
end
