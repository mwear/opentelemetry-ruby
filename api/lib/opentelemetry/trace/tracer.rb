# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Trace
    # No-op implementation of Tracer.
    class Tracer
      REMOTE_SPAN_CONTEXT_KEY = Propagation::ContextKeys.remote_span_context_key
      CURRENT_SPAN_KEY = Propagation::ContextKeys.current_span_key

      private_constant :REMOTE_SPAN_CONTEXT_KEY, :CURRENT_SPAN_KEY

      def current_span
        Context.value(CURRENT_SPAN_KEY) || Span::INVALID
      end

      # Returns the span active of the currently active span. It's possible for
      # the current span context to refer to a remote parent that has been
      # extracted. If both a current span and an extracted, remote context
      # exist, the context of the current span will be returned.
      def current_span_context
        Context.value(CURRENT_SPAN_KEY)&.context ||
          Context.value(REMOTE_SPAN_CONTEXT_KEY) ||
          SpanContext::INVALID
      end

      # This is a helper for the default use-case of extending the current trace with a span.
      #
      # With this helper:
      #
      #   OpenTelemetry.tracer.in_span('do-the-thing') do ... end
      #
      # Equivalent without helper:
      #
      #   OpenTelemetry.tracer.with_span(OpenTelemetry.tracer.start_span('do-the-thing')) do ... end
      #
      # On exit, the Span that was active before calling this method will be reactivated.
      def in_span(name, attributes: nil, links: nil, start_timestamp: nil, kind: nil, sampling_hint: nil, with_parent: nil, with_parent_context: nil)
        span = start_span(name, attributes: attributes, links: links, start_timestamp: start_timestamp, kind: kind, sampling_hint: sampling_hint, with_parent: with_parent, with_parent_context: with_parent_context)
        with_span(span) { |s| yield s }
      ensure
        span.finish
      end

      # Activates/deactivates the Span within the current Context, which makes the "current span"
      # available implicitly.
      #
      # On exit, the Span that was active before calling this method will be reactivated.
      def with_span(span)
        Context.with_value(CURRENT_SPAN_KEY, span) { |s| yield s }
      end

      def start_root_span(name, attributes: nil, links: nil, start_timestamp: nil, kind: nil, sampling_hint: nil)
        Span.new
      end

      # Used when a caller wants to manage the activation/deactivation and lifecycle of
      # the Span and its parent manually.
      #
      # Parent context can be either passed explicitly, or inferred from currently activated span.
      #
      # @param [optional Span] with_parent Explicitly managed parent Span, overrides
      #   +with_parent_context+.
      # @param [optional SpanContext] with_parent_context Explicitly managed. Overridden by
      #   +with_parent+.
      #
      # @return [Span]
      def start_span(name, with_parent: nil, with_parent_context: nil, attributes: nil, links: nil, start_timestamp: nil, kind: nil, sampling_hint: nil)
        span_context = with_parent&.context || with_parent_context || current_span_context
        if span_context.valid?
          Span.new(span_context: span_context)
        else
          Span.new
        end
      end
    end
  end
end
