# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Trace
    # No-op implementation of Tracer.
    class Tracer
      CURRENT_SPAN_KEY = Propagation::ContextKeys.current_span_key

      private_constant :CURRENT_SPAN_KEY

      # Returns the current span from the current or provided context
      #
      # @param [optional Context] context The context to lookup the current
      #   {Span} from. Defaults to Context.current
      def current_span(context = nil)
        context ||= Context.current
        context.value(CURRENT_SPAN_KEY) || Span::INVALID
      end

      # Returns a context containing the span, derived from the optional parent
      # context, or the current context if one was not provided.
      #
      # @param [optional Context] context The context to use as the parent for
      #  the returned context
      def context_with_span(span, context = Context.current)
        context.set_value(CURRENT_SPAN_KEY, span)
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
      # On exit, the Span that was active before calling this method will be reactivated. If an
      # exception occurs during the execution of the provided block, it will be recorded on the
      # span and reraised.
      # @yield [span, context] yields the newly created span and a context containing the
      #   span to the block.
      def in_span(name, attributes: nil, links: nil, start_timestamp: nil, kind: nil, with_parent: nil)
        span = nil
        span = start_span(name, attributes: attributes, links: links, start_timestamp: start_timestamp, kind: kind, with_parent: with_parent)
        with_span(span) { |s, c| yield s, c }
      rescue Exception => e # rubocop:disable Lint/RescueException
        span&.record_exception(e)
        span&.status = Status.new(Status::ERROR,
                                  description: "Unhandled exception of type: #{e.class}")
        raise e
      ensure
        span&.finish
      end

      # Activates/deactivates the Span within the current Context, which makes the "current span"
      # available implicitly.
      #
      # On exit, the Span that was active before calling this method will be reactivated.
      #
      # @param [Span] span the span to activate
      # @yield [span, context] yields span and a context containing the span to the block.
      def with_span(span)
        Context.with_value(CURRENT_SPAN_KEY, span) { |c, s| yield s, c }
      end

      def start_root_span(name, attributes: nil, links: nil, start_timestamp: nil, kind: nil)
        Span.new
      end

      # Used when a caller wants to manage the activation/deactivation and lifecycle of
      # the Span and its parent manually.
      #
      # Parent context can be either passed explicitly, or inferred from currently activated span.
      #
      # @param [optional Context] with_parent Explicitly managed parent context
      #
      # @return [Span]
      def start_span(name, with_parent: nil, attributes: nil, links: nil, start_timestamp: nil, kind: nil)
        span_context = current_span(with_parent).context

        if span_context.valid?
          Span.new(span_context: span_context)
        else
          Span.new
        end
      end
    end
  end
end
