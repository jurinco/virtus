module Virtus

  # Extensions common for both classes and instances
  module Extensions
    WRITER_METHOD_REGEXP   = /=\z/.freeze
    INVALID_WRITER_METHODS = %w[ == != === []= attributes= ].to_set.freeze
    RESERVED_NAMES         = [:attributes].to_set.freeze

    # A hook called when an object is extended with Virtus
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    def self.extended(object)
      super
      object.instance_variable_set('@attribute_set', AttributeSet.new)
      object.instance_eval do
        extend InstanceMethods
        extend InstanceMethods::Constructor
        extend InstanceMethods::MassAssignment
        extend attribute_set
      end
    end
    private_class_method :extended

    # Defines an attribute on an object's class
    #
    # @example
    #    class Book
    #      include Virtus
    #
    #      attribute :title,        String
    #      attribute :author,       String
    #      attribute :published_at, DateTime
    #      attribute :page_count,   Integer
    #      attribute :index                   # defaults to Object
    #    end
    #
    # @param [Symbol] name
    #   the name of an attribute
    #
    # @param [Class] type
    #   the type class of an attribute
    #
    # @param [#to_hash] options
    #   the extra options hash
    #
    # @return [self]
    #
    # @see Attribute.build
    #
    # @api public
    def attribute(name, type, options = {})
      assert_valid_name(name)
      attribute_set << Attribute.build(type, merge_options(name, options))
      self
    end

    # @api public
    def values(&block)
      instance_eval do
        private :attributes=

        def attribute(name, type, options = {})
          super(name, type, options.merge(:writer => :private))
        end
      end

      yield

      extend(ValueObject::AllowedWriterMethods)
      include(ValueObject::InstanceMethods)

      include(::Equalizer.new(*attribute_set.map(&:name)))

      self
    end

    # The list of writer methods that can be mass-assigned to in #attributes=
    #
    # @return [Set]
    #
    # @api private
    def allowed_writer_methods
      @allowed_writer_methods ||=
        begin
          allowed_writer_methods  = allowed_methods.grep(WRITER_METHOD_REGEXP).to_set
          allowed_writer_methods -= INVALID_WRITER_METHODS
          allowed_writer_methods.freeze
        end
    end

    private

    # Return an attribute set for that instance
    #
    # @return [AttributeSet]
    #
    # @api private
    def attribute_set
      @attribute_set
    end

    # Merge default options
    #
    # @return [Hash]
    #
    # @api private
    def merge_options(name, options)
      { :name => name }.merge(options)
    end

    # @api private
    def assert_valid_name(name)
      if RESERVED_NAMES.include?(name.to_sym)
        raise ArgumentError, "#{name.inspect} is not allowed as an attribute name"
      end
    end

  end # module Extensions
end # module Virtus
