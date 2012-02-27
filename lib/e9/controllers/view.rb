module E9::Controllers
  module View
    extend ActiveSupport::Concern

    included do
      before_filter :find_layouts, :only => :layouts
      filter_access_to :layouts, :change_layout, :attribute_check => true, :load_method => :filter_target, :context => :admin
    end

    def change_layout
      object = resource 

      object.change_layout(::Layout.find(params[:layout_id]))

      respond_with(object) do |format|
        format.html { redirect_to(collection_path)  }
      end
    end

    def layouts
      object = resource

      respond_to do |format|
        format.html do
          render layouts_template, :layout => !request.xhr?

          # TODO this would be good but it requires some hacking of
          # colorbox to work as there's no error interception
          #
          #if @layouts.length > 1
            #render layouts_template, :layout => !request.xhr?
          #else
            #render :text => "There are no other layouts for this content type.", :status => 400
          #end
        end
      end
    end

    protected

      def layouts_template
        'admin/views/layouts'
      end

      def find_layouts
        @layouts ||= ::Layout.for_roleable(current_user).for_page_class(resource_class)
      end

      def params_for_build
        params[resource_instance_name] ||= {}
      end

      #
      # On the initial new request, prototype from the layout.  On subsequent form requests, build normally from the params.
      #
      def build_resource
        get_resource_ivar || set_resource_ivar(built_resource)
      end

      def built_resource
        if params[:action] != 'new'
          build_resource_from_class
        elsif record = record_to_copy
          record.copy
        else
          build_resource_from_layout
        end
      end

      def build_resource_from_layout
        find_layout.prototype(resource_class, params_for_build)
      end

      # NOTE this will need to be overridden for controller routes that don't uesr permalink
      def record_to_copy
        params[:copy_id] && resource_class.find_by_permalink(params[:copy_id])
      end

      def build_resource_from_class
        resource_class.new(params_for_build).tap do |built|
          prototyped = build_resource_from_layout

          unless (prototyped_regions = prototyped.try(:regions)).blank?
            # effectively built.regions |= prototyped_regions
            #
            # This is done to ensure that the new resource has regions
            # that the submitter of the form may not have access to.
            #
            built.regions += prototyped_regions.select {|region| !built.regions.member?(region) }
          end

          #
          # NOTE images do not work this way anymore.  They're now a nested association.
          # Left here for clarity and 
          #
          # This method allows us to assign to and crop images for "view" records before they are saved,
          # working on a similar idea to the region splicing for regions above the current users's privileges.
          # 
          # In Layout#prototype! the prototyped view is given an image for each image_spec of the Layout,
          # but these images are not yet saved and have no ID, but they do have a spec.  If the form is submitted
          # with these blank (no file) images the image spec validation will fail, and the form will be re-rendered.
          #
          # This method ensures that every time the form is submitted, the missing images from the prototyped
          # image array are replaced into the array of images passed to the new record, so until all the specs
          # are satisfied, the image will fail validation.
          #
          # It also performs another duty of Layout#prototype! and sets the 'owner' association of each of the 
          # images in the array, for the purposes of mount label name lookup.  (Since the images aren't associated
          # to the new record until after it is saved).
          #
          #
          #if resource_class.reflect_on_association(:images)
            #built.images = prototyped.images.map do |pr_i|
              #img = if i = built.images.index {|pa_i| pa_i.image_spec_id == pr_i.image_spec_id }
                #built.images.slice(i)
              #else
                #pr_i
              #end

              #img.owner = built
              #img
            #end
          #end

          # NOTE "placements" work identically to images, as above
          # TODO write a subroutine for this method
          if resource_class.reflect_on_association(:placements)
            built.placements = prototyped.placements.map do |pp|
              placement = if i = built.placements.index {|bp| pp.associated_id == bp.associated_id }
                built.placements.slice(i)
              else
                pp
              end

              placement.owner = built
              placement
            end
          end

          yield(built, prototyped) if block_given?
        end
      end

      ##
      # Filters
      #
      def find_layout
        @_found_layout ||= begin
          if layout_id = params[:layout_id]
            ::Layout.find(layout_id)
          elsif layout_id = params[resource_instance_name].try(:[], :layout_id)
            ::Layout.find(layout_id)
          else
            ::Layout.for(resource_class)
          end
        end
      end

      def update_resource(object, attributes)
        object.update_attributes(attributes).tap do |success|
          clear_and_update_regions(object) if success
        end
      end

      def clear_and_update_regions(obj)
        if regions_attributes = params[resource_instance_name][:regions_attributes]
          regions_attributes.values.each do |hash|
            region = obj.regions.detect {|r| r.id.to_s == hash[:id] }
            next if region.nil?

            region.nodes.clear()
            region.nodes_attributes = hash[:nodes_attributes] if hash[:nodes_attributes]
            region.save(:validate => false)
          end
        end
      end
    #end protected
  end
end
