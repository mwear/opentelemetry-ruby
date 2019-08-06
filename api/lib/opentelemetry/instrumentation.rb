# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors

# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  # This class facilitates the registering, configuring, and installing of
  # instrumentation packages
  class Instrumentation
    class << self
      # rubocop:disable Style/AccessModifierDeclarations
      private :new
      # rubocop:enable Style/AccessModifierDeclarations

      # Instrumentation subclasses are registered via this hook
      def inherited(subclass)
        subclasses << subclass
      end

      def subclasses
        @subclasses ||= []
      end

      def instrumentation_name(name = nil)
        if name.nil?
          @instrumentation_name
        else
          @instrumentation_name = name.to_sym
        end
      end

      def instance
        @instance ||= new
      end
    end

    def instrumentation_name
      self.class.instrumentation_name
    end
  end
end
