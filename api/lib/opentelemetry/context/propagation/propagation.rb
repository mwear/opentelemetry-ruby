# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  class Context
    module Propagation
      # The Propagation class provides methods to inject and extract context
      # to pass across process boundaries
      class Propagation
        HTTP_TRACE_CONTEXT_EXTRACTOR = Trace::Propagation::HttpTraceContextExtractor.new
        HTTP_TRACE_CONTEXT_INJECTOR = Trace::Propagation::HttpTraceContextInjector.new
        RACK_HTTP_TRACE_CONTEXT_EXTRACTOR = Trace::Propagation::HttpTraceContextExtractor.new(
          traceparent_header_key: 'HTTP_TRACEPARENT',
          tracestate_header_key: 'HTTP_TRACESTATE'
        )
        RACK_HTTP_TRACE_CONTEXT_INJECTOR = Trace::Propagation::HttpTraceContextInjector.new(
          traceparent_header_key: 'HTTP_TRACEPARENT',
          tracestate_header_key: 'HTTP_TRACESTATE'
        )
        HTTP_CORRELATION_CONTEXT_EXTRACTOR = CorrelationContext::Propagation::HttpCorrelationContextExtractor.new
        HTTP_CORRELATION_CONTEXT_INJECTOR = CorrelationContext::Propagation::HttpCorrelationContextInjector.new
        RACK_HTTP_CORRELATION_CONTEXT_EXTRACTOR = CorrelationContext::Propagation::HttpCorrelationContextExtractor.new(
          correlation_context_key: 'HTTP_CORRELATION_CONTEXT'
        )
        RACK_HTTP_CORRELATION_CONTEXT_INJECTOR = CorrelationContext::Propagation::HttpCorrelationContextInjector.new(
          correlation_context_key: 'HTTP_CORRELATION_CONTEXT'
        )
        BINARY_FORMAT = Trace::Propagation::BinaryFormat.new
        EMPTY_ARRAY = [].freeze

        private_constant :HTTP_TRACE_CONTEXT_INJECTOR, :HTTP_TRACE_CONTEXT_EXTRACTOR,
                         :RACK_HTTP_TRACE_CONTEXT_INJECTOR, :RACK_HTTP_TRACE_CONTEXT_EXTRACTOR,
                         :BINARY_FORMAT, :EMPTY_ARRAY

        # Get or set global http_extractors
        #
        # @param [Array<#extract>] extractors When setting, provide an array
        #   of extractors
        #
        # @return Array<#extract>
        attr_accessor :http_extractors

        # Get or set global http_injectors
        #
        # @param [Array<#inject>] injectors When setting, provide an array
        #   of injectors
        #
        # @return Array<#inject>
        attr_accessor :http_injectors

        def initialize
          @http_extractors = EMPTY_ARRAY
          @http_injectors = EMPTY_ARRAY
        end

        # Injects context into carrier to be propagated across process
        # boundaries
        #
        # @param [Object] carrier A carrier of HTTP headers to inject
        #   context into
        # @param [optional Context] context Context to be injected into carrier. Defaults
        #   to +Context.current+
        # @param [optional Array<Object>] http_injectors An array of HTTP injectors. Each
        #   injector will be invoked once with given context and carrier. Defaults to the
        #   globally registered +http_injectors+
        #
        # @return [Object] carrier
        def inject(carrier, context: Context.current, http_injectors: self.http_injectors)
          http_injectors.inject(carrier) do |memo, injector|
            injector.inject(context, memo)
          end
        end

        # Extracts context from a carrier
        #
        # @param [Object] carrier A carrier of HTTP headers to extract context
        #   from
        # @param [optional Context] context Context to be updated with the state
        #   extracted from the carrier. Defaults to +Context.current+
        # @param [optional Array<Object>] http_extractors An array of HTTP extractors.
        #   Each extractor will be invoked once with given context and carrier. Defaults
        #   to the globally registered +http_extractors+
        #
        # @return [Context] a new context updated with state extracted from the
        #   carrier
        def extract(carrier, context: Context.current, http_extractors: self.http_extractors)
          http_extractors.inject(context) do |ctx, extractor|
            extractor.extract(ctx, carrier)
          end
        end

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

        # Returns an extractor that extracts context using the W3C Correlation
        # Context format for HTTP
        def http_correlation_context_injector
          HTTP_CORRELATION_CONTEXT_INJECTOR
        end

        # Returns an injector that injects context using the W3C Correlation
        # Context format for HTTP
        def http_correlation_context_extractor
          HTTP_CORRELATION_CONTEXT_EXTRACTOR
        end

        # Returns an extractor that extracts context using the W3C Correlation
        # Context format for HTTP with Rack normalized keys (upcased and
        # prefixed with HTTP_)
        def rack_http_correlation_context_injector
          RACK_HTTP_CORRELATION_CONTEXT_INJECTOR
        end

        # Returns an injector that injects context using the W3C Correlation
        # Context format for HTTP with Rack normalized keys (upcased and
        # prefixed with HTTP_)
        def rack_http_correlation_context_extractor
          RACK_HTTP_CORRELATION_CONTEXT_EXTRACTOR
        end

        # Returns a propagator for the binary format
        def binary_format
          BINARY_FORMAT
        end
      end
    end
  end
end
