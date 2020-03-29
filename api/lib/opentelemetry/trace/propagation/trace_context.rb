# frozen_string_literal: true

# Copyright 2020 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry/trace/propagation/trace_context/trace_parent'
require 'opentelemetry/trace/propagation/trace_context/http_trace_context_extractor'
require 'opentelemetry/trace/propagation/trace_context/http_trace_context_injector'

module OpenTelemetry
  module Trace
    module Propagation
      # The TraceContext module contains injectors, extractors, and utilties
      # for context propagation in the W3C Trace Context format.
      module TraceContext
        extend self

        HTTP_TRACE_CONTEXT_EXTRACTOR = HttpTraceContextExtractor.new
        HTTP_TRACE_CONTEXT_INJECTOR = HttpTraceContextInjector.new
        RACK_HTTP_TRACE_CONTEXT_EXTRACTOR = HttpTraceContextExtractor.new(
          traceparent_header_key: 'HTTP_TRACEPARENT',
          tracestate_header_key: 'HTTP_TRACESTATE'
        )
        RACK_HTTP_TRACE_CONTEXT_INJECTOR = HttpTraceContextInjector.new(
          traceparent_header_key: 'HTTP_TRACEPARENT',
          tracestate_header_key: 'HTTP_TRACESTATE'
        )

        private_constant :HTTP_TRACE_CONTEXT_INJECTOR, :HTTP_TRACE_CONTEXT_EXTRACTOR,
                         :RACK_HTTP_TRACE_CONTEXT_INJECTOR, :RACK_HTTP_TRACE_CONTEXT_EXTRACTOR

        # Returns an extractor that extracts context using the W3C Trace Context
        # format for HTTP
        def http_trace_context_extractor
          HTTP_TRACE_CONTEXT_EXTRACTOR
        end

        # Returns an injector that injects context using the W3C Trace Context
        # format for HTTP
        def http_trace_context_injector
          HTTP_TRACE_CONTEXT_INJECTOR
        end

        # Returns an extractor that extracts context using the W3C Trace Context
        # format for HTTP with Rack normalized keys (upcased and prefixed with
        # HTTP_)
        def rack_http_trace_context_extractor
          RACK_HTTP_TRACE_CONTEXT_EXTRACTOR
        end

        # Returns an injector that injects context using the W3C Trace Context
        # format for HTTP with Rack normalized keys (upcased and prefixed with
        # HTTP_)
        def rack_http_trace_context_injector
          RACK_HTTP_TRACE_CONTEXT_INJECTOR
        end
      end
    end
  end
end
