module E9::Liquid::Tags
  class Slideshow < Base
    class << self
      def title; 'Slideshow' end
      def description; 'Tag to render a slideshow' end
      def tag_name; 'slideshow' end
      def partial; 'shared/liquid_tags/slideshow' end
      def options; [:search] end
      def array_attributes; [:tags, :labels] end
      def js_options
        {
          :autoplay => :boolean,
          :carousel => :boolean,
          :carousel_follow => :boolean, 
          :carousel_speed => :integer,
          :carousel_steps => :string,
          :clicknext => :boolean,
          :debug => :boolean,
          :easing => :string,
          :height => :integer,
          :idle_time => :integer,
          :image_crop => :boolean,
          :image_margin => :integer,
          :image_pan => :boolean,
          :image_pan_smoothness => :integer,
          :image_position => :string,
          :keep_source => :boolean,
          :lightbox_fade_speed => :integer,
          :lightbox_transition_speed => :integer,
          :link_source_images => :boolean,
          :overlay_opacity => :decimal, # 0..1
          :overlay_background => :string, # hex color
          :pause_on_interaction => :boolean,
          :popup_links => :boolean,
          :preload => :integer,
          :queue => :boolean,
          :show => :integer,
          :show_info => :boolean,
          :show_counter => :boolean,
          :show_imagenav => :boolean,
          :theme => :string,
          :thumb_crop => :boolean,
          :thumb_fit => :boolean,
          :thumb_margin => :integer,
          :thumb_quality => :integer,
          :thumbnails => :boolean,
          :transition => :string, # accepts: fade, slide, flash, pulse, fadeSlide
          :transition_initial => :string,
          :transition_speed => :integer,
          :width => :integer
        }
      end
    end

    def render!
      options   = {}

      slideshow = if (id = @attributes[:slideshow_id]).present?
                    ::Slideshow.where(:id => id).first
                  elsif link = @attributes[:slideshow_name] || @attributes[:slideshow]
                    ::Slideshow.where(:permalink => link).first
                  else
                    # search
                    if search = @attributes[:search]
                      options[:search] = search

                    # or context/tags, not both
                    else
                      if context = @attributes[:context]
                        options[:tagged_with_context] = context
                      end

                      if (labels = @attributes[:labels] || @attributes[:tags]).present?
                        options[:tagged_with] = labels
                      end
                    end

                    # order 
                    order_options = %w(alpha alphabetical published published_at updated updated_at)

                    if (order = @attributes[:sort] || @attributes[:order]) && order_options.member?(order.downcase)
                      attribute = case order.downcase
                        when 'alpha',     'alphabetical'  then :title
                        when 'published', 'published_at'  then :published_at
                        when 'updated',   'updated_at'    then :updated_at
                      end

                      direction = E9.true_value?(@attributes[:reverse]) ? :desc : :asc
                      
                      options[:ordered_on] = attribute
                      options[:dir]        = direction
                    end

                    # limit
                    if (limit = @attributes[:limit]) && limit =~ /\d+/
                      options[:limit] = limit
                    end

                    ::Slideshow.new
                  end

      if slideshow.present?
        render_partial self.class.partial, :resource => slideshow, :search_options => options, :js_options => process_js_options(@attributes)
      end
    end

    def process_js_options(attrs)
      attrs = attrs.symbolize_keys.slice(*self.class.js_options.keys)
      attrs.inject({}) do |mem, key_val|
        key, val = key_val

        mem[key] = case val
                   when /^true$/i;    true
                   when /^false$/i;   false
                   when /^(1|0)$/
                     if self.class.js_options[key] == :boolean
                       $1 == '1' ? true : false
                     else
                       val.to_i
                     end
                   when /^\d+$/;      val.to_i
                   when /^\d*\.\d+$/; val.to_f
                   else               val
                   end

        mem
      end
    end
  end

  Liquid::Template.register_tag(Slideshow.tag_name, Slideshow)
end
