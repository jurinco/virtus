module Virtus

  module Model

    # @api private
    def self.included(descendant)
      return unless descendant.is_a?(Class)
      descendant.class_eval {
        include Core
        include Constructor
        include MassAssignment
      }
    end

    module Core

      # @api private
      def self.included(descendant)
        super
        descendant.extend(ClassMethods)
        descendant.send(:include, ClassInclusions::Methods)
        descendant.send(:include, InstanceMethods)
      end
      private_class_method :included

      # @api private
      def self.extended(descendant)
        super
        descendant.extend(ClassMethods)
        descendant.send(:include, InstanceMethods)
      end
      private_class_method :included

    end # Core

    module Constructor

      # @api private
      def self.included(descendant)
        super
        descendant.send(:include, InstanceMethods::Constructor)
      end
      private_class_method :included

    end # Constructor

    module MassAssignment

      # @api private
      def self.included(descendant)
        super
        descendant.send(:include, InstanceMethods::MassAssignment)
      end
      private_class_method :included

    end # MassAssignment

  end # Model
end # Virtus
