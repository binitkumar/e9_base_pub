module E9
  # 
  # Module for classes that perform the job of an ImageSpecification for
  # mounted Images.
  #
  # Including classes must implement <tt>spec_width</tt> and <tt>spec_height</tt>.
  #
  module ImageSpecification
    def spec_dimensions
      Dimensions.new(self, spec_width, spec_height)
    end

    delegate :present?, :valid?, :satisfied_by?, :to => :spec_dimensions, :prefix => :spec

    # NOTE Most spec methods are delegated to the internal spec, but spec_name 
    # and spec_required? are actually methods on the including record for 
    # purposes of subclass overrides.  Careful with infinite recursion here.
    def spec_name() '' end
    def spec_required?() true end

    class Dimensions < Array
      def initialize(record, width, height)
        @record = record
        super [width, height]
      end

      def width() self[0] end
      def height() self[1] end
      def to_s() "#{width}x#{height}" end
      def name() @record.spec_name end
      def required?() @record.spec_required? end

      def satisfied_by?(image)
        return true unless required? && valid?
        self == image.dimensions
      end

      def valid?
        [width, height].all? {|n| n.is_a?(Fixnum) && n > 0 }
      end

      def present?
        valid?
      end
    end
  end
end
