# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
module OpenTelemetry
  module Propagator
    # Namespace for OpenTelemetry propagator extension libraries
    module B3
      extend self

      DEBUG_CONTEXT_KEY = Context.create_key('b3-debug-key')
      PADDING = '0' * 16
      private_constant :DEBUG_CONTEXT_KEY, :PADDING

      def debug(context)
        context.set_value(DEBUG_CONTEXT_KEY, true)
      end

      def debug?(context)
        context.value(DEBUG_CONTEXT_KEY)
      end

      def to_trace_id(id_str)
        id_str = "#{PADDING}#{id_str}" unless id_str.length == 32
        Array(id_str).pack('H*')
      end

      def to_span_id(id_str)
        Array(id_str).pack('H*')
      end
    end
  end
end

require_relative './b3/version'
require_relative './b3/multi/text_map_extractor'
require_relative './b3/single/text_map_extractor'
require_relative './b3/single/text_map_injector'
