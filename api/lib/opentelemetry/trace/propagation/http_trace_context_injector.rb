# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0
module OpenTelemetry
  module Trace
    module Propagation
      # Injects context into carriers using the W3C Trace Context format
      class HttpTraceContextInjector
        # Returns a new HttpTraceContextInjector that injects context using the
        # specified header keys
        #
        # @param [String] traceparent_header_key The traceparent header key used in the carrier
        # @param [String] tracestate_header_key The tracestate header key used in the carrier
        # @return [HttpTraceContextInjector]
        def initialize(traceparent_header_key:, tracestate_header_key:)
          @text_format = TextFormat.new(traceparent_header_key: traceparent_header_key,
                                        tracestate_header_key: tracestate_header_key)
        end

        # Set the span context on the supplied carrier.
        #
        # @param [Context] context The active {Context}.
        # @param [optional Callable] setter An optional callable that takes a carrier and a key and
        #   a value and assigns the key-value pair in the carrier. If omitted the default setter
        #   will be used which expects the carrier to respond to [] and []=.
        # @yield [Carrier, String, String] if an optional setter is provided, inject will yield
        #   carrier, header key, header value to the setter.
        # @return [Object] the carrier with context injected
        def inject(context, carrier, &setter)
          span_context = context[ContextKeys.span_context_key]
          @text_format.inject(span_context, carrier, &setter)
          carrier
        end
      end
    end
  end
end