# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'

require_relative 'middlewares/tracer_middleware'
require_relative 'patches/rack_builder'

module OpenTelemetry
  module Adapters
    module Faraday
      class Adapter < OpenTelemetry::Instrumentation::Adapter
        install do |config|
          config[:tracer_middleware] ||= Middlewares::TracerMiddleware

          register_tracer_middleware
          use_middleware_by_default
        end

        present do
          Gem.loaded_specs.include?('faraday')
        end

        private

        def register_tracer_middleware
          ::Faraday::Middleware.register_middleware(
            open_telemetry: config[:tracer_middleware]
          )
        end

        def use_middleware_by_default
          ::Faraday::RackBuilder.prepend(Patches::RackBuilder)
        end
      end
    end
  end
end
